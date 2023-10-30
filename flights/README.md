# Flights

This project was created in PostgreSQL, and is based on the datasets
provided by [OpenFlights](https://openflights.org/data).

## Installing PostgreSQL

Follow these instructions:
1. On the [PostgreSQL website](https://www.postgresql.org/download/), choose the 
   Operating System you are working on, and then the version of PostgreSQL
   that makes sense for your OS version/distribution
2. Download the installer
3. Follow the installation wizard, and choose the default options
4. Choose a password for the database superuser
5. Do not run the Stack Builder at the end of the installation  

## Creating the database

When the PostgreSQL installation finishes, open the pgAdmin application.

By following the Setup Wizard and its default options, a database server
should have been created automatically.

In pgAdmin, connect to the database server listed on the left side, inputting
the password you chose during the installation.

The connection should be successful. You should see a single database there,
called "postgres", an inside it there should be a single schema called "public",
with nothing in it.

## Creating the tables

You will be creating the tables related to the Flights datasets inside
the "public" schema you saw earlier.

There is an SQL file called [flights_tables.sql](./flights_tables.sql) to create
all the required tables for this project.

This will allow you to import the CSV files into the `load` tables, and then apply
some normalization to the data, in the remaining tables.

The contents of the SQL file can be run directly in pgAdmin, by selecting
the `public` schema, and opening the SQL Editor via the
"Execute arbitrary SQL queries." toolbar button.

## Importing the CSV files

The datasets from OpenFlights are available in .dat files, although their
contents are that of .csv files. There are empty values and `\N` values,
and there are some values surrounded by quotes, but not all of them.

I decided to do the following changes, so the datasets are easier to import
into a database:
- change their extension from .dat to .csv
- open them in Excel, and
  - use the "Text to Columns" functionality, indicate that the fields are
    delimited by commas, and set the double quotes as the text qualifier
  - remove all the `\N` and `-` and `N/A` values; this way, they will be
    considered as `NULL` in the database, together with the already empty values
  - add a header row with the names of all the columns in each dataset,
    based on the information in the [OpenFlights website](https://openflights.org/data)
  - remove any rows with `id = -1`
  - on the countries' dataset, I had to adjust 2 names that contained commas,
    and Excel didn't handle that properly
  - replace the sequence `\\'` with simply `'`

In order to import each CSV file into its respective `load` table:
1. Open pgAdmin
2. Connect to the PostgreSQL server
3. Find the `public` schema inside the `postgres` database
4. Find the `load` table for the CSV file you want to import
5. Right-click on the table, and click on the "Import..." option in the menu
6. On the File Options tab, select the file you want to import, change
   the format to "csv", and the encoding to "UTF8"
7. On the Misc. Options tab, select the Header checkbox, and set the delimiter
   to the semicolon (;)
8. Click on the "Import" button, and it should be successful

To confirm the successful import of the data, right-click on the table, hover
over the "View Data" option in the menu, and then choose one of the sub-options.
You should see some, or all, of the data in a new window.

## Data checks

After importing the data, I started looking at the data, and found a lot
of empty values. When I started looking at the empty values in detail,
I started finding duplicate data.

I decided to create some queries for each dataset, to make some detailed checks
on the data. The files I created are:
- [airlines_data_checks.sql](./airlines_data_checks.sql)
- [airports_data_checks.sql](./airports_data_checks.sql)
- [countries_data_checks.sql](./countries_data_checks.sql)
- [planes_data_checks.sql](./planes_data_checks.sql)
- [routes_data_checks.sql](./routes_data_checks.sql)

In short, here are some alerts that will cause the results from my queries
to be less than ideal:
- Airlines
  - 70 repeated names (6 for active airlines)
  - 320 repeated IATA codes (19 for active airlines -- this should not be allowed!)
  - 4628 empty IATA codes (241 for active airlines)
- Airports
  - 36 repeated names (6 of which belong to the same city and country)
  - 1626 empty IATA codes
- Planes
  - 6 repeated IATA codes (different plane models from the same company,
    still think this should not be allowed!)
  - 12 empty IATA codes

## Data normalization

In order to reorganize the data in the load tables, to remove any unstructured
or redundant data, I created a file called
[flights_data_insertion.sql](./flights_data_insertion.sql).
It contains a series of INSERT statements that populates all the "final" tables
with normalized data.

## Querying the data

Having all the data inserted correctly in tables `airlines`, `airports`,
`countries`, `cities`, `planes`, `routes` and `routes_planes`, I created
a new SQL file called [flights_queries.sql](./flights_queries.sql),
where I use various SQL elements like `inner join`, `left outer join`,
`order by`, `group by`, `having`, CTEs, `limit`, aggregate functions, loops,
`partition by`, `except`, temporary tables, string concatenation, and sub-queries.

Open a database connection in the pgAdmin client.

Open the SQL file in a text editor, copy one of the queries in it,
paste it into the pgAdmin Query window, and run it, like so:

```
select
    co.name as country,
    count(*) as total_airports
from airports a
inner join countries co
    on co.id = a.country_id
group by
    co.name
having count(*) > 1
order by count(*) desc
limit 5;
```

And the results will be:

```
country;total_airports
"United States";1512
"Canada";430
"Australia";334
"Brazil";264
"Russia";264
```
