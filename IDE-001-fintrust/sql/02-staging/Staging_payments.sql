CREATE OR REPLACE TABLE prueba-maps-283720.staging_fintrust.payments AS(
SELECT 
    CAST(payment_id AS STRING) AS payment_id,
    CAST(loan_id AS STRING) AS loan_id,
    CAST(installment_id AS STRING) AS installment_id,
    SAFE_CAST(payment_date AS DATE) AS payment_date,
    CAST(payment_amount AS NUMERIC) AS payment_amount,
    UPPER(TRIM(COALESCE(payment_channel, 'OTRO'))) AS payment_channel,
    CAST(payment_status AS STRING) AS payment_status,
    SAFE_CAST(loaded_at AS TIMESTAMP) AS loaded_at
FROM `prueba-maps-283720.raw_fintrust.payments`
WHERE payment_id IS NOT NULL
);
