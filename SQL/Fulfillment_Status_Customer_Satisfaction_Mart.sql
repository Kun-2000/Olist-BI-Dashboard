WITH valid_orders AS (
    SELECT 
        order_id, 
        customer_id, 
        order_purchase_timestamp,
        DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY) AS total_actual_lead_time_days,
        DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) AS delay_days,
        IF(DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) > 0, 1, 0) AS is_delayed,
        DATE_DIFF(DATE(order_delivered_carrier_date), DATE(order_purchase_timestamp), DAY) AS seller_lead_time_days,
        DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_delivered_carrier_date), DAY) AS carrier_transit_time_days  
    FROM `brazilian-e-commerce-494206.Olist.orders`
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_approved_at IS NOT NULL
      AND order_delivered_carrier_date IS NOT NULL
      AND DATE_DIFF(DATE(order_delivered_carrier_date), DATE(order_purchase_timestamp), DAY) >= 0
      AND DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_delivered_carrier_date), DAY) >= 0
      AND DATE(order_purchase_timestamp) BETWEEN '2017-03-01' AND '2018-08-31'
),
review_metrics AS (
    SELECT 
        order_id, 
        MIN(review_score) AS review_score
    FROM `brazilian-e-commerce-494206.Olist.order_reviews`
    GROUP BY order_id
),
customer_locations AS (
    SELECT 
        customer_id,
        customer_state
    FROM `brazilian-e-commerce-494206.Olist.customers`
),
seller_locations AS (
    SELECT 
        seller_id,
        seller_state
    FROM `brazilian-e-commerce-494206.Olist.sellers`
)
SELECT 
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    DATE(vo.order_purchase_timestamp) AS purchase_date,
    oi.price AS item_price,
    oi.freight_value AS item_freight_value,
    (oi.price + oi.freight_value) AS item_total_value,
    SAFE_DIVIDE(oi.freight_value, (oi.price + oi.freight_value)) AS item_freight_ratio,
    sl.seller_state,
    cl.customer_state,
    IF(sl.seller_state != cl.customer_state, 1, 0) AS is_cross_state,
    vo.total_actual_lead_time_days,
    vo.seller_lead_time_days,
    vo.carrier_transit_time_days,
    vo.delay_days,
    vo.is_delayed,
    rm.review_score
FROM `brazilian-e-commerce-494206.Olist.order_items` AS oi
INNER JOIN valid_orders AS vo 
    ON oi.order_id = vo.order_id
LEFT JOIN review_metrics AS rm 
    ON oi.order_id = rm.order_id
LEFT JOIN customer_locations AS cl 
    ON vo.customer_id = cl.customer_id
LEFT JOIN seller_locations AS sl 
    ON oi.seller_id = sl.seller_id;