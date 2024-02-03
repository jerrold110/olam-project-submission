
/*
https://www.postgresqltutorial.com/postgresql-date-functions/postgresql-extract/
*/
WITH rowcounts_staging AS (
    SELECT 
    symbol,
    report_date,
    COUNT(*) OVER (PARTITION BY (symbol, report_date::DATE)) as row_count
    FROM staging
),
index_duration_intermediate AS (
    SELECT
    symbol,
    MIN(report_date::DATE) as start_date,
    MAX(report_date::DATE) as end_date,
    12*(EXTRACT(YEAR FROM MAX(report_date::DATE)) - EXTRACT(YEAR FROM MIN(report_date::DATE))) as duurex,
    (EXTRACT(MONTH FROM MAX(report_date::DATE)) - EXTRACT(MONTH FROM MIN(report_date::DATE))) as durex,
    COUNT(*) as duration_present_months
    FROM rowcounts_staging
    WHERE row_count = 1
    GROUP BY symbol
)
select *,
CASE 
    WHEN duration_present_months < duration_months THEN 0
    WHEN duration_present_months = duration_months THEN 1
    ELSE -1
END
FROM index_duration_intermediate
;
