WITH mm_report AS (
    SELECT /*+ MATERIALIZE*/
                       trunc(sa_sales.event_dt, 'MM')        AS month,
        product_category,
        COUNT(*)                              AS number_of_products,
        SUM(product_price)                    AS summary_price
    FROM
             sa_sales
        INNER JOIN sa_products USING ( product_desc )
    GROUP BY
        trunc(sa_sales.event_dt, 'MM'),
        product_category
    ORDER BY
        1,
        3
)
SELECT
    decode(GROUPING(month), 1, '[All months]', month)                                     AS day,
    decode(GROUPING(product_category), 1, '[All categories]', product_category)           AS product_category,
    SUM(summary_price)
FROM
    mm_report mr
GROUP BY
    ROLLUP(month,
         product_category)
ORDER BY
    month