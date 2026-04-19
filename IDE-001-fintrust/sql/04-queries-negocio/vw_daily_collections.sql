CREATE OR REPLACE VIEW prueba-maps-283720.vw_analytics_fintrust.vw_daily_collections AS(

SELECT
    payment_date,

    -- recaudo total del día
    SUM(
        CASE 
            WHEN payment_status = 'CONFIRMED' 
            THEN payment_amount 
            ELSE 0 
        END
    ) AS total_recaudo,

    -- recaudo aplicado a cuotas en mora
    SUM(
        CASE 
            WHEN payment_status = 'CONFIRMED'
                 AND installment_status_calc = 'PARTIAL'
            THEN payment_amount 
            ELSE 0 
        END
    ) AS recaudo_mora

FROM `prueba-maps-283720.analytics_fintrust.fct_loan_installments_payments`

WHERE payment_date IS NOT NULL

GROUP BY payment_date
ORDER BY payment_date


);
