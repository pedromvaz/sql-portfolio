
-- insert new continents
insert into continent (name)
select distinct
    l.continent
from load_covid_stats l
left outer join continent c
    on l.continent = c.name
where c.name is null
and trim(l.continent) != "";


-- insert new locations
insert into location (iso_code, name, population, continent_id)
select distinct
    l.iso_code,
    l.location,
    l.population,
    c.id
from load_covid_stats l
left outer join location loc
    on l.location = loc.name
left outer join continent c
    on l.continent = c.name
where loc.name is null
and trim(l.location) != "";


-- insert daily covid statistics for all countries
insert into daily_covid_stats
select
    loc.id,
    l.on_date,
    l.total_cases,
    l.new_cases,
    l.total_deaths,
    l.new_deaths,
    l.reproduction_rate,
    l.icu_patients,
    l.hosp_patients,
    l.weekly_icu_admissions,
    l.weekly_hosp_admissions,
    l.total_tests,
    l.new_tests,
    l.positive_rate,
    l.tests_per_case,
    l.total_vaccinations,
    l.people_vaccinated,
    l.people_fully_vaccinated,
    l.total_boosters,
    l.new_vaccinations,
    l.life_expectancy
from load_covid_stats l
inner join location loc
    on l.location = loc.name
left outer join daily_covid_stats c
    on loc.id = c.location_id
    and l.on_date = c.on_date
where c.location_id is null;
