# World Happiness Report

This project was created in sqlite, and is based on the dataset [World Happiness Report up to 2023](https://www.kaggle.com/datasets/sazidthe1/global-happiness-scores-and-factors) provided by **kaggle**.

## Installing SQLite3

Following the instructions on [tutorialspoint](https://www.tutorialspoint.com/sqlite/sqlite_installation.htm), I
1. downloaded the SQLite precompiled binaries (dll and tools) from the [SQLite download page](https://www.sqlite.org/download.html)
2. unzipped them into folder `C:\sqlite`
3. added this folder to the `PATH` environment variable
4. opened the command line and ran `sqlite3` to ensure it was working

## Creating the database file

Following the instructions on [tutorialspoint](https://www.tutorialspoint.com/sqlite/sqlite_create_database.htm) again, I ran the following commands on the command line:

```
cd .\world_happiness
sqlite3 WorldHappiness.db
```

## Creating the tables

I created an SQL file called [world_happiness.sql](./world_happiness.sql) to create all the required tables for this project.

This will allow me to import the CSV files one by one, in the `load_whr` table, and then apply some normalization to the data, in the remaining tables.

Following the instructions on [tutorialspoint](https://www.tutorialspoint.com/sqlite/sqlite_create_database.htm), I ran the following command on the command line:

```
sqlite3 WorldHappiness.db < world_happiness.sql
```

This created all the tables from the SQL file inside the database.

## Importing the CSV files

Following the instructions on [sqlitetutorial](https://www.sqlitetutorial.net/sqlite-import-csv/), in order to import a CSV file, I had to copy the [WHR files](https://www.kaggle.com/datasets/sazidthe1/global-happiness-scores-and-factors/download?datasetVersionNumber=1) to folder `.\world_happiness\data`, and then run the following commands in SQLite:

```
delete from load_whr;
.mode csv
.import .\\data\\WHR_2015.csv load_whr
delete from load_whr where country = 'country';
select count(*) from load_whr;
.quit
```

The `delete` statement removes the header row from the CSV file, which would be used in case the table didn't exist prior to the `.import`.

The `select` statement proves that the data was loaded correctly (158 rows of data).

Finally, I ran the following command, which executes 3 `insert` statements inside an SQL file called [normalize_happiness_data.sql](./normalize_happiness_data.sql).
These `insert` statements normalize the data present in table `load_whr` at the time:

```
sqlite3 WorldHappiness.db < normalize_happiness_data.sql
```

A few notes on the SQL file:
- We need to update the year in the last `insert` (e.g. 2015), depending on the file we're loading (e.g. `WHR_2015.csv`)
- The `insert` statements only add new data to each table, based on their `primary key`, so no errors should occur in case we import the same file more than once

After going through the various WHR files, I found out that the ones related to 2017 and 2018 had a duplicate line for Cyprus, which I had to remove manually before successfully loading the data into the table.

## Querying the data

Having all the data inserted correctly in tables `region`, `country`, and `world_happiness`, I created a new SQL file called [world_happiness_queries.sql](./world_happiness_queries.sql), where I use various SQL elements like `inner join`, `order by`, `group by`, `cast`, `round`, and aggregate functions.

The way I did this was to first open a database connection, as before:

```
cd .\world_happiness
sqlite3 WorldHappiness.db
```

Then I opened the SQL file in a text editor, copied one of the queries in it, and ran it in SQLite, like so:

```
SQLite version 3.43.1 2023-09-11 12:01:27
Enter ".help" for usage hints.
sqlite> .headers on
sqlite> .mode columns
sqlite> select
   ...>     'Highest happiness',
   ...>     c.name,
   ...>     h.happiness_score,
   ...>     h.year
   ...> from world_happiness h
   ...> inner join country c
   ...>     on h.country_id = c.id
   ...> order by h.happiness_score desc
   ...> limit 1;
'Highest happiness'  name     happiness_score  year
-------------------  -------  ---------------  ----
Highest happiness    Finland  7.842            2021
```

The commands `.headers on` and `.mode columns` help visualize the data by showing the column names, and aligning the data in their respective columns.
