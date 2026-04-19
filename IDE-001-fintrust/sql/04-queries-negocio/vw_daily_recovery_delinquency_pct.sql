CREATE OR REPLACE VIEW prueba-maps-283720.vw_analytics_fintrust.vw_daily_recovery_delinquency_pct AS ( 

SELECT
    payment_date,

    SUM(
        CASE 
            WHEN payment_status = 'CONFIRMED'
            THEN payment_amount
            ELSE 0
        END
    ) AS total_recaudo,

    SUM(
        CASE 
            WHEN payment_status = 'CONFIRMED'
                 AND payment_timing = 'LATE'
            THEN payment_amount
            ELSE 0
        END
    ) AS recaudo_mora,

    SAFE_DIVIDE(
        SUM(
            CASE 
                WHEN payment_status = 'CONFIRMED'
                     AND payment_timing = 'LATE'
                THEN payment_amount
                ELSE 0
            END
        ),
        SUM(
            CASE 
                WHEN payment_status = 'CONFIRMED'
                THEN payment_amount
                ELSE 0
            END
        )
    ) AS pct_recaudo_mora

FROM `prueba-maps-283720.analytics_fintrust.fct_loan_installments_payments`

WHERE payment_date IS NOT NULL

GROUP BY payment_date
ORDER BY payment_date

);
