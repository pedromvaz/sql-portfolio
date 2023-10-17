# Flights

This project was created in PostgreSQL, and is based on the datasets provided by [OpenFlights](https://openflights.org/data).

## Installing PostgreSQL

Follow these instructions:
1. On the [PostgreSQL website](https://www.postgresql.org/download/), choose the Operating System you are working on, and then the version of PostgreSQL that makes sense for your OS version/distribution
2. Download the installer
3. Follow the installation wizard, and choose the default options
4. Choose a password for the database superuser
5. Do not run the Stack Builder at the end of the installation  

## Creating the database

When the PostgreSQL installation finishes, open the pgAdmin application.

By following the Setup Wizard and its default options, a database server should have been created automatically.

In pgAdmin, connect to the database server listed on the left side, inputting the password you chose during the installation.

The connection should be successful. You should see a single database there, called "postgres", an inside it there should be a single schema called "public", with nothing in it.

## Creating the tables

You will be creating the tables related to the Flights datasets inside the "public" schema you saw earlier.

There is an SQL file called [flights_tables.sql](./flights_tables.sql) to create all the required tables for this project.

This will allow you to import the CSV files into the `load` tables, and then apply some normalization to the data, in the remaining tables.

The contents of the SQL file can be run directly in pgAdmin, by selecting the `public` schema, and opening the SQL Editor via the "Execute arbitrary SQL queries." tool bar button.

## Importing the CSV files

The datasets from OpenFlights are available in .dat files, although their contents are that of .csv files. There are empty values and `\N` values, and there are some values surrounded by quotes, but not all of them.

I decided to do the following changes, so the datasets are easier to import into a database:
- change their extension from .dat to .csv
- open them in Excel, and
  - use the "Text to Columns" functionality, indicate that the fields are delimited by commas, and set the double quotes as the text qualifier
  - remove all the `\N` and `-` and `N/A` values; this way, they will be considered as `NULL` in the database, together with the already empty values
  - add a header row with the names of all the columns in each dataset, based on the information in the [OpenFlights website](https://openflights.org/data)
  - remove any rows with `id = -1`
  - on the countries' dataset, I had to adjust 2 names that contained commas, and Excel didn't handle that properly

## Querying the data
