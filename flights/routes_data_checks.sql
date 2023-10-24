
-- count empty values for each column, vs total lines in the load table
select
	count(*) as total_lines,
	sum(case when airline is null or length(trim(airline)) = 0 then 1 else 0 end) as total_empty_airlines,
	sum(case when airline is null then 1 else 0 end) as total_empty_airline_ids,
	sum(case when source_airport is null or length(trim(source_airport)) = 0 then 1 else 0 end) as total_empty_source_airports,
	sum(case when source_airport_id is null then 1 else 0 end) as total_empty_source_airport_ids,
	sum(case when destination_airport is null or length(trim(destination_airport)) = 0 then 1 else 0 end) as total_empty_destination_airports,
	sum(case when destination_airport_id is null then 1 else 0 end) as total_empty_destination_airport_ids,
	sum(case when codeshare is null or length(trim(codeshare)) = 0 then 1 else 0 end) as total_empty_codeshares,
	sum(case when stops is null then 1 else 0 end) as total_empty_stops,
	sum(case when equipment is null or length(trim(equipment)) = 0 then 1 else 0 end) as total_empty_equipments
from load_routes;

-- list all routes with empty airport IDs (source or destination) (423)
select *
from load_routes
where source_airport_id is null
or destination_airport_id is null
order by
	source_airport,
	destination_airport;

-- try to find airport IDs in the load_airports table, for the incomplete routes
-- (this will help when inserting the data in the "final" table)
select
	r.airline,
	r.airline_id,
	r.source_airport,
	aso.iata_code as source_airport_iata,
	r.source_airport_id,
	aso.id as source_airport_real_id,
	r.destination_airport,
	ade.iata_code as destination_airport_iata,
	r.destination_airport_id,
	ade.id as destination_airport_real_id,
	r.codeshare,
	r.stops,
	r.equipment
from load_routes r
left outer join load_airports aso
	on r.source_airport = aso.iata_code
left outer join load_airports ade
	on r.destination_airport = ade.iata_code
where r.source_airport_id is null
or r.destination_airport_id is null
order by
	r.source_airport,
	r.destination_airport;

-- search for wrong airport IDs in the load_routes table
-- (916 total rows, where 459 have a bad source airport ID, and 463 have a bad destination airport ID -- a few rows have both)
select
	r.airline,
	r.airline_id,
	r.source_airport,
	aso.iata_code as source_airport_iata,
	r.source_airport_id,
	aso.id as source_airport_real_id,
	r.destination_airport,
	ade.iata_code as destination_airport_iata,
	r.destination_airport_id,
	ade.id as destination_airport_real_id,
	r.codeshare,
	r.stops,
	r.equipment
from load_routes r
left outer join load_airports aso
	on r.source_airport = aso.iata_code
left outer join load_airports ade
	on r.destination_airport = ade.iata_code
where r.source_airport_id is not null and r.source_airport_id != aso.id
or r.destination_airport_id is not null and r.destination_airport_id != ade.id
order by
	r.source_airport,
	r.destination_airport;

-- search for wrong airline IDs in the load_routes table (10558 total rows!!!)
select
	r.airline,
	r.airline_id,
	a.id as airline_real_id,
	r.source_airport,
	r.source_airport_id,
	r.destination_airport,
	r.destination_airport_id,
	r.codeshare,
	r.stops,
	r.equipment
from load_routes r
left outer join load_airlines a
	on r.airline = a.iata_code
where r.airline_id is not null and r.airline_id != a.id
order by r.airline;

-- search for duplicates in the values of airline + source_airport + destination_airport (0)
select
	airline,
	source_airport,
	destination_airport,
	count(*)
from load_routes
group by
	airline,
	source_airport,
	destination_airport
having count(*) > 1;

-- check if there's more data missing, when there is no plane (i.e. equipment) assigned to a route (2)
select *
from load_routes
where equipment is null;
