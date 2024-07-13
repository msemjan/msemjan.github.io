---
title: "Sql Migrations With Goose"
date: "2024-07-13T15:45:24+02:00"
author: "Marek Semjan"
draft: false
summary: "Goose is a database migration tool that will help you manage your database schemas"
toc: false
images:
tags:
  - SQL
  - Migrations
  - Goose
  - Go
  - Golang
---
## What Is Goose?

[Goose](https://pressly.github.io/goose/) is a database migration tool that will help you manage your database schemas. In this blog post I will teach you the basics of this useful tool.

## Installation

If you have Go installed, you can use `go install` command to install Goose:
```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
```

Then you can verify that the tool was installed correctly by running:
```bash
goose -h
```

## Initialization Of Goose

First, let's create initialize the database. We will do so by running the following command:

```bash
goose DRIVER DBSTRING create init sql
```

Don't run it yet. First, you will need to replace `DRIVER` with one of the supported drivers: `clickhouse`, `mssql`, `mysql`, `postgres`, `sqlite3`, `turso`, `vertica`, and `ydb`. Secondly, you need a `DBSTRING` (the database connection string), which will differ depending on the specific database. Here is a non-exhaustive list of examples:

| Database        | Corresponding `init` command                                                                     |
|-----------------|--------------------------------------------------------------------------------------------------|
| PostgreSQL      | `goose postgres "user=postgres password=postgres dbname=postgres sslmode=disable" init`          |
| MySQL           | `goose mysql "user:password@/dbname?parseTime=true" init`                                        |
| Amazon Redshift | `goose redshift "postgres://user:password@qwerty.us-east-1.redshift.amazonaws.com:5439/db" init` |
| TiDB            | `goose tidb "user:password@/dbname?parseTime=true" init`                                         |
| MS SQL          | `goose mssql "sqlserver://user:password@dbname:1433?database=master" init`                       |
| ClickHouse      | `goose clickhouse "tcp://127.0.0.1:9000" init`                                                   |
| Vertica         | `goose vertica "vertica://user:password@localhost:5433/dbname?connection_load_balance=1" init`   |

For simplicity, I will use Sqlite3 from now on. The database can be initiated with the following command:

```bash
goose sqlite3 ./database.db create init sql
```

## Goose Annotations And Writing First Migration

Let's create the first migration. There is a useful `goose create` command to create template for a migration file in a consistent way:
```bash
goose sqlite3 ./database.db create first sql
```

This will create a file in the current working directory (the `first` will be prefixed by a timestamp). Every migration is a SQL file (with `.sql` extension). Alternatively, we can omit the trailing `sql` in the command and we will get a template file for our migration in Go programming language. However, more developers know SQL than Go, so we will stick to it.

The file names of the migrations should start with a timestamp or a sequential number. When you open the file in your favorite editor, you should see:

```sql
-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
-- +goose StatementEnd
```

Goose uses several annotations. At the time of writing, there were seven annotations:

```sql
-- +goose up
-- +goose down
-- +goose statementbegin
-- +goose statementend
-- +goose no transaction
-- +goose envsub on
-- +goose envsub off
```

The annotations are case insensitive, they should be placed on their own line with no leading whitespace, and when writing migrations, don't forget to include the `-- +goose` prefix. Only the `-- +goose up` is mandatory. Each SQL statement should be terminated by semicolon (`;`), otherwise they will not be properly recognized by Goose.

More complex statements that contain semicolons must be wrapped within the `-- +goose statementbegin` and `-- +goose statementend` block. This pair of annotations will tell Goose to treat them as a larger unit instead of several separate statements. Comments, empty lines, and semicolons within such block will be preserved.

Moreover, the `-- +goose statementbegin` and `-- +goose statementend` annotations can be used to send multiple statements as a single query instead of executing them individually. This can be useful e.g. when we are populating a table with test data using a large number of `INSERT` SQL statements. The use of these annotations also has performance implications, since inserting multiple rows in the same transaction is much faster than executing queries on one-by-one basis.

However, let's return for a while to our first migration. It is common to create tables at the beginning of programming projects. In the example below, I wrote an example of creating a `users` table. Notice that in `-- +goose Down` part I have a `DROP TABLE` command. It is optional, only `-- +goose up` is necessary, but it may help when you need to revert the changes.

```sql
-- +goose Up
-- +goose StatementBegin
CREATE TABLE users (
  id         INT NOT NULL,
  first_name VARCHAR(255),
  last_name  VARCHAR(255),
  email      VARCHAR(255)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE users;
-- +goose StatementEnd
```

The change still was not applied, and we can check the state of the database with:

```bash
goose sqlite3 ./database.db status
```

The output may potentially look like this:

```
2024/07/12 18:32:41     Applied At                  Migration
2024/07/12 18:32:41     =======================================
2024/07/12 18:32:41     Pending      -- 20240710181543_init.sql
```

To apply pending migrations we can use use the command:

```bash
goose sqlite3 ./database.db up
```

The output of the command should look something like this:

```
2024/07/12 18:32:41     Applied At                  Migration
2024/07/12 18:32:41     =======================================
2024/07/12 18:32:41     Fri Jul 12 16:44:03 2024 -- 20240710181543_init.sql
```

When the requirements change and new changes need to be done, we can create new migrations (preferably with the `goose sqlite3 ./database.db create descriptive_name_of_migration sql` command), and then rerun `goose sqlite3 ./database.db up` to apply it. In case there is any issue and we've implemented the `-- +goose down`, we can revert the latest migration with:

```bash
goose sqlite3 ./database.db down
```

## Other Goose Commands

Besides the `create`, `up`, `down`, and `status` commands there are a few more that might be useful

| Command           | Usage                                      |
|-------------------|--------------------------------------------|
| `up-by-one`       | Migrate the DB up by 1                     |
| `up-to VERSION`   | Migrate the DB to a specific VERSION       |
| `down-to VERSION` | Roll back to a specific VERSION            |
| `redo`            | Re-run the latest migration                |
| `reset`           | Roll back all migrations                   |
| `version`         | Print the current version of the database  |
| `fix`             | Apply sequential ordering to migrations    |
| `validate`        | Check migration files without running them |

## No Transactions

Goose runs all the statements in a migration file within a single transaction. However, this will not work for some statements, e.g. `CREATE DATABASE` or `CREATE INDEX CURRENTLY` that can not be run inside a transaction. In such cases we can add `-- +goose no transaction` annotation to the top of the file, and Goose will run all statements within the marked file outside a transaction.

## Substitution Of Environment Variables

In case we don't know some value at the time of writing of a migration, we can use the environment variable substitution feature of Goose. The substitution is disabled by default, and can be enabled by including the `-- +goose envsub on` annotation. If we need to use the substitution only in a small subsection of the file, we can disable it again with `-- +goose envsub off`, otherwise Goose will attempt to substitute environment variable until the end of the file.

Supported expansions use [mfridman/interpolate](https://github.com/mfridman/interpolate?tab=readme-ov-file#supported-expansions) package:
- `${parameter}` or `$parameter` - Uses the value if the `parameter` is set, otherwise it will be left blank
- `${parameter:-[word]}` - If the `parameter` is unset or null, the expansion of the `word` will be substituted
- `${parameter-[word]` - If the parameter is unset, the expansion of the `word` is used
- `${parameter:[offset]}` - Use the substring of the `parameter` after the `offset`
- `${parameter:[offset]:[length]}` - Use the substring of the `parameter` after the `offset` of the given `length`
- `${parameter?[word]}` - Indicate error if null
- `${parameter:?[word]}` - Indicate error if null or unset

Example of an environment variable substitution is:

```sql
-- +goose envsub on

-- +goose up
SELECT * FROM regions WHERE name = '${REGION}';
```

## Conclusions

Hopefully, I've shown in this blog post that Goose is a useful tool that will help you write your migrations in an organized fashion instead of executing random SQL statements ad hoc. Such approach is hard to reproduce and possibly erroneous. Moreover, when you systematically save the SQL files into the same directory and put it into your version control system, you can easily reproduce, rollout, or revert the changes.

I also see a potential in running automated tests that first create a SQL tables and populate the database with expected data. If SQLite3 is used, it is also easy to clean up, since the  entire database is stored in a single file. Alternatively, Goose could be used to easily create development environment that has the same (or very similar) setup as the production database.
