
-- find out the first 10 countries where the Covid-19 outbreak started
with country_initial_cases (location_id, initial_cases) as (
    select
        location_id,
        min(total_cases)
    from daily_covid_stats
    where total_cases > 0
    group by location_id
)
select
    l.name as country,
    i.initial_cases,
    min(c.on_date) as first_date
from country_initial_cases i
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

-- find out the top 10 countries with the highest number of cases, and their total deaths
select
    l.name as country,
    max(c.total_cases) as total_cases,
    max(c.total_deaths) as total_deaths
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
group by country
order by total_cases desc
limit 10;

-- find out the top 10 countries with the lowest number of cases, and their total deaths
select
    l.name as country,
    max(c.total_cases) as total_cases,
    max(c.total_deaths) as total_deaths
from daily_covid_stats c
inner join location l
    on c.location_id = l.id
    and l.continent_id is not null
group by country
having total_cases > 0
order by total_cases asc
limit 10;
