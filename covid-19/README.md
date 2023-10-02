# Covid-19

This project was created in MySql, and is based on the dataset [Data on the daily number of new reported COVID-19 cases and deaths by EU/EEA country](https://www.ecdc.europa.eu/en/publications-data/data-daily-new-cases-covid-19-eueea-country) provided by the **ECDC**.

## Installing MySql

Following the instructions on [dev.mysql.com](https://dev.mysql.com/doc/refman/5.7/en/windows-installation.html#windows-installation-simple), I
1. downloaded the MySql installer for Windows
2. used all the default options in the Setup Wizard
3. chose a master password, and then a username and its password, for the database
4. opened the MySQL 8.0 Command Line Client and entered the master password, to ensure it was working

## Creating the database

By following the Setup Wizard and its default options, a database server is created automatically, and it runs as a service every time Windows starts.

When we open the MySQL 8.0 Command Line Client, we can run the `show databases` command to find that there are, in fact, some databases already created during the installation.

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

We can then create our own database for Covid-19 related data, with the `create database` command:

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

I created an SQL file called [daily_covid_stats.sql](./daily_covid_stats.sql) to create all the required tables for this project.

This will allow me to import the CSV file into the `load_covid_stats` table, and then apply some normalization to the data, in the remaining tables.

I copy-pasted the file's contents into the Command Line Client, which in turn created all the tables from the SQL file inside the database.

## Importing the CSV files

## Querying the data
