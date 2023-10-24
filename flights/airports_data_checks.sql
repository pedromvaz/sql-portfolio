
-- count empty values for each column, vs total lines in the load table
select
	count(*) as total_lines,
	sum(case when name is null or length(trim(name)) = 0 then 1 else 0 end) as total_empty_names,
	sum(case when city is null or length(trim(city)) = 0 then 1 else 0 end) as total_empty_cities,
	sum(case when country is null or length(trim(country)) = 0 then 1 else 0 end) as total_empty_countries,
	sum(case when iata_code is null or length(trim(iata_code)) = 0 then 1 else 0 end) as total_empty_iata_codes,
	sum(case when icao_code is null or length(trim(icao_code)) = 0 then 1 else 0 end) as total_empty_icao_codes,
	sum(case when type is null or length(trim(type)) = 0 then 1 else 0 end) as total_empty_types,
	sum(case when source is null or length(trim(source)) = 0 then 1 else 0 end) as total_empty_sources
from load_airports;

-- check if there are repeated names (36!)
select name, count(*)
from load_airports
where trim(name) != ''
group by name
having count(*) > 1;

-- check if the repeated names belong to the same city and country (6!)
select name, city, country, count(*)
from load_airports
group by name, city, country
having count(*) > 1;

-- list all the airports with the same name, city, and country
-- (they all seen to be duplicated... or maybe they moved to another area?!)
select *
from load_airports
where name in (
	select name
	from load_airports
	group by name, city, country
	having count(*) > 1
)
order by name, id;

-- check if there are repeated iata codes (0)
select iata_code, count(*)
from load_airports
where trim(iata_code) != ''
group by iata_code
having count(*) > 1;

-- check if there are repeated icao codes (0)
select icao_code, count(*)
from load_airports
where trim(icao_code) != ''
group by icao_code
having count(*) > 1;

-- check if there are cities with the same name, but from different countries (121!!)
select city, count(distinct country) as different_countries
from load_airports
where city is not null
group by city
having count(distinct country) > 1;

-- list the countries from the first city in the previous query (UK, USA)
select distinct city, country
from load_airports
where city = 'Aberdeen';
