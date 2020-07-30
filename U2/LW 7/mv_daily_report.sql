CREATE MATERIALIZED VIEW mv_daily_report
    BUILD DEFERRED
    REFRESH
        COMPLETE
        ON COMMIT
ENABLE QUERY REWRITE AS
    SELECT
        trunc(sa_sales.event_dt)       AS day,
        product_category,
        COUNT(*)                       AS number_of_products,
        SUM(product_price)             AS summary_price
    FROM
             sa_sales
        INNER JOIN sa_products USING ( product_desc )
    GROUP BY
        trunc(sa_sales.event_dt),
        product_category;