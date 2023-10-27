
-- remove all data from all tables and restart their ID sequences

truncate table routes, airlines, airports, cities, countries, planes;

alter sequence if exists routes_seq restart with 1;
alter sequence if exists airlines_seq restart with 1;
alter sequence if exists airports_seq restart with 1;
alter sequence if exists cities_seq restart with 1;
alter sequence if exists countries_seq restart with 1;
alter sequence if exists planes_seq restart with 1;


-- insert country names and codes from 3 load tables into the countries table

insert into countries (name, iso_code, dafif_code)
select distinct
    trim(l.name),
    trim(l.iso_code),
    trim(l.dafif_code)
from load_countries l
left outer join countries c
    on trim(l.name) = c.name
where c.id is null
and trim(l.name) != '';

/*
insert into countries (name, iso_code, dafif_code)
select distinct
    trim(l.country),
    null,
    null
from load_airlines l
left outer join countries c
    on trim(l.country) = c.name
where c.id is null
and trim(l.country) != '';
*/

insert into countries (name, iso_code, dafif_code)
select distinct
    trim(l.country),
    null,
    null
from load_airports l
left outer join countries c
    on trim(l.country) = c.name
where c.id is null
and trim(l.country) != '';


-- insert city names and their countries from the load_airports table into the cities table

insert into cities (name, country_id)
select distinct
    l.city,
    co.id
from load_airports l
left outer join cities ci
    on ci.name = l.city
left outer join countries co
    on l.country = co.name
where ci.id is null
and trim(l.city) != '';


-- insert planes and their information from the load_planes table into the planes table

insert into planes (name, iata_code, icao_code)
select distinct
    trim(l.name),
    trim(l.iata_code),
    trim(l.icao_code)
from load_planes l
left outer join planes p
    on trim(l.name) = p.name
where p.id is null
and trim(l.name) != '';


-- insert airlines and their information from the load_airlines table into the airlines table

insert into airlines (name, iata_code, icao_code, active, country_id)
select distinct
    trim(l.name),
    trim(l.iata_code),
    trim(l.icao_code),
    case upper(l.active)
        when 'Y' then true
        when 'N' then false
        else null
    end,
    c.id
from load_airlines l
left outer join countries c
    on c.name = trim(l.country)
left outer join airlines a
    on a.name = trim(l.name)
where a.id is null
and trim(l.name) != '';


-- insert airports and their information from the load_airports table into the airports table

insert into airports (name, city_id, country_id, iata_code, icao_code, altitude)
select distinct
    trim(l.name),
    ci.id,
    co.id,
    trim(l.iata_code),
    trim(l.icao_code),
    l.altitude
from load_airports l
left outer join cities ci
    on ci.name = trim(l.city)
left outer join countries co
    on co.name = trim(l.country)
left outer join airports a
    on a.name = trim(l.name)
where a.id is null
and trim(l.name) != '';


-- insert routes and their information from the load_routes table into the routes table

insert into routes (airline_id, source_airport_id, destination_airport_id, stops)
select distinct
    a.id,
    s.id,
    d.id,
    l.stops
from load_routes l
left outer join airlines a
    on a.iata_code = trim(l.airline)
left outer join airports s
    on s.iata_code = trim(l.source_airport)
left outer join airports d
    on d.iata_code = trim(l.destination_airport)
left outer join routes r
    on a.id = r.airline_id
    and s.id = r.source_airport_id
    and d.id = r.destination_airport_id
where r.id is null
and trim(l.airline) != ''
and trim(l.source_airport) != ''
and trim(l.destination_airport) != '';
