
--------------
-- AIRPORTS --
--------------

-- find out which cities have more than 1 airport

select
    ci.name as city,
    co.name as country,
    count(*) as total_airports,
    string_agg(a.name, ', ') as airport_names
from airports a
inner join cities ci
    on ci.id = a.city_id
inner join countries co
    on co.id = a.country_id
group by
    ci.name,
    co.name
having count(*) > 1
order by count(*) desc;

-- find out which countries have the most airports

select
    co.name as country,
    count(*) as total_airports
from airports a
inner join countries co
    on co.id = a.country_id
group by
    co.name
having count(*) > 1
order by count(*) desc
limit 5;

-- find out which cities have airports with the same name
--
-- I checked some of the apparent duplicates, and I believe they aren't
-- e.g. Arlington USA (there are 3 distinct cities in WA, TX and VA, and 2 of them have airports)
-- e.g. Charlottetown Canada (there are 2 distinct cities in NL and one in PE, and 2 of them have airports)

select distinct
    a.name as airport_name,
    string_agg(concat(ci.name, ' (', co.name, ')') , ', ') as cities_names
from airports a
inner join cities ci
    on ci.id = a.city_id
inner join countries co
    on co.id = ci.country_id
group by
    a.name
having count(*) > 1
order by a.name;
