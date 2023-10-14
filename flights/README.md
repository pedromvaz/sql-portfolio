# Flights

This project was created in PostgreSQL, and is based on the datasets provided by [OpenFlights](https://openflights.org/data).

## Installing PostgreSQL

Follow these instructions:
1. On the [PostgreSQL website](https://www.postgresql.org/download/), choose the Operating System you are working on, and then the version of PostgreSQL that makes sense for your OS version/distribution
2. Download the installer
3. Follow the installation wizard, and choose the default options
4. Choose a password for the database superuser
5. If/When installing Stack Builder, choose the "PostgreSQL ..." option on the first screen, and then choose the psqlODBC database drivers (32 bit and 64 bit)  


## Creating the database


## Creating the tables


## Importing the CSV file

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
