
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

-- find out how common each range of altitudes (in feet) is for airports

create temporary table altitude_ranges
(
    minimum     integer     not null,
    maximum     integer     not null
);

do $$
declare
    minimum integer := -2000; -- minimum altitude in the data is -1266 feet
    range integer := 1000;
begin
    loop
        insert into altitude_ranges values (minimum, minimum + range);

        minimum := minimum + range;

        if minimum > 14000 then -- maximum altitude in the data is 14472 feet
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

-- find out how many routes each airline has, and order them from most routes to least routes

select
    a.name as airline_name,
    count(r.id) as total_routes
from airlines a
inner join routes r
    on r.airline_id = a.id
group by a.name
order by count(r.id) desc;

-- find out which is the most frequent source/departure airport for each airline

with
    airline_airport_source_frequency (airline_id, airport_id, frequency) as
    (
        select
            airline_id,
            source_airport_id,
            count(*)
        from routes
        where airline_id is not null
        and source_airport_id is not null
        group by
            airline_id,
            source_airport_id
    ),
    airline_airport_source_frequency_ranked (airline_id, airport_id, frequency, rank) as
    (
        select
            airline_id,
            airport_id,
            frequency,
            rank() over (partition by airline_id order by frequency desc)
        from airline_airport_source_frequency
    )
select
    al.name as airline_name,
    r.frequency,
    string_agg(ap.name, ', ') as airport_names
from airline_airport_source_frequency_ranked r
inner join airlines al
    on al.id = r.airline_id
inner join airports ap
    on ap.id = r.airport_id
where rank = 1
group by
    al.name,
    r.frequency
order by al.name;

-- find out how many models of planes each active airline uses on their routes,
-- and order them from most models to least models

select
    a.name as airline_name,
    count(distinct rp.plane_id) as total_plane_models
from airlines a
inner join routes r
    on r.airline_id = a.id
inner join routes_planes rp
    on rp.route_id = r.id
group by a.name
order by count(distinct rp.plane_id) desc;


------------
-- PLANES --
------------

-- find out which companies have the most plane models
--
-- the output "Douglas" is referring to "Douglas Aircraft Company", which later merged
-- with "McDonnell Aircraft Corporation", to become "McDonnell Douglas"
-- later still, "McDonnell Douglas" merged with "Boeing"

select
    unnest(string_to_array(name, ' ')) as word,
    count(*) as word_count
from planes
group by words
order by count(*) desc
limit 5;


------------
-- ROUTES --
------------

-- find out which routes have at least 1 stop

select
    al.name as airline_name,
    concat(ap1.name, ' (', c1.name, ')') as source_airport_name,
    concat(ap2.name, ' (', c2.name, ')') as destination_airport_name,
    r.stops
from routes r
inner join airlines al
    on al.id = r.airline_id
inner join airports ap1
    on ap1.id = r.source_airport_id
inner join countries c1
    on c1.id = ap1.country_id
inner join airports ap2
    on ap2.id = r.destination_airport_id
inner join countries c2
    on c2.id = ap2.country_id
where stops > 0
order by 1, 2, 3;

-- find out how many national routes each airport has, counting all airlines,
-- and list them by number of routes in descending order

select
    a1.name as airport_name,
    count(*) as total_internal_routes
from routes r
inner join airports a1
    on a1.id = r.source_airport_id
inner join countries c1
    on c1.id = a1.country_id
inner join airports a2
    on a2.id = r.destination_airport_id
inner join countries c2
    on c2.id = a2.country_id
    and c2.id = c1.id
group by a1.name
order by 2 desc;

-- find out the number of national routes per country, not counting airlines,
-- and list them by number of routes in descending order

select
    c2.name as country_name,
    count(*) as total_routes
from (select distinct source_airport_id, destination_airport_id from routes) ar
inner join airports a1
    on a1.id = ar.source_airport_id
inner join countries c1
    on c1.id = a1.country_id
inner join airports a2
    on a2.id = ar.destination_airport_id
inner join countries c2
    on c2.id = a2.country_id
    and c2.id = c1.id
group by c2.name
order by 2 desc;

-- find out the number of routes between each pair of countries, not counting airlines,
-- and list them by number of routes in descending order

with
    country_routes (source_country_name, destination_country_name, total_routes) as
    (
        select
            c1.name as source_country_name,
            c2.name as destination_country_name,
            count(*) as total_routes
        from (select distinct source_airport_id, destination_airport_id from routes) ar
        inner join airports a1
            on a1.id = ar.source_airport_id
        inner join countries c1
            on c1.id = a1.country_id
        inner join airports a2
            on a2.id = ar.destination_airport_id
        inner join countries c2
            on c2.id = a2.country_id
            and c2.id != c1.id
        group by
            c1.name,
            c2.name
    )
select
    case
        when source_country_name < destination_country_name then source_country_name
        else destination_country_name
    end as first_country,
    case
        when source_country_name < destination_country_name then destination_country_name
        else source_country_name
    end as second_country,
    sum(total_routes) as total_routes
from country_routes
group by
    first_country,
    second_country
order by 3 desc;

-- find out which routes do not have a return route, for each airline

with
    airline_routes (airline_id, source_airport_id, destination_airport_id) as
    (
        select distinct
            airline_id,
            source_airport_id,
            destination_airport_id
        from routes
        where airline_id is not null
        and source_airport_id is not null
        and destination_airport_id is not null
    ),
    one_way_airline_routes (airline_id, source_airport_id, destination_airport_id) as
    (
        select
            airline_id,
            source_airport_id,
            destination_airport_id
        from airline_routes

        except

        select
            r1.airline_id,
            r1.source_airport_id,
            r1.destination_airport_id
        from airline_routes r1
        inner join airline_routes r2
            on r2.airline_id = r1.airline_id
            and r2.source_airport_id = r1.destination_airport_id
            and r2.destination_airport_id = r1.source_airport_id
    )
select
    al.name as airline_name,
    concat(ap1.name, ' (', c1.name, ')') as source_airport_name,
    concat(ap2.name, ' (', c2.name, ')') as destination_airport_name
from one_way_airline_routes r
inner join airlines al
    on al.id = r.airline_id
inner join airports ap1
    on ap1.id = r.source_airport_id
inner join countries c1
    on c1.id = ap1.country_id
inner join airports ap2
    on ap2.id = r.destination_airport_id
inner join countries c2
    on c2.id = ap2.country_id
order by 1, 2, 3;

-- find out which countries do not have a single route between them (from country A to country B, not both ways)

select
    c1.name as source_country,
    c2.name as destination_country
from countries c1
cross join countries c2

except

select distinct
    c1.name,
    c2.name
from routes r
inner join airports a1
    on a1.id = r.source_airport_id
inner join countries c1
    on c1.id = a1.country_id
inner join airports a2
    on a2.id = r.destination_airport_id
inner join countries c2
    on c2.id = a2.country_id;
