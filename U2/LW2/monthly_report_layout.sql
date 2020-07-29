SELECT
    trunc(sa_sales.event_dt, 'MM')         AS month,
    product_category,
    COUNT(*)                              AS number_of_products,
    to_char(SUM(product_price))
    || ' $'                               AS summary_price
FROM
         sa_sales
    INNER JOIN sa_products USING ( product_desc )
GROUP BY
    trunc(sa_sales.event_dt, 'MM'),
    product_category
ORDER BY
    1,
    3