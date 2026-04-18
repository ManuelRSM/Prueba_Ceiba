CREATE OR REPLACE TABLE prueba-maps-283720.staging_fintrust.customers AS
SELECT *
FROM (
    SELECT 
       CAST(customer_id AS STRING) AS customer_id,  
       UPPER(TRIM(CAST(full_name AS STRING))) AS full_name, 
       UPPER(TRIM(CAST(city AS STRING))) AS city, 
       UPPER(TRIM(CAST(segment AS STRING))) AS segment, 
       CAST(monthly_income AS NUMERIC) AS monthly_income, 
       CAST(created_at AS DATE) AS created_at,

       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY created_at DESC
       ) AS rn

    FROM `prueba-maps-283720.raw_fintrust.customers`
)
WHERE rn = 1;