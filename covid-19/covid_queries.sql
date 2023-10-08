
-- find out the first 10 locations where the Covid-19 outbreak started
with location_initial_cases (location_id, initial_cases) as (
    select
        location_id,
        min(total_cases)
    from daily_covid_stats
    where total_cases > 0
    group by location_id
)
select
    l.name as location,
    i.initial_cases,
    min(c.on_date) as first_date
from location_initial_cases i
inner join daily_covid_stats c
    on i.location_id = c.location_id
    and i.initial_cases = c.total_cases
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
group by
    l.name,
    i.initial_cases
order by first_date
limit 10;

-- find out the top 10 locations with the highest number of cases, and their total deaths
select
    l.name as location,
    max(c.total_cases) as total_cases,
    max(c.total_deaths) as total_deaths
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
group by location
order by total_cases desc
limit 10;

-- find out the top 10 locations with the lowest number of cases, and their total deaths
select
    l.name as location,
    max(c.total_cases) as total_cases,
    max(c.total_deaths) as total_deaths
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
group by location
having total_cases > 0
order by total_cases asc
limit 10;

-- find out the top 10 instances when the total number of deaths per total number of cases was highest
--
-- based on the findings on the original query, I had to
-- 1. exclude locations where, at any point in time, the number of deaths exceeded the number of cases
-- 2. points in time when the number of deaths was equal to the number of cases
select
    l.name as location,
    c.on_date,
    c.total_cases,
    c.total_deaths,
    (c.total_deaths / c.total_cases) * 100 as death_percentage
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
where c.total_cases > 0
and c.total_cases > c.total_deaths
and l.name not in ('Botswana', 'Germany', 'France', 'Mauritania', 'Peru', 'Zimbabwe')
order by death_percentage desc
limit 10;

-- find out how many cases there are with more total deaths than total cases, per location
-- (fyi, this should not happen! this is the first error I found in the dataset,
-- based on the file available on October 7th, 2023)
select
    l.name as location,
    count(*) as total
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
where c.total_deaths > c.total_cases
group by location;

-- find out all the locations where, at least once, all their cases resulted in deaths
select distinct
    l.name as location
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
where c.total_cases > 0
and c.total_cases = c.total_deaths;
