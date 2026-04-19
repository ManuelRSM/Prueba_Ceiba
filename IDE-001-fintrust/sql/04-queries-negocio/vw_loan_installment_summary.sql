CREATE OR REPLACE VIEW prueba-maps-283720.vw_analytics_fintrust.vw_loan_installment_summary AS(

WITH payments_agg AS (
SELECT
    installment_id,
    SUM(CASE WHEN payment_status = 'CONFIRMED' THEN payment_amount ELSE 0 END) AS total_paid
FROM `prueba-maps-283720.analytics_fintrust.fct_loan_installments_payments`
GROUP BY installment_id
)

SELECT
    C.customer_id,
    C.full_name,
    C.city,
    C.segment,

    L.loan_id,
    L.origination_date,
    L.principal_amount,

    I.installment_id,
    I.installment_number,
    I.due_date,

    (I.principal_due + I.interest_due) AS total_due,
    COALESCE(P.total_paid, 0) AS total_paid,

    GREATEST((I.principal_due + I.interest_due) - COALESCE(P.total_paid, 0), 0) AS remaining_balance,

    CASE 
        WHEN COALESCE(P.total_paid, 0) > (I.principal_due + I.interest_due)
        THEN COALESCE(P.total_paid, 0) - (I.principal_due + I.interest_due)
        ELSE 0
    END AS overpayment,

    CASE 
        WHEN GREATEST((I.principal_due + I.interest_due) - COALESCE(P.total_paid, 0), 0) = 0
            THEN 'PAID'
        WHEN I.due_date < CURRENT_DATE()
            THEN 'OVERDUE'
        ELSE 'PENDING'
    END AS installment_status_final,

    CASE 
        WHEN I.due_date < CURRENT_DATE() THEN TRUE
        ELSE FALSE
    END AS is_overdue

FROM `prueba-maps-283720.staging_fintrust.installments` I

LEFT JOIN `prueba-maps-283720.staging_fintrust.loans` L
    ON I.loan_id = L.loan_id

LEFT JOIN `prueba-maps-283720.staging_fintrust.customers` C
    ON L.customer_id = C.customer_id

LEFT JOIN payments_agg P
    ON I.installment_id = P.installment_id


);