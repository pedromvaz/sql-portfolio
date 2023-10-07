
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
