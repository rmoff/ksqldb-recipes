-- Stream of transactions
CREATE SOURCE CONNECTOR FD_transactions WITH (
  'connector.class'          = 'OracleDatabaseSource',
  'name'                     = 'recipe-oracle-transactions',
  'connector.class'          = 'OracleDatabaseSource',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'connection.host'          = '<my-database-endpoint>',
  'connection.port'          = '1521',
  'connection.user'          = '<database-username>',
  'connection.password'      = '<database-password>',
  'db.name'                  = '<db-name>',
  'table.whitelist'          = 'TRANSACTIONS',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON',
  'db.timezone'              = 'UCT',
  'tasks.max'                = '1');

-- Stream of customers
CREATE SOURCE CONNECTOR FD_customers WITH (
  'connector.class'          = 'OracleDatabaseSource',
  'name'                     = 'recipe-oracle-customers',
  'connector.class'          = 'OracleDatabaseSource',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'connection.host'          = '<my-database-endpoint>',
  'connection.port'          = '1521',
  'connection.user'          = '<database-username>',
  'connection.password'      = '<database-password>',
  'db.name'                  = '<db-name>',
  'table.whitelist'          = 'CUSTOMERS',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON',
  'db.timezone'              = 'UCT',
  'tasks.max'                = '1');
