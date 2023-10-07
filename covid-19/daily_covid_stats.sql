
use covid;

drop table if exists load_covid_stats;

create table load_covid_stats
(
    iso_code                                    varchar(10) not null,
    continent                                   varchar(20) not null,
    location                                    varchar(50) not null,
    on_date                                     char(10) not null,
    total_cases                                 decimal(15,3) null,
    new_cases                                   decimal(15,3) null,
    new_cases_smoothed                          decimal(15,3) null,
    total_deaths                                decimal(15,3) null,
    new_deaths                                  decimal(15,3) null,
    new_deaths_smoothed                         decimal(15,3) null,
    total_cases_per_million                     decimal(15,3) null,
    new_cases_per_million                       decimal(15,3) null,
    new_cases_smoothed_per_million              decimal(15,3) null,
    total_deaths_per_million                    decimal(15,3) null,
    new_deaths_per_million                      decimal(15,3) null,
    new_deaths_smoothed_per_million             decimal(15,3) null,
    reproduction_rate                           decimal(15,3) null,
    icu_patients                                decimal(15,3) null,
    icu_patients_per_million                    decimal(15,3) null,
    hosp_patients                               decimal(15,3) null,
    hosp_patients_per_million                   decimal(15,3) null,
    weekly_icu_admissions                       decimal(15,3) null,
    weekly_icu_admissions_per_million           decimal(15,3) null,
    weekly_hosp_admissions                      decimal(15,3) null,
    weekly_hosp_admissions_per_million          decimal(15,3) null,
    total_tests                                 decimal(15,3) null,
    new_tests                                   decimal(15,3) null,
    total_tests_per_thousand                    decimal(15,3) null,
    new_tests_per_thousand                      decimal(15,3) null,
    new_tests_smoothed                          decimal(15,3) null,
    new_tests_smoothed_per_thousand             decimal(15,3) null,
    positive_rate                               decimal(8,6) null,
    tests_per_case                              decimal(15,3) null,
    tests_units                                 varchar(20) null,
    total_vaccinations                          decimal(15,3) null,
    people_vaccinated                           decimal(15,3) null,
    people_fully_vaccinated                     decimal(15,3) null,
    total_boosters                              decimal(15,3) null,
    new_vaccinations                            decimal(15,3) null,
    new_vaccinations_smoothed                   decimal(15,3) null,
    total_vaccinations_per_hundred              decimal(15,3) null,
    people_vaccinated_per_hundred               decimal(15,3) null,
    people_fully_vaccinated_per_hundred         decimal(15,3) null,
    total_boosters_per_hundred                  decimal(15,3) null,
    new_vaccinations_smoothed_per_million       decimal(15,3) null,
    new_people_vaccinated_smoothed              decimal(15,3) null,
    new_people_vaccinated_smoothed_per_hundred  decimal(15,3) null,
    stringency_index                            decimal(8,4) null,
    population_density                          decimal(15,3) null,
    median_age                                  decimal(8,4) null,
    aged_65_older                               decimal(8,4) null,
    aged_70_older                               decimal(8,4) null,
    gdp_per_capita                              varchar(20) null,
    extreme_poverty                             decimal(8,4) null,
    cardiovasc_death_rate                       decimal(15,3) null,
    diabetes_prevalence                         decimal(15,3) null,
    female_smokers                              decimal(8,4) null,
    male_smokers                                decimal(8,4) null,
    handwashing_facilities                      decimal(15,3) null,
    hospital_beds_per_thousand                  decimal(8,4) null,
    life_expectancy                             decimal(8,4) null,
    human_development_index                     decimal(8,4) null,
    population                                  decimal(15,3) null,
    excess_mortality_cumulative_absolute        varchar(20) null,
    excess_mortality_cumulative                 decimal(8,4) null,
    excess_mortality                            decimal(8,4) null,
    excess_mortality_cumulative_per_million     varchar(20) null,
    constraint load_covid_stats_PK primary key (iso_code, on_date)
);



drop table if exists continent;

create table continent
(
    id          integer unsigned    not null auto_increment,
    name        varchar(20)        not null,
    constraint continent_PK primary key (id)
);



drop table if exists location;

create table location
(
    id              integer unsigned    not null auto_increment,
    iso_code        varchar(10)         not null,
    name            varchar(50)        not null,
    population      decimal(15,1)       not null,
    continent_id    integer unsigned    not null,
    constraint location_PK primary key (id),
    constraint continent_FK foreign key (continent_id) references continent(id)
);



drop table if exists daily_covid_stats;

create table daily_covid_stats
(
    location_id                 integer unsigned    not null,
    on_date                     date                not null,
    total_cases                 decimal(15,1)       null,
    new_cases                   decimal(15,1)       null,
    total_deaths                decimal(15,1)       null,
    new_deaths                  decimal(15,1)       null,
    reproduction_rate           decimal(5,2)        null,
    icu_patients                decimal(15,1)       null,
    hosp_patients               decimal(15,1)       null,
    weekly_icu_admissions       decimal(15,1)       null,
    weekly_hosp_admissions      decimal(15,1)       null,
    total_tests                 decimal(15,1)       null,
    new_tests                   decimal(15,1)       null,
    positive_rate               decimal(8,6)        null,
    tests_per_case              decimal(6,4)        null,
    total_vaccinations          decimal(15,1)       null,
    people_vaccinated           decimal(15,1)       null,
    people_fully_vaccinated     decimal(15,1)       null,
    total_boosters              decimal(15,1)       null,
    new_vaccinations            decimal(15,1)       null,
    life_expectancy             decimal(6,3)        null,
    constraint daily_covid_stats_PK primary key (location_id, on_date),
    constraint location_FK foreign key (location_id) references location(id)
);
