https://www.postgresql.org/docs/current/plpgsql-declarations.html
https://www.postgresql.org/docs/current/sql-alterfunction.html

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

WITH rowcounts_staging AS (
    SELECT 
    *,
    COUNT(*) OVER (PARTITION BY (symbol, report_date))
    FROM staging
)

SELECT DISTINCT
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
WHERE row_count = 1;
;
