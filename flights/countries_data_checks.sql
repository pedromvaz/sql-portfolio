
-- count empty values for each column, vs total lines in the load table
select
	count(*) as total_lines,
	sum(case when name is null or length(trim(name)) = 0 then 1 else 0 end) as total_empty_names,
	sum(case when iso_code is null or length(trim(iso_code)) = 0 then 1 else 0 end) as total_empty_iso_codes,
	sum(case when dafif_code is null or length(trim(dafif_code)) = 0 then 1 else 0 end) as total_empty_dafif_codes
from load_countries;

-- check if there are repeated iso codes (2)
select iso_code, count(*)
from load_countries
where trim(iso_code) != ''
group by iso_code
having count(*) > 1;

-- check if there are repeated dafif codes (0)
select dafif_code, count(*)
from load_countries
where trim(dafif_code) != ''
group by dafif_code
having count(*) > 1;

-- list all the countries with the same iso code
-- (India and Palestine have 2 records each, but their DAFIF code is different)
select *
from load_countries
where iso_code in (
	select iso_code
	from load_countries
	group by iso_code
	having count(*) > 1
)
order by name;

-- deleting wrong entries in load_countries
-- based on https://www.geodatasource.com/resources/tutorials/international-country-code-fips-versus-iso-3166/
delete from load_countries
where name = 'India' and dafif_code = 'BS';

delete from load_countries
where name = 'Palestine' and dafif_code = 'GZ';

-- re-check if there are repeated iso codes (0)
select iso_code, count(*)
from load_countries
where trim(iso_code) != ''
group by iso_code
having count(*) > 1;
