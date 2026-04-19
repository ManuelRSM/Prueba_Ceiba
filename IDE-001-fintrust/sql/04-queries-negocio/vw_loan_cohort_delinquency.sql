CREATE OR REPLACE VIEW prueba-maps-283720.vw_analytics_fintrust.vw_loan_cohort_delinquency AS(

WITH fecha_corte AS (
  SELECT MAX(due_date) AS corte
  FROM `prueba-maps-283720.analytics_fintrust.fct_loan_installments_payments`
),

cuota_agg AS (
SELECT
    loan_id,
    installment_id,
    origination_date,
    due_date,
    total_due,

    SUM(
        CASE 
            WHEN payment_status = 'CONFIRMED'
            THEN payment_amount 
            ELSE 0 
        END
    ) AS total_paid

FROM `prueba-maps-283720.analytics_fintrust.fct_loan_installments_payments`

GROUP BY
    loan_id,
    installment_id,
    origination_date,
    due_date,
    total_due
)

SELECT
    origination_date AS cohort_date,

    -- cartera al día
    SUM(
        CASE 
            WHEN (total_due - total_paid) > 0
                 AND due_date >= (SELECT corte FROM fecha_corte)
            THEN (total_due - total_paid)
            ELSE 0
        END
    ) AS cartera_al_dia,

    -- cartera en mora
    SUM(
        CASE 
            WHEN (total_due - total_paid) > 0
                 AND due_date < (SELECT corte FROM fecha_corte)
            THEN (total_due - total_paid)
            ELSE 0
        END
    ) AS cartera_en_mora

FROM cuota_agg
GROUP BY cohort_date
ORDER BY cohort_date


);