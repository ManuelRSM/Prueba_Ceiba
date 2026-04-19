CREATE OR REPLACE VIEW prueba-maps-283720.vw_analytics_fintrust.vw_top_loans_delinquency AS(

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
),

cuotas_con_mora AS (
SELECT
    loan_id,
    installment_id,
    due_date,
    GREATEST(total_due - total_paid, 0) AS saldo_pendiente,
    DATE_DIFF((SELECT corte FROM fecha_corte), due_date, DAY) AS dias_atraso
FROM cuota_agg
WHERE 
    GREATEST(total_due - total_paid, 0) > 0
    AND due_date < (SELECT corte FROM fecha_corte)
)

SELECT
    loan_id,
    SUM(saldo_pendiente) AS saldo_total_pendiente,
    MAX(dias_atraso) AS max_dias_atraso
FROM cuotas_con_mora
GROUP BY loan_id
ORDER BY 
    max_dias_atraso DESC,
    saldo_total_pendiente DESC



);