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
    L.origination_date,
    L.principal_amount,
    I.installment_id,
    I.installment_number,
    I.principal_due,
    I.interest_due,
    I.principal_due + I.interest_due AS total_due,
    I.installment_status,
    I.due_date,
    P.payment_amount,
    CASE 
        WHEN P.payment_amount > (I.principal_due + I.interest_due ) 
        THEN P.payment_amount - (I.principal_due + I.interest_due ) 
        ELSE 0 
    END AS overpayment,
    GREATEST((principal_due + interest_due) - COALESCE(payment_amount, 0), 0) AS remaining_balance,--Esta opreación se utiliza para saber cuanto dinero quedo pendiente para el pago de la cuota
    P.payment_channel,
    P.payment_date,
    (CASE
        WHEN L.loan_id IS NULL THEN NULL
        WHEN P.payment_date IS NULL THEN 'NO_PAYMENT'
        WHEN P.payment_date <= I.due_date THEN 'ON_TIME'
        WHEN P.payment_date > I.due_date THEN 'LATE'
        WHEN L.loan_id IS NULL THEN NULL
        ELSE 'UNKNOWN'
    END) AS payment_timing,--Se usa para poder saber si el pago fue a tienpo o no
    P.payment_status,
    CASE
        WHEN L.loan_id IS NULL THEN NULL

        WHEN COALESCE(P.payment_amount, 0) >= (I.principal_due + I.interest_due) AND P.payment_status = 'CONFIRMED'
            THEN 'PAID'

        WHEN COALESCE((I.principal_due + I.interest_due) - P.payment_amount , 0) > 0 AND P.payment_status = 'CONFIRMED'
            THEN 'PARTIAL'

        WHEN COALESCE((I.principal_due + I.interest_due) - P.payment_amount , 0) = 0 
             AND (P.payment_date IS NULL)
            THEN 'OVERDUE'

        WHEN P.payment_status = 'REVERSED' THEN 'OVERDUE'

        ELSE 'PENDING'
    END AS installment_status_calc,
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

