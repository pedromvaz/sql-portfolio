
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



drop table if exists world_happiness;

create table world_happiness
(
    year                            integer     not null,
    country_id                      integer     not null,
    happiness_score                 real        not null,
    gdp_per_capita                  real        not null,
    social_support                  real        not null,
    healthy_life_expectancy         real        not null,
    freedom_to_make_life_choices    real        not null,
    generosity                      real        not null,
    perceptions_of_corruption       real        not null,
    constraint load_whr_PK primary key (year, country_id)
);



drop table if exists country;

create table country
(
    id          integer         primary key,
    name        varchar(100)    not null,
    region_id   integer         not null,
    constraint region_FK foreign key (region_id) references region(id)
);



drop table if exists region;

create table region
(
    id          integer         primary key,
    name        varchar(100)    not null
);
