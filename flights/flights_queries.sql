
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

-- find out if there are any countries with no airports
--
-- some of the countries listed have multiple names to them, and their other name(s) have airports assigned to them
-- e.g. Cabo Verde vs Cape Verde, Macao vs Macau, Faeroe Islands vs Faroe Islands
-- this would require manual updates to fix the "duplicate" countries' names
--
-- it's possible that some of the islands listed don't have airports on them, didn't check them all
-- Monaco I checked, and it doesn't have any airport; according to Google, travellers should fly to Nice (France), which is 30km away

select distinct
    c.name as country
from countries c
left outer join airports a
    on a.country_id = c.id
where a.id is null
order by c.name;

-- find out which countries have the most number of cities with airports in them

select distinct
    co.name as country,
    count(distinct ci.id) as total_cities
from countries co
inner join cities ci
    on ci.country_id = co.id
inner join airports a
    on a.city_id = ci.id
group by
    co.name
order by total_cities desc;

-- find out the maximum, minimum, and average altitudes (in feet) of all airports

select
    min(altitude) as minimum_altitude,
    max(altitude) as maximum_altitude,
    round(avg(altitude)) as average_altitude
from airports;

-- find out which ranges of altitudes (in feet) are most common in airports

create temporary table altitude_ranges
(
    minimum     integer     not null,
    maximum     integer     not null
);

do $$
declare
    minimum integer := -2000;
    range integer := 1000;
begin
    loop
        insert into altitude_ranges values (minimum, minimum + range);

        minimum := minimum + range;

        if minimum > 14000 then
            exit;
        end if;
    end loop;
end $$;

select
    ar.minimum,
    ar.maximum,
    count(*)
from altitude_ranges ar
inner join airports a
    on a.altitude >= ar.minimum
    and a.altitude < ar.maximum
group by
    ar.minimum,
    ar.maximum
order by
    ar.minimum;

drop table altitude_ranges;


--------------
-- AIRLINES --
--------------

-- find out how many active or inactive airlines each country has,
-- and list them by the total number of airlines in descending order

select
    c.name as country,
    sum(case when a.active then 1 else 0 end) as total_active,
    sum(case when not a.active then 1 else 0 end) as total_inactive
from countries c
left outer join airlines a
    on a.country_id = c.id
group by
    c.name
order by
    count(a.id) desc,
    c.name;

-- find out which countries have more active airlines than inactive ones,
-- and list them by the difference of active vs inactive, in descending order

with
    country_airlines (country, total_active, total_inactive) as
    (
        select
            c.name,
            sum(case when a.active then 1 else 0 end) as total_active,
            sum(case when not a.active then 1 else 0 end) as total_inactive
        from countries c
        left outer join airlines a
            on a.country_id = c.id
        group by
            c.name
    )
select
    *
from country_airlines
where total_active >= total_inactive
and total_active > 0
order by
    total_active - total_inactive desc;
