WITH filtered_valid_orders AS (
    SELECT 
        order_id,
        customer_id,
        order_purchase_timestamp
    FROM 
        `brazilian-e-commerce-494206.Olist.orders`
    WHERE 
        DATE(order_purchase_timestamp) >= '2017-03-01' 
        AND DATE(order_purchase_timestamp) <= '2018-08-31'
        AND order_status NOT IN ('canceled', 'unavailable')
),
reference_date_calc AS (
    SELECT 
        DATE_ADD(MAX(DATE(order_purchase_timestamp)), INTERVAL 1 DAY) AS ref_date
    FROM 
        filtered_valid_orders
),
customer_raw_metrics AS (
    SELECT
        c.customer_unique_id,
        ARRAY_AGG(c.customer_state ORDER BY o.order_purchase_timestamp DESC LIMIT 1)[OFFSET(0)] AS customer_state,
        ARRAY_AGG(c.customer_city ORDER BY o.order_purchase_timestamp DESC LIMIT 1)[OFFSET(0)] AS customer_city,
        
        MAX(DATE(o.order_purchase_timestamp)) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(p.payment_value) AS monetary
    FROM
        `brazilian-e-commerce-494206.Olist.customers` AS c
    INNER JOIN
        filtered_valid_orders AS o 
        ON c.customer_id = o.customer_id
    INNER JOIN
        `brazilian-e-commerce-494206.Olist.order_payments` AS p 
        ON o.order_id = p.order_id
    GROUP BY
        1
)
SELECT
    crm.customer_unique_id,
    crm.customer_state,
    crm.customer_city,
    crm.last_purchase_date,
    DATE_DIFF(rd.ref_date, crm.last_purchase_date, DAY) AS recency,
    crm.frequency,
    crm.monetary,
    CASE 
        WHEN crm.frequency > 1 THEN 'Repeat Buyer' 
        ELSE 'One-off Buyer' 
    END AS retention_status
FROM
    customer_raw_metrics AS crm
CROSS JOIN
    reference_date_calc AS rd;