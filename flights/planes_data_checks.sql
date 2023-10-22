
-- count empty values for each column, vs total lines in the load table
select
	count(*) as total_lines,
	sum(case when name is null or length(trim(name)) = 0 then 1 else 0 end) as total_empty_names,
	sum(case when iata_code is null or length(trim(iata_code)) = 0 then 1 else 0 end) as total_empty_iata_codes,
	sum(case when icao_code is null or length(trim(icao_code)) = 0 then 1 else 0 end) as total_empty_icao_codes
from load_planes;

-- check if there are repeated iata codes (6)
select iata_code, count(*)
from load_planes
where trim(iata_code) != ''
group by iata_code
having count(*) > 1;

-- check if there are repeated icao codes (1)
select icao_code, count(*)
from load_planes
where trim(icao_code) != ''
group by icao_code
having count(*) > 1;

-- list all the planes with the same iata code
-- (different plane models under the same IATA code)
select *
from load_planes
where iata_code in (
	select iata_code
	from load_planes
	group by iata_code
	having count(*) > 1
)
order by name;

-- list all the planes with the same icao code
-- (I checked the "duplicate" data in 2 websites, and they match
--     https://en.wikipedia.org/wiki/List_of_aircraft_type_designators
--     https://www.icao.int/publications/doc8643/pages/search.aspx
-- )
select *
from load_planes
where icao_code in (
	select icao_code
	from load_planes
	group by icao_code
	having count(*) > 1
)
order by name;
