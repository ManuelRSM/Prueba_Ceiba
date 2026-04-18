CREATE OR REPLACE TABLE prueba-maps-283720.analytics_fintrust.fct_loan_installments_payments AS(


WITH installments_numbered AS (
    SELECT
        loan_id,
        installment_id,
        ROW_NUMBER() OVER(PARTITION BY loan_id ORDER BY due_date) AS installment_number,
        principal_due,
        interest_due,
        installment_status,
        due_date
    FROM `prueba-maps-283720.staging_fintrust.installments`
)



SELECT
    C.customer_id,
    C.full_name,
    C.city,
    C.segment,
    C.monthly_income,
    L.loan_id,
    I.installment_id,
    I.installment_number,
    I.principal_due,
    I.interest_due,
    I.installment_status,
    I.due_date,
    P.payment_amount,
    P.payment_channel,
    P.payment_date,
    P.payment_status
FROM `prueba-maps-283720.staging_fintrust.customers` C
LEFT JOIN `prueba-maps-283720.staging_fintrust.loans` L
    ON C.customer_id = L.customer_id
LEFT JOIN installments_numbered I
    ON L.loan_id = I.loan_id
LEFT JOIN `prueba-maps-283720.staging_fintrust.payments` P
    ON I.installment_id = P.installment_id
ORDER BY
    C.customer_id, L.loan_id, I.installment_number, P.payment_date

);