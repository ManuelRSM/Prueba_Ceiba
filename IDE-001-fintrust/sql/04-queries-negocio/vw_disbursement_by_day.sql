CREATE OR REPLACE VIEW prueba-maps-283720.vw_analytics_fintrust.vw_disbursement_by_day AS (


SELECT  
    origination_date, 
    city,
    segment,
    SUM(principal_amount) AS total_disbursement
FROM (
    SELECT DISTINCT
        loan_id,
        origination_date,
        city,
        segment,
        principal_amount
    FROM `prueba-maps-283720.analytics_fintrust.fct_loan_installments_payments`
    WHERE loan_id IS NOT NULL
)
GROUP BY 
    origination_date, 
    city, 
    segment
ORDER BY 
    origination_date

);