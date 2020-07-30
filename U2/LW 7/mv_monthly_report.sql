CREATE MATERIALIZED VIEW mv_monthly_report
    BUILD IMMEDIATE
    REFRESH
        COMPLETE
        ON DEMAND
ENABLE QUERY REWRITE AS
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
        decode(GROUPING(month), 1, '[All months]', to_char(month, 'FMMonth , YYYY'))               AS calendar_month,
        decode(GROUPING(product_category), 1, '[All categories]', product_category)                AS product_category,
        SUM(summary_price)                                                                         AS sum
    FROM
        mm_report mr
    GROUP BY
        ROLLUP(month,
               product_category)
    ORDER BY
        month DESC,
        GROUPING(mr.product_category) DESC;
        
BEGIN
dbms_mview.refresh('MV_MONTHLY_REPORT', 'C');
END;        
        
