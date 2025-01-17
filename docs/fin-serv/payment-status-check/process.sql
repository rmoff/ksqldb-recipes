-- Register the initial streams and tables from the Kafka topics
CREATE STREAM PAYMENTS (
  PAYMENT_ID INTEGER KEY,
  CUSTID INTEGER,
  ACCOUNTID INTEGER,
  AMOUNT INTEGER,
  BANK VARCHAR
) WITH (
  kafka_topic='payments',
  value_format='json',
  PARTITIONS=6
);

create stream aml_status (
  PAYMENT_ID INTEGER,
  BANK VARCHAR,
  STATUS VARCHAR
) with (
  kafka_topic='aml_status',
  value_format='json',
  PARTITIONS=6
);

create stream funds_status (
  PAYMENT_ID INTEGER,
  REASON_CODE VARCHAR,
  STATUS VARCHAR
) with (
  kafka_topic='funds_status',
  value_format='json',
  PARTITIONS=6
);

create table customers (
  ID INTEGER PRIMARY KEY, 
  FIRST_NAME VARCHAR, 
  LAST_NAME VARCHAR, 
  EMAIL VARCHAR, 
  GENDER VARCHAR, 
  STATUS360 VARCHAR
) WITH (
  kafka_topic='customers',
  value_format='JSON',
  PARTITIONS=6
);

-- Enrich Payments stream with Customers table
CREATE STREAM enriched_payments AS SELECT
  p.payment_id as payment_id,
  p.custid as customer_id,
  p.accountid,
  p.amount,
  p.bank,
  c.first_name,
  c.last_name,
  c.email,
  c.status360
  from payments p left join customers c on p.custid = c.id;

-- Combine the status streams
CREATE STREAM payment_statuses AS SELECT
  payment_id,
  status,
  'AML' as source_system
  FROM aml_status;

INSERT INTO payment_statuses SELECT payment_id, status, 'FUNDS' as source_system FROM funds_status;

-- Combine payment and status events in 1 hour window. Why we need a timing window for stream-stream join?
CREATE STREAM payments_with_status AS SELECT
  ep.payment_id as payment_id,
  ep.accountid,
  ep.amount,
  ep.bank,
  ep.first_name,
  ep.last_name,
  ep.email,
  ep.status360,
  ps.status,
  ps.source_system
  FROM enriched_payments ep LEFT JOIN payment_statuses ps WITHIN 1 HOUR ON ep.payment_id = ps.payment_id ;

-- Aggregate data to the final table
CREATE TABLE payments_final AS SELECT
  payment_id,
  histogram(status) as status_counts,
  collect_list('{ "system" : "' + source_system + '", "status" : "' + STATUS + '"}') as service_status_list
  FROM payments_with_status
  WHERE status is not null
  GROUP BY payment_id;
