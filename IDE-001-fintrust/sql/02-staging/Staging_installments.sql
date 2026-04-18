CREATE OR REPLACE TABLE prueba-maps-283720.staging_fintrust.installments AS
SELECT * EXCEPT(rn)
FROM (
    SELECT 
        CAST(installment_id AS STRING) AS installment_id,
        CAST(loan_id AS STRING) AS loan_id,
        CAST(installment_number AS INT64) AS installment_number,
        SAFE_CAST(due_date AS DATE) AS due_date,
        CAST(principal_due AS NUMERIC) AS principal_due,
        CAST(interest_due AS NUMERIC) AS interest_due, 
        CAST(installment_status AS STRING) AS installment_status,

        ROW_NUMBER() OVER (
            PARTITION BY loan_id, installment_number
            ORDER BY due_date DESC
        ) AS rn

    FROM `prueba-maps-283720.raw_fintrust.installments`
)
WHERE rn = 1;
