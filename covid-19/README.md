# Covid-19

This project was created in MySql, and is based on the dataset [COVID-19 Data Explorer](https://ourworldindata.org/the-coronavirus-pandemic-data-explorer) provided by [Our World In Data](https://ourworldindata.org/).

At the time of writing this README file, the dataset is almost 90MB in size, so I will not be putting it in my repository. You can download it [here](https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv).

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

On the server, once you connect to the database, run the following commands:

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
mysql> use covid;
Database changed
mysql> LOAD DATA LOCAL INFILE 'C:/Users/Pedro/PycharmProjects/sql-portfolio/covid-19/data/covid_stats.csv'
    -> INTO TABLE load_covid_stats
    -> FIELDS TERMINATED BY ','
    -> LINES TERMINATED BY '\n'
    -> IGNORE 1 ROWS;
Query OK, 28729 rows affected, 385 warnings (1.14 sec)
Records: 28729  Deleted: 0  Skipped: 0  Warnings: 385
```

There are several warnings in the output of the previous command, but all the lines from the CSV file should now be in the table (except for the header line):

```
mysql> select count(*) from load_covid_stats;
+----------+
| count(*) |
+----------+
|    28729 |
+----------+
1 row in set (0.01 sec)
```

## Querying the data
