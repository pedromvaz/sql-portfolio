
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
-- based on the findings on the original query, I had to exclude
-- 1. locations where, at any point in time, the number of deaths exceeded the number of cases
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
--
-- I don't think this should happen! this is the first error I found in the dataset,
-- based on the file available on October 7th, 2023
-- did these countries consider the deaths as COVID deaths, without testing? and if they did test, why were they
-- not considered as COVID cases? very strange!
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

-- find out in which countries, and on which dates, there was the biggest increase in deaths from one day to the next
-- (this should not consider the population of each country as the denominator)
--
-- base on my findings, and looking at the whole month for the listed countries, I concluded that:
-- 1. the first 2 countries in the dataset, Chile and Ecuador, must have their numbers wrong, they are much higher
--    than what we see in the rest of the month. I even looked at the WHO data, and Chile has 1 death spike since the
--    beginning, and Ecuador has 2 spikes... this seems like bad data to me
-- 2. the only reason Germany and Spain appear in these results is because these are weekly numbers, not daily;
--    I did not insert the "smoothed" numbers into this table, they are only in the "load" table
-- 3. the only country listed that makes sense is India, as the number is in line with the whole month
select
    l.name as location,
    c.new_deaths,
    c.on_date
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
order by new_deaths desc
limit 5;

-- find the average COVID death percentage per continent, for the most recent date
with location_stats (location_name, continent_id, total_deaths, population) as (
    select
        l.name,
        l.continent_id,
        max(c.total_deaths),
        max(l.population)
    from daily_covid_stats c
    inner join location l
        on c.location_id = l.id
        and l.continent_id is not null
    group by
        l.name,
        l.continent_id
)
select
    c.name,
    sum(s.total_deaths) as total_deaths,
    sum(s.population) as population,
    sum(s.total_deaths) / sum(s.population) * 100 as death_percentage
from continent c
inner join location_stats s
    on c.id = s.continent_id
group by c.name
order by death_percentage desc;
