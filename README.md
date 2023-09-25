# sql-portfolio
A portfolio of SQL queries over multiple data-sets, to be shown for Data Analytics positions

## World Happiness Report
This project was created in sqlite, and is based on the dataset [World Happiness Report up to 2023](https://www.kaggle.com/datasets/sazidthe1/global-happiness-scores-and-factors) provided by **kaggle**.

### Installing SQLite3
Following the rules on [tutorialspoint](https://www.tutorialspoint.com/sqlite/sqlite_installation.htm), I
1. downloaded the SQLite precompiled binaries (dll and tools) from the [SQLite download page](https://www.sqlite.org/download.html)
1. unzipped them into folder C:\sqlite
1. added this folder to the PATH environment variable
1. opened the command line and ran **sqlite3** to ensure it was working

### Creating the database file
Following the rules on [tutorialspoint](https://www.tutorialspoint.com/sqlite/sqlite_create_database.htm) again, I ran the following commands on the command line:

```
cd C:\sqlite
sqlite3 WorldHappiness.db
```

### Creating the tables
I created an SQL file called **load_whr.sql**, with the following contents:

```
drop table if exists load_whr;

create table load_whr
(
    country                         varchar(100)    not null,
    region                          varchar(100)    not null,
    happiness_score                 real            not null,
    gdp_per_capita                  real            not null,
    social_support                  real            not null,
    healthy_life_expectancy         real            not null,
    freedom_to_make_life_choices    real            not null,
    generosity                      real            not null,
    perceptions_of_corruption       real            not null,
    constraint load_whr_PK primary key (country)
);
```

This will allow me to import the CSV files one by one, and then apply some normalization to the data, while inserting it into "final tables" (as opposed to "load tables").

### Importing the CSV files
To import a CSV file, I had to copy the WHR files to folder C:\sqlite\whr, and then run the following commands in SQLite:

```
.mode csv
.import C:\\sqlite\\whr\\WHR_2015.csv load_whr
select count(*) from load_whr;
delete from load_whr where country = 'country';
select count(*) from load_whr;
```

The SELECT statements proved that the data was loaded correctly (159 rows of data).
The DELETE statement removed the header row from the CSV file, which would be used in case the table didn't exist prior to the import.
