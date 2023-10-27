# Covid-19

This project was created in MySql, and is based on the dataset [COVID-19 Data Explorer](https://ourworldindata.org/the-coronavirus-pandemic-data-explorer) provided by [Our World In Data](https://ourworldindata.org/).

At the time of writing this README file, the dataset is almost 90MB in size, so I will not be putting it in my repository. You can download it [here](https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv), then copy the CSV file to the `data` folder.

## Installing MySql

Follow the instructions on [dev.mysql.com](https://dev.mysql.com/doc/refman/5.7/en/windows-installation.html#windows-installation-simple):
1. Download the MySql installer for Windows
2. Use all the default options in the Setup Wizard
3. Choose a password for the `root` user
4. Create your own username and give it a password
5. Open the MySQL 8.0 Command Line Client and enter the root password, to ensure everything is set up properly

## Creating the database

By following the Setup Wizard and its default options, a database server is created automatically, and it runs as a service every time Windows starts.

Follow the instructions on [dev.mysql.com](https://dev.mysql.com/doc/mysql-getting-started/en/):
- Open the MySQL 8.0 Command Line Client
- Run the `show databases` command. You will find that there are some databases already created.

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sakila             |
| sys                |
| world              |
+--------------------+
6 rows in set (0.01 sec)
```

- Create your own database for Covid-19 related data, with the `create database` command:

```
mysql> create database covid;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| covid              |
| information_schema |
| mysql              |
| performance_schema |
| sakila             |
| sys                |
| world              |
+--------------------+
7 rows in set (0.00 sec)
```

## Creating the tables

There is an SQL file called [daily_covid_stats.sql](./daily_covid_stats.sql) to create all the required tables for this project.

This will allow you to import the CSV file into the `load_covid_stats` table, and then apply some normalization to the data, in the remaining tables.

Copy & paste the file's contents into the Command Line Client, which in turn will create all the tables from the SQL file inside the database.

## Importing the CSV file

To import the CSV file, and assuming you're using MySQL 8, you need to change 2 configurations (found this on [stackoverflow](https://stackoverflow.com/questions/63361962/error-2068-hy000-load-data-local-infile-file-request-rejected-due-to-restrict)):
- One on the server
- Another on the client

On the client, once you connect to the database, run the following commands:

```
SET GLOBAL local_infile = true;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
```

Here is the expected output:

```
mysql> SET GLOBAL local_infile = true;
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW GLOBAL VARIABLES LIKE 'local_infile';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| local_infile  | ON    |
+---------------+-------+
1 row in set (0.00 sec)
```

On the client, you need to add a parameter to the command used to start the MySQL 8.0 Command Line Client:

```
OLD
---
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" "--defaults-file=C:\ProgramData\MySQL\MySQL Server 8.0\my.ini" "-uroot" "-p"

NEW
---
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" "--defaults-file=C:\ProgramData\MySQL\MySQL Server 8.0\my.ini" "--local-infile=1" "-uroot" "-p"
```

Then, you can run the following commands inside the client (found this on [n8n](https://blog.n8n.io/import-csv-into-mysql/)):

```
USE covid;

LOAD DATA LOCAL INFILE 'C:/Users/Pedro/PycharmProjects/sql-portfolio/covid-19/data/owid-covid-data.csv'
INTO TABLE load_covid_stats
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

Here is the expected output:

```
mysql> USE covid;
Database changed
mysql> LOAD DATA LOCAL INFILE 'C:/Users/Pedro/PycharmProjects/sql-portfolio/covid-19/data/owid-covid-data.csv'
    -> INTO TABLE load_covid_stats
    -> FIELDS TERMINATED BY ','
    -> LINES TERMINATED BY '\n'
    -> IGNORE 1 ROWS;
Query OK, 346549 rows affected, 65535 warnings (30.87 sec)
Records: 346549  Deleted: 0  Skipped: 0  Warnings: 10375871
```

There is a huge number of warnings in the output of the previous command, probably due to all the missing values in the CSV file, but all the lines from the CSV file should now be in the table (except for the header line):

```
mysql> select count(*) from load_covid_stats;
+----------+
| count(*) |
+----------+
|   346549 |
+----------+
1 row in set (1.84 sec)
```

Finally, you need to run the SQL INSERT statements inside the file [normalize_covid_data.sql](./normalize_covid_data.sql), so that the data is normalized and populated into the "final" tables.

## Querying the data

Having all the data inserted correctly in tables `continent`, `location`, and `daily_covid_stats`, I created a new SQL file called [covid_queries.sql](./covid_queries.sql), where I use various SQL elements like `inner join`, `order by`, `group by`, `having`, CTEs, and aggregate functions.

Open a database connection in the MySQL client.

Open the SQL file in a text editor, copy one of the queries in it, paste it into the MySQL client, and run it, like so:

```
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.34 MySQL Community Server - GPL

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use covid;
Database changed
mysql> select
    ->     l.name as location,
    ->     c.new_deaths,
    ->     c.on_date
    -> from daily_covid_stats c
    -> inner join location l
    ->     on c.location_id = l.id
    ->     and l.continent_id is not null
    -> order by new_deaths desc
    -> limit 5;
+----------+------------+------------+
| location | new_deaths | on_date    |
+----------+------------+------------+
| Chile    |  11447.000 | 2022-03-22 |
| Ecuador  |   8786.000 | 2021-07-21 |
| Germany  |   6460.000 | 2020-12-20 |
| India    |   6148.000 | 2021-06-10 |
| Spain    |   5841.000 | 2020-04-05 |
+----------+------------+------------+
5 rows in set (0.56 sec)
```
