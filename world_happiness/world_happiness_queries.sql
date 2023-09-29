
-- find out the country and year with the highest happiness
select
    'Highest happiness',
    c.name,
    h.happiness_score,
    h.year
from world_happiness h
inner join country c
    on h.country_id = c.id
order by h.happiness_score desc
limit 1;


-- find out the country and year with the lowest happiness
select
    'Lowest happiness',
    c.name,
    h.happiness_score,
    h.year
from world_happiness h
inner join country c
    on h.country_id = c.id
order by h.happiness_score asc
limit 1;


-- find out the best year in terms of general happiness
select
    'Best year',
    year,
    sum(happiness_score) as total_happiness
from world_happiness
group by year
order by total_happiness desc
limit 1;


-- find out the worst year in terms of general happiness
select
    'Worst year',
    year,
    sum(happiness_score) as total_happiness
from world_happiness
group by year
order by total_happiness
limit 1;


-- find out how frequent each level of happiness is
-- (considering all the data)
select
    cast(happiness_score as integer) as happiness_score_level,
    count(*) as total
from world_happiness
group by happiness_score_level;


-- order the levels of happiness by year, from highest to lowest
select
    year,
    cast(happiness_score as integer) as happiness_score_level,
    count(*) as total
from world_happiness
group by
    year,
    happiness_score_level
order by total desc;


-- find out the top 5 countries with the longest streak of happiness >= 7,
-- and the start and end years of those streaks
select
    c.name,
    w1.year as starting_year,
    w2.year as ending_year,
    count(w3.year) as longest_streak,
    sum(w3.happiness_score) as total_happiness
from country c
inner join world_happiness w1
    on c.id = w1.country_id
    and w1.happiness_score >= 7.0
inner join world_happiness w2
    on w2.country_id = w1.country_id
    and w2.year > w1.year
    and w2.happiness_score >= 7.0
inner join world_happiness w3
    on w3.country_id = w2.country_id
    and w3.year between w1.year and w2.year
    and w3.happiness_score >= 7.0
group by
    c.name,
    starting_year,
    ending_year
order by longest_streak desc, total_happiness desc
limit 5;


-- find out the country with the highest increase in happiness,
-- and the years when that happened
select
    c.name,
    w1.year as year_of_lowest_score,
    w2.year as year_of_highest_score,
    round(max(w2.happiness_score - w1.happiness_score), 5) as highest_increase
from world_happiness w1
inner join world_happiness w2
    on w1.country_id = w2.country_id
    and w1.happiness_score < w2.happiness_score
    and w1.year < w2.year
inner join country c
    on c.id = w1.country_id
group by name
order by highest_increase desc
limit 1;


-- find out the country with the highest decrease in happiness,
-- and the years when that happened
select
    c.name,
    w1.year as year_of_highest_score,
    w2.year as year_of_lowest_score,
    round(min(w2.happiness_score - w1.happiness_score), 5) as highest_decrease
from world_happiness w1
inner join world_happiness w2
    on w1.country_id = w2.country_id
    and w1.happiness_score > w2.happiness_score
    and w1.year < w2.year
inner join country c
    on c.id = w1.country_id
group by name
order by highest_decrease
limit 1;


-- there are no queries on the other metrics, because happiness
-- is a sum of all of them, according to the kaggle website
