-- with a as (
-- select
-- a.symbol,
-- a.industry,
-- extract(year from report_date) as year
-- from company_industry a inner join
-- stock_values b on a.symbol = b.symbol)

-- select 
-- year, 
-- industry,
-- count(distinct(symbol))
-- from a
-- group by year, industry
-- ;

-- do this with window function
SELECT
    (SELECT symbol FROM index_duration WHERE duration_present_months = MAX(duration_present_months)) AS max_duration_symbol,
    MAX(duration_present_months) AS max_duration_months,
    (SELECT symbol FROM index_duration WHERE duration_present_months = MIN(duration_present_months)) AS min_duration_symbol,
    MIN(duration_present_months) AS min_duration_months
FROM index_duration
;


