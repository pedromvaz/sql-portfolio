
use covid;

drop table if exists load_covid_stats;

create table load_covid_stats
(
    the_date                            date            not null,
    the_day                             integer         not null,
    the_month                           integer         not null,
    the_year                            integer         not null,
    cases                               integer         not null,
    deaths                              integer         not null,
    country_or_territory_description    varchar(100)    not null,
    geo_id                              char(2)         not null,
    country_or_territory_code           char(3)         not null,
    population_from_2020                integer         not null,
    continent                           varchar(10)     not null,
    constraint load_covid_stats_PK primary key (the_date, country_or_territory_code)
);



drop table if exists continent;

create table continent
(
    id          integer         primary key,
    name        varchar(100)    not null
);



drop table if exists country;

create table country
(
    id              integer         primary key,
    geo_id          char(2)         not null,
    code            char(3)         not null,
    name            varchar(100)    not null,
    continent_id    integer         not null,
    constraint continent_FK foreign key (continent_id) references continent(id)
);



drop table if exists daily_covid_stats;

create table daily_covid_stats
(
    stats_date                      date        not null,
    country_id                      integer     not null,
    cases                           integer     not null,
    deaths                          integer     not null,
    population_from_2020            integer     not null,
    constraint daily_covid_stats_PK primary key (stats_date, country_id),
    constraint country_FK foreign key (country_id) references country(id)
);
