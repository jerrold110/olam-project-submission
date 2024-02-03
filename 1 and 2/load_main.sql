DELETE FROM index_duration;
DELETE FROM stock_values;
DELETE FROM company_industry;
DELETE FROM company;

-- Load company table
/*
No null rows
Fuzzy string closest symbol to name match

https://www.postgresql.org/docs/current/fuzzystrmatch.html#FUZZYSTRMATCH-LEVENSHTEIN
https://www.postgresql.org/docs/current/sql-select.html
*/
INSERT INTO company (symbol, name)
SELECT DISTINCT ON (symbol) -- only one row for each symbol is returned
    symbol,
    name
FROM staging
WHERE symbol IS NOT NULL
    AND name IS NOT NULL
ORDER BY symbol, levenshtein(name, symbol) ASC
;

-- Load name table
/*
Convert all first letter in every word to uppercase and rest of word to lowercase
https://www.postgresql.org/docs/9.1/functions-string.html
*/
INSERT INTO company_industry(symbol, industry)
SELECT DISTINCT
symbol,
INITCAP(REPLACE(industry, '&', 'AND')) as industry
FROM staging
WHERE symbol IS NOT NULL
AND industry IS NOT NULL
;

--Load numerical table
/*
Replace all non numerical values such as '-' with NULL
Convert all 5,000 -> 5000
Create a function
https://www.postgresql.org/docs/current/plpgsql-declarations.html
https://www.postgresql.org/docs/current/sql-alterfunction.html
*/
-- Drop and create cleaning function for numeric data
DROP FUNCTION IF EXISTS convert_to_numeric;
CREATE OR REPLACE FUNCTION convert_to_numeric(input VARCHAR)
RETURNS NUMERIC
AS $$
DECLARE
    result NUMERIC;
BEGIN
    -- Try to cast input value to numeric
    BEGIN
        result := input::NUMERIC;
    -- If an exception occurs set result to null
    EXCEPTION
        WHEN OTHERS THEN
            result := NULL;
    END;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;
-- pass ownership
ALTER FUNCTION convert_to_numeric(varchar) OWNER TO user_1;
-- Not scalable to use distinct (entire row) to drop duplicate rows during load
-- This approach uses window function on key( symbol, reporting_date)
WITH rowcounts_staging AS (
    SELECT 
    *,
    COUNT(*) OVER (PARTITION BY (symbol, report_date)) as row_count
    FROM staging
)
SELECT count(*) FROM
(
SELECT
symbol,
CAST(report_date AS DATE) as report_date,
NULLIF(REPLACE(equity_cap, ',', '')::NUMERIC::BIGINT , NULL) as equity_cap,
NULLIF(REPLACE(free_float_cap, ',', '')::NUMERIC::INT, NULL) as free_float_cap,
convert_to_numeric(beta) as beta,
convert_to_numeric(volatility_per) as volatility_per,
convert_to_numeric(monthly_return) as monthly_return,
convert_to_numeric(weightage) as weightage,
convert_to_numeric(r2) as r2,
convert_to_numeric(avg_impact) as avg_impact
FROM rowcounts_staging
WHERE row_count = 1) as asd
;

-- Load duration table