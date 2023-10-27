
truncate table routes, airlines, airports, cities, countries, planes;

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


-- insert city names and their countries from the airports' load table into the cities table

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
