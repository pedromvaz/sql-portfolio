
-- insert new regions
insert into region (name)
select distinct
    l.region
from load_whr l
left outer join region r
    on l.region = r.name
where r.name is null;


-- insert new countries
insert into country (name, region_id)
select distinct
    l.country,
    r.id
from load_whr l
left outer join country c
    on l.country = c.name
left outer join region r
    on l.region = r.name
where c.name is null;


-- insert happiness for all countries in a certain year
insert into world_happiness
select
    2015,
    c.id,
    l.happiness_score,
    l.gdp_per_capita,
    l.social_support,
    l.healthy_life_expectancy,
    l.freedom_to_make_life_choices,
    l.generosity,
    l.perceptions_of_corruption
from load_whr l
inner join country c
    on l.country = c.name
left outer join world_happiness h
    on c.id = h.country_id
    and h.year = 2015
where h.country_id is null;
