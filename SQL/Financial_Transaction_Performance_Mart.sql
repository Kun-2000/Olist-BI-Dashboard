SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    DATE(o.order_purchase_timestamp) AS purchase_date,
    FORMAT_DATE('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
    FORMAT_DATE('%Y-%W', o.order_purchase_timestamp) AS purchase_week,
    COALESCE(SUM(p.payment_value), 0) AS total_order_value,
    COUNT(DISTINCT p.payment_type) AS distinct_payment_methods,
    ARRAY_AGG(p.payment_type ORDER BY p.payment_value DESC, p.payment_sequential ASC LIMIT 1)[OFFSET(0)] AS primary_payment_type
FROM
    `brazilian-e-commerce-494206.Olist.orders` AS o
JOIN
    `brazilian-e-commerce-494206.Olist.order_payments` AS p
    ON o.order_id = p.order_id
WHERE
    DATE(o.order_purchase_timestamp) >= '2017-03-01' 
    AND DATE(o.order_purchase_timestamp) <= '2018-08-31'
    AND o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    1, 2, 3, 4, 5, 6;