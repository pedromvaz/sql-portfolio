
drop table if exists load_airlines;

create table load_airlines
(
    id          integer not null,
    name        varchar(100) null,
    alias       varchar(100) null,
    iata_code   char(3) null,
    icao_code   char(4) null,
    callsign    varchar(20) null,
    country     varchar(100) null,
    active      char(1) null,
    constraint load_airlines_PK primary key (id)
);

drop table if exists load_airports;

create table load_airports
(
    id                      integer not null,
    name                    varchar(100) null,
    city                    varchar(100) null,
    country                 varchar(100) null,
    iata_code               char(4) null,
    icao_code               char(5) null,
    latitude                varchar(30) null,
    longitude               varchar(30) null,
    altitude                integer null,
    timezone                numeric(6,3) null,
    dst                     char(1) null,
    tz_database_time_zone   varchar(30) null,
    type                    varchar(10) null,
    source                  varchar(20) null,
    constraint load_airports_PK primary key (id)
);

drop table if exists load_countries;

create table load_countries
(
    name        varchar(100) null,
    iso_code    char(3) null,
    dafif_code  char(3) null
);

drop table if exists load_planes;

create table load_planes
(
    name        varchar(100) null,
    iata_code   char(4) null,
    icao_code   char(5) null
);

drop table if exists load_routes;

create table load_routes
(
    airline                 char(3) not null,
    airline_id              integer null,
    source_airport          char(4) not null,
    source_airport_id       integer null,
    destination_airport     char(4) not null,
    destination_airport_id  integer null,
    codeshare               char(1) null,
    stops                   smallint null,
    equipment               varchar(50) null,
    constraint load_routes_PK primary key (airline, source_airport, destination_airport)
);
