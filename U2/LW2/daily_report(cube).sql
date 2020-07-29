WITH dd_report AS (
    SELECT /*+ MATERIALIZE*/
                                                            trunc(sa_sales.event_dt)       AS day,
        product_category,
        COUNT(*)                       AS number_of_products,
        SUM(product_price)             AS summary_price
    FROM
             sa_sales
        INNER JOIN sa_products USING ( product_desc )
    GROUP BY
        trunc(sa_sales.event_dt),
        product_category
    ORDER BY
        1,
        3
)
SELECT
    decode(GROUPING(day), 1, '[All days]', day)                                           AS day,
    decode(GROUPING(product_category), 1, '[All categories]', product_category)           AS product_category,
    SUM(summary_price),
    decode(GROUPING_ID(day, product_category), 0, '0-row', 1, '1-group by day',
           2,
           '2-group by category',
           3,
           '3-Total')                                                                     AS info
FROM
    dd_report dr
GROUP BY
    CUBE(day,
         product_category)
ORDER BY
    info desc