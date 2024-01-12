# Logical DDL
logical_ddl is an extension for PostgreSQL that captures DDL operations against tables and helps them replicate over logical replication to subscribers. The extension is to decrease required amount of manual operations for DDLs and risk of stopping replication due to table definition mismatches when logical replication is used.

## How it works?
logical_ddl captures DDL operations by helping of event trigger feature of PostgreSQL. After execution of DDL command, trigger function, which is written in PL/pgSQL and C, is called for deparsing executed DDL command and saves it into a table that is also replicated over logical replication. When subscriber receives details of DDL operation, it generates an SQL (DDL) query so as to apply the same or similar changes to the table on the subscriber's side and executes it.

You can find detailed information for event triggers: https://www.postgresql.org/docs/current/event-triggers.html

## Which DDL operations are captured?
* ALTER TABLE .. RENAME TO ..
* ALTER TABLE .. RENAME COLUMN .. TO ..
* ALTER TABLE .. ADD COLUMN ..
* ALTER TABLE .. ALTER COLUMN .. TYPE ..
* ALTER TABLE .. DROP COLUMN ..

## Which data types are compatible
* All built-in data types are supported.
* Arrays are supported.
* Composite data types, domains, and enumerated types are supported.
    * Replicating definitions of composite data types, domains, and enumerated types themselves are not supported. Data types or domains should already be available on subscriber side.

## Caveats
* To be able to run a ALTER TABLE command againt a table, a role has to be owner of the object or has SUPERUSER privilege. logical_ddl works under SUPERUSER privileges.
* PostGIS hasn't been tested, yet.
* *USING* expression of data type changes hasn't been implemented, yet.
* Capturing and replicating default value expressions of columns haven't been implemented, yet.
* Capturing and replicating table and column constraints haven't been implemented, yet.
* Capturing and replicating indexes haven't been implemented, yet.
* The extension is still under development. There can be changes near future that can be incompatiple with the current version.

## Installation
The extension mainly developed and tested on Linux environment. Compilation and installation consist of three simple main steps.

```
$ cd src/
$ make
# make install
```

After compiling, extension can be created by executing following command in psql.
```
logical_ddl=# CREATE EXTENSION logical_ddl;
```

## Configuration
### logical_ddl.setting
Table has two columns.
| Column name | Data type   | Definition |
| ----------- | ----------- | ---------- |
| publish     | boolean     | Controls role of source, one or zero row can exists with true value. |
| source      | varchar(64) | Source name, it has to be longer than 2 characters.                  |

Extension can be configured as subsriber, publisher or both. Role of extension is controlled over records in logical_ddl.settings table.
* If there is a record with 'true' on publish column, extension starts capturing and publishing DDLs.
* If there is a record with 'false' on publish column, extension starts listening incoming DDLs from sources defined in source column.

### logical_ddl.publish_tablelist
Table has three columns.
| Column name | Data type   | Definition |
| ----------- | ----------- | ---------- |
| id          | int         | Primary key attribute |
| relid       | oid         | Object ID of source table |
| cmd_list    | text[]      | Command list of being captured, default value is '{}'::text[] |

This table manages the tables whose DDL changes are captured and replicated. Which changes should be published by extension can be defined on table level over cmd_list column of publish_tablelist table. cmd_list columns is a text array. Currently valid values are;
| Value                           | Definition |
| ------------------------------- | ---------- |
| '{}'::text[]                    | Empty array, captures and publish all changes. This is default behaviour. |
| "alter table.rename table"      | Captures *ALTER TABLE .. RENAME TO ..* |
| "alter table.rename column"     | Captures *ALTER TABLE .. RENAME COLUMN .. TO ..* |
| "alter table.add column"        | Captures *ALTER TABLE .. ADD COLUMN .. ..* |
| "alter table.drop column"       | Captures *ALTER TABLE .. DROP COLUMN ..* |
| "alter table.alter column type" | Captures *ALTER TABLE .. ALTER COLUMN .. TYPE ..* |

### logical_ddl.subscribe_tablelist
| Column name | Data type   | Definition |
| ----------- | ----------- | ---------- |
| id          | int         | Primary key attribute |
| source      | varchar(64) | Source name of DDLs |
| relid       | oid         | Object ID of target table |
| cmd_list    | text[]      | Command list of being replayed, default value is '{}'::text[] |

Valid values of cmd_list is the same with publish_tablelist's cmd_list column.

## Monitoring
### logical_ddl.shadow_table
shadow_table is the table that captured changes are stored in. The table has five columns.
| Column name | Data type   | Definition |
| ----------- | ----------- | ---------- |
| id          | int         | Identitiy number, unique for each source |
| source      | varchar(64) | Source name of DDLs |
| schema_name | varchar(64) | Schema name of table |
| command     | json        | Details of DDL command |
| date        | timestamp   | When changes is captured |

### logical_ddl.applied_commands
| Column name    | Data type   | Definition |
| -------------- | ----------- | ---------- |
| id             | int         | Identitiy number, unique for each source |
| source         | varchar(64) | Source name of DDLs |
| command_string | text        | Generated DDL query on subscriber side |
| command_id     | int         | Id number of received command in shadow_table. |
| applied_date   | timestamp   | When the command is executed |
| is_failed      | boolean     | Is execution of generated DDL command failed? |

## Simple Configuration
All commands are run by a role with SUPERUSER privilege.
### Publisher side
1. Create extension

    `CREATE EXTENSION logical_ddl;`

1. Give a name to your publication

    `INSERT INTO logical_ddl.settings VALUES (true, 'source1');`

1. Add tables to your publication

    `INSERT INTO logical_ddl.publish_tablelist (relid) VALUES ('table1'::regclass);`

    If you want to add all tables in logical replication, you can use following query.

    `INSERT INTO logical_ddl.publish_tablelist (relid) SELECT prrelid FROM pg_catalog.pg_publication_rel;`

1. Add shadow_table to your publication

    `ALTER PUBLICATION log_pub_1 ADD TABLE logical_ddl.shadow_table;`
    
### Subscriber side
1. Create extension

    `CREATE EXTENSION logical_ddl;`

1. Add DDL publisher source name

    `INSERT INTO logical_ddl.settings VALUES (false, 'source1');`

1. Add target tables for DDL operations

    `INSERT INTO logical_ddl.subscribe_tablelist (source,relid) VALUES ('source1','table1'::regclass);`

    If you want to add all tables in logical replication, you can use following query.

    `INSERT INTO logical_ddl.subscribe_tablelist (source,relid) SELECT 'source1',srrelid FROM pg_catalog.pg_subscription_rel;`

1. Refresh publication

    `ALTER SUBSCRIPTION log_sub_1 REFRESH PUBLICATION;`
