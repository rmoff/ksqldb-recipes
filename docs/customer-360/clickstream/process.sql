-- stream of user clicks:
CREATE STREAM clickstream (
  _time bigint,
  time varchar,
  ip varchar,
  request varchar,
  status int,
  userid int,
  bytes bigint,
  agent varchar
) WITH (
  kafka_topic = 'clickstream',
  value_format = 'json',
  partitions = 6
);

-- users lookup table:
CREATE TABLE WEB_USERS (
  user_id int primary key,
  registered_At BIGINT,
  username varchar,
  first_name varchar,
  last_name varchar,
  city varchar,
  level varchar
) WITH (
  kafka_topic = 'clickstream_users',
  value_format = 'json',
  partitions = 6
);

-- Build materialized stream views:

-- enrich click-stream with more user information:
CREATE STREAM USER_CLICKSTREAM AS
  SELECT
    userid,
    u.username,
    ip,
    u.city,
    request,
    status,
    bytes
  FROM clickstream c
  LEFT JOIN web_users u ON c.userid = u.user_id;

-- Build materialized table views:

-- Table of html pages per minute for each user:
CREATE TABLE pages_per_min AS
  SELECT
    userid as k1,
    AS_VALUE(userid) as userid,
    WINDOWSTART as EVENT_TS,
    count(*) AS pages
  FROM clickstream WINDOW HOPPING (size 60 second, advance by 5 second)
  WHERE request like '%html%'
  GROUP BY userid;

-- User sessions table - 30 seconds of inactivity expires the session
-- Table counts number of events within the session
CREATE TABLE CLICK_USER_SESSIONS AS
  SELECT
    username as K,
    AS_VALUE(username) as username,
    WINDOWEND as EVENT_TS,
    count(*) AS events
  FROM USER_CLICKSTREAM window SESSION (30 second)
  GROUP BY username;

-- number of errors per min, using 'HAVING' Filter to show ERROR codes > 400 where count > 5
CREATE TABLE ERRORS_PER_MIN_ALERT AS
  SELECT
    status as k1,
    AS_VALUE(status) as status,
    WINDOWSTART as EVENT_TS,
    count(*) AS errors
  FROM clickstream window HOPPING (size 60 second, advance by 20 second)
  WHERE status > 400
  GROUP BY status
  HAVING count(*) > 5 AND count(*) is not NULL;

-- Enriched user details table:
-- Aggregate (count&groupBy) using a TABLE-Window
CREATE TABLE USER_IP_ACTIVITY WITH (key_format='json') AS
  SELECT
    username as k1,
    ip as k2,
    city as k3,
    AS_VALUE(username) as username,
    WINDOWSTART as EVENT_TS,
    AS_VALUE(ip) as ip,
    AS_VALUE(city) as city,
    COUNT(*) AS count
  FROM USER_CLICKSTREAM WINDOW TUMBLING (size 60 second)
  GROUP BY username, ip, city
  HAVING COUNT(*) > 1;
