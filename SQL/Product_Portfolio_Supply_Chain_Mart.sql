SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    DATE(o.order_purchase_timestamp) AS purchase_date,
    oi.price AS item_price,
    oi.freight_value AS item_freight,
    (oi.price + oi.freight_value) AS item_total_value,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    s.seller_city,
    s.seller_state
FROM
    `brazilian-e-commerce-494206.Olist.order_items` AS oi
INNER JOIN
    `brazilian-e-commerce-494206.Olist.orders` AS o 
    ON oi.order_id = o.order_id
LEFT JOIN
    `brazilian-e-commerce-494206.Olist.products` AS p 
    ON oi.product_id = p.product_id
LEFT JOIN
    `brazilian-e-commerce-494206.Olist.product_category_name_translation` AS t 
    ON p.product_category_name = t.product_category_name
LEFT JOIN
    `brazilian-e-commerce-494206.Olist.sellers` AS s 
    ON oi.seller_id = s.seller_id
WHERE
    DATE(o.order_purchase_timestamp) >= '2017-03-01' 
    AND DATE(o.order_purchase_timestamp) <= '2018-08-31'
    AND o.order_status NOT IN ('canceled', 'unavailable');