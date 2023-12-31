
-- count empty values for each column, vs total lines in the load table
select
	count(*) as total_lines,
	sum(case when name is null or length(trim(name)) = 0 then 1 else 0 end) as total_empty_names,
	sum(case when alias is null or length(trim(alias)) = 0 then 1 else 0 end) as total_empty_aliases,
	sum(case when iata_code is null or length(trim(iata_code)) = 0 then 1 else 0 end) as total_empty_iata_codes,
	sum(case when icao_code is null or length(trim(icao_code)) = 0 then 1 else 0 end) as total_empty_icao_codes,
	sum(case when call_sign is null or length(trim(call_sign)) = 0 then 1 else 0 end) as total_empty_call_signs,
	sum(case when country is null or length(trim(country)) = 0 then 1 else 0 end) as total_empty_countries,
	sum(case when active is null or length(trim(active)) = 0 then 1 else 0 end) as total_empty_actives
from load_airlines;

-- check if there are repeated names (70!)
select name, count(*)
from load_airlines
where trim(name) != ''
group by name
having count(*) > 1;

-- check if there are repeated names by activity / inactivity (6 active!, 52 inactive)
select active, name, count(*)
from load_airlines
where trim(name) != ''
group by active, name
having count(*) > 1
order by active desc, name;

-- list the active airlines with repeated names (Air Salone is the only one that's really duplicated)
select *
from load_airlines
where name in (
	select name
	from load_airlines
	where trim(name) != ''
	and upper(active) = 'Y'
	group by name
	having count(*) > 1
)
and upper(active) = 'Y'
order by name;

-- check if there are repeated aliases (0)
select alias, count(*)
from load_airlines
where trim(alias) != ''
group by alias
having count(*) > 1;

-- check if there are repeated iata codes (320!!)
select iata_code, count(*)
from load_airlines
where trim(iata_code) != ''
group by iata_code
having count(*) > 1;

-- check if there are repeated iata codes by activity / inactivity (19 active!, 103 inactive)
select active, iata_code, count(*)
from load_airlines
where trim(iata_code) != ''
group by active, iata_code
having count(*) > 1
order by active desc, iata_code;

-- list the active airlines with repeated iata codes (some of them seem duplicated)
select *
from load_airlines
where iata_code in (
	select iata_code
	from load_airlines
	where trim(iata_code) != ''
	and upper(active) = 'Y'
	group by iata_code
	having count(*) > 1
)
and upper(active) = 'Y'
order by name;

-- check if there are repeated icao codes (34!)
select icao_code, count(*)
from load_airlines
where trim(icao_code) != ''
group by icao_code
having count(*) > 1;

-- check if there are repeated icao codes by activity / inactivity (8 active!, 11 inactive)
select active, icao_code, count(*)
from load_airlines
where trim(icao_code) != ''
group by active, icao_code
having count(*) > 1
order by active desc, icao_code;

-- list the active airlines with repeated icao codes
-- (Malmo Aviation and Tyrolean Airways are the only ones that are really duplicated, and some others seem duplicated)
select *
from load_airlines
where icao_code in (
	select icao_code
	from load_airlines
	where trim(icao_code) != ''
	and upper(active) = 'Y'
	group by icao_code
	having count(*) > 1
)
and upper(active) = 'Y'
order by icao_code;

-- check if there are repeated call signs (44!)
select call_sign, count(*)
from load_airlines
where trim(call_sign) != ''
group by call_sign
having count(*) > 1;

-- check if there are repeated call signs by activity / inactivity (11 active!, 10 inactive)
select active, call_sign, count(*)
from load_airlines
where trim(call_sign) != ''
group by active, call_sign
having count(*) > 1
order by active desc, call_sign;

-- list the active airlines with repeated call signs (Tyrolean Airways is the only one that's really duplicated)
select *
from load_airlines
where call_sign in (
	select call_sign
	from load_airlines
	where trim(call_sign) != ''
	and upper(active) = 'Y'
	group by call_sign
	having count(*) > 1
)
and upper(active) = 'Y'
order by name;

-- count how many active / inactive airlines there are
select upper(active) as active, count(*)
from load_airlines
group by upper(active)

-- check if there are repeated lines (6161 distinct vs 6161 total, so 0)
select count(*) from (select distinct * from load_airlines) a
