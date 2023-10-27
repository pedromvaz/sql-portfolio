
-- LOAD TABLES

drop table if exists load_airlines;

create table load_airlines
(
    id          integer not null,
    name        varchar(100) null,
    alias       varchar(100) null,
    iata_code   char(3) null,
    icao_code   char(4) null,
    callsign    varchar(50) null,
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

-- FINAL TABLES

drop table if exists routes;
drop table if exists airlines;
drop table if exists airports;
drop table if exists cities;
drop table if exists countries;
drop table if exists planes;

drop sequence if exists routes_seq;
drop sequence if exists airlines_seq;
drop sequence if exists airports_seq;
drop sequence if exists cities_seq;
drop sequence if exists countries_seq;
drop sequence if exists planes_seq;


create sequence if not exists countries_seq;

create table countries
(
    id              integer         not null    primary key default nextval('countries_seq'),
    name            varchar(100)    not null,
    iso_code        char(2)         null,
    dafif_code      char(2)         null
);


create sequence if not exists cities_seq;

create table cities
(
    id              integer         not null    primary key default nextval('cities_seq'),
    name            varchar(100)    not null,
    country_id      integer         not null,
    constraint country_FK foreign key (country_id) references countries(id)
);


create sequence if not exists airports_seq;

create table airports
(
    id              integer         not null    primary key default nextval('airports_seq'),
    name            varchar(100)    not null,
    city_id         integer         null,
    country_id      integer         not null,
    iata_code       char(3)         null,
    icao_code       char(4)         null,
    altitude        integer         not null,
    constraint city_FK foreign key (city_id) references cities(id),
    constraint country_FK foreign key (country_id) references countries(id)
);


create sequence if not exists airlines_seq;

create table airlines
(
    id              integer         not null    primary key default nextval('airlines_seq'),
    name            varchar(100)    not null,
    iata_code       char(2)         null,
    icao_code       char(3)         null,
    active          boolean         null,
    country_id      integer         null,
    constraint country_FK foreign key (country_id) references countries(id)
);


create sequence if not exists planes_seq;

create table planes
(
    id              integer         not null    primary key default nextval('planes_seq'),
    name            varchar(100)    not null,
    iata_code       char(3)         null,
    icao_code       char(4)         null
);


create sequence if not exists routes_seq;

create table routes
(
    id                      integer         not null    primary key default nextval('routes_seq'),
    airline_id              integer         null,
    source_airport_id       integer         null,
    destination_airport_id  integer         null,
    stops                   integer         not null,
    constraint different_airports check (destination_airport_id != source_airport_id),
    constraint airline_FK foreign key (airline_id) references airlines(id),
    constraint source_airport_FK foreign key (source_airport_id) references airports(id),
    constraint destination_airport_FK foreign key (destination_airport_id) references airports(id)
);
