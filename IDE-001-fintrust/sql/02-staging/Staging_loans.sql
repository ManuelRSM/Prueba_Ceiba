CREATE OR REPLACE TABLE prueba-maps-283720.staging_fintrust.loans AS
SELECT * EXCEPT(rn)
FROM (
    SELECT
        CAST(loan_id AS STRING) AS loan_id,
        CAST(customer_id AS STRING) AS customer_id,
        CAST(origination_date AS DATE) AS origination_date,
        CAST(principal_amount AS NUMERIC) AS principal_amount, 
        CAST(annual_rate AS NUMERIC) AS annual_rate,  
        CAST(term_months AS NUMERIC) AS term_months, 
        UPPER(TRIM(CAST(loan_status AS STRING))) AS loan_status, 
        UPPER(TRIM(CAST(product_type AS STRING))) AS product_type,

        ROW_NUMBER() OVER (
            PARTITION BY loan_id
            ORDER BY origination_date DESC
        ) AS rn

    FROM `prueba-maps-283720.raw_fintrust.loans`
)
WHERE rn = 1;