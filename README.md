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
Following data types have been tested. Other data types are likely compatible, especially without modifier, but they haven't tested, yet.
* char, varchar, character, and character varying (with and without modifiers, such as varchar and varchar(250))
* text
* smallint, integer, bigint
* bit, bit varying (with or without modifier)
* boolean
* bytea
* cidr
* date
* timestamp with time zone, timestamp without time zone (with and without modifier)
* time with time zone, time without time zone (with or without modifiers)
* interval (without modifier)
* json, jsonb
* numeric (with and without modifiers)

## Caveats
* To be able to run a ALTER TABLE command againt a table, a role has to be owner of the object or has SUPERUSER privilege. logical_ddl works under SUPERUSER privileges.
* Replicating of *INTERVAL* data type with modifiers hasn't been implemented.
* Geometric data types and PostGIS haven't been tested, yet.
* Replication of *array datatypes*, *rangetypes*, *composite data types* and user defined data types haven't been implemented, yet.
* *USING* expression of data type changes hasn't been implemented, yet.
* Arrays!!! varchar(50)[] -> varchar(50)
* interval with modifier interval hour -> interval(6)
* replicating default values !!!
* Extension is still under development. There can be changes near future which can be incompatiple with the current version.

## Installition
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
1. publish (boolean) **:** controls role of source, one or zero row can exists with true value.
1. source (varchar(64)) **:** source name, it has to be longer than 2 characters.

Extension can be configured as subsriber, publisher or both. Role of extension is controlled over records in logical_ddl.settings table.
* If there is a record with 'true' on publish column, extension starts capturing and publishing DDLs.
* If there is a record with 'false' on publish column, extension starts listening incoming DDLs from sources defined in source column.

### logical_ddl.publish_tablelist
Table has three columns.
1. id (int) **:** Primary key attribute
1. relid (oid) **:** Object ID of source table
1. cmd_list (text[]) **:** Command list of being captured, default value is '{}'::text[]

This table manages the tables whose DDL changes are captured and replicated. Which changes should be published by extension can be defined on table level over cmd_list column of publish_tablelist table. cmd_list columns is a text array. Currently valid values are;
* '{}'::text[] **:** Empty array, captures and publish all changes. This is default behaviour.
* "alter table.rename table" **:** captures *ALTER TABLE .. RENAME TO ..*
* "alter table.rename column" **:** Captures *ALTER TABLE .. RENAME COLUMN .. TO ..*
* "alter table.add column" **:** captures *ALTER TABLE .. ADD COLUMN .. ..*
* "alter table.drop column" **:** captures *ALTER TABLE .. DROP COLUMN ..*
* "alter table.alter column type" **:** captures *ALTER TABLE .. ALTER COLUMN .. TYPE ..*

### logical_ddl.subscribe_tablelist
1. id (int) **:** Primary key attribute
1. source (varchar(64)) **:** source name of DDLs
1. relid (oid) **:** Object ID of target table
1. cmd_list (text[]) **:** Command list of being replayed, default value is '{}'::text[]

Valid values of cmd_list is the same with publish_tablelist's cmd_list column.

## Monitoring
### logical_ddl.shadow_table
shadow_table is the table that captured changes are stored in. The table has five columns.
1. id (int) **:** identitiy number, unique for each source 
1. source (varchar(64)) **:** source name of DDLs
1. schema_name (varchar(64)) **:** schema name of table
1. command (json) **:** details of DDL command
1. date (timestamp) **:** when changes is captured

### logical_ddl.applied_commands
1. id (int) **:** identitiy number, unique for each source 
1. source (varchar(64)) **:** source name of DDLs
1. command_string (text) **:** generated DDL query on subscriber side
1. command_id (int) **:** id number of received command in shadow_table.
1. applied_date (timestamp) **:** when the command is run
1. is_failed (boolean) **:** is execution of generated DDL command failed?

## Simple Configuration
All commands are run by a role with SUPERUSER privilege.
### Publisher side
1. Create extension
    `CREATE EXTENSION logical_ddl;`
1. Give a name to your publication
    `INSERT INTO logical_ddl.settings (true, 'source1');`
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
    `INSERT INTO logical_ddl.settings (false, 'source1');`
1. Add target tables for DDL operations
    `INSERT INTO logical_ddl.subscribe_tablelist (source,relid) VALUES ('source1','table1'::regclass);`
    If you want to add all tables in logical replication, you can use following query.
    `INSERT INTO logical_ddl.subscribe_tablelist (source,relid) SELECT 'source1',srrelid FROM pg_catalog.pg_subscription_rel;`
1. Refresh publication
    `ALTER SUBSCRIPTION log_sub_1 REFRESH PUBLICATION;`
