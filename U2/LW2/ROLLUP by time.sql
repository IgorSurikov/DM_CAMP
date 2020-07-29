SELECT
    decode(GROUPING(trunc(sa_sales.event_dt)), 1, '[All days]', trunc(sa_sales.event_dt))                     AS day,
    COUNT(*)                                                                                                  AS number_of_products,
    to_char(SUM(product_price))
    || ' $'                                                                                                   AS summary_price
FROM
         sa_sales
    INNER JOIN sa_products USING ( product_desc )
GROUP BY
    ROLLUP(trunc(sa_sales.event_dt))
ORDER BY
    day;

SELECT
    decode(GROUPING(trunc(sa_sales.event_dt, 'MM')), 1, '[All months]', to_char(trunc(sa_sales.event_dt, 'MM'), 'FMMonth , YYYY'))                           AS
    month,
    COUNT(*)                                                                                                                                                 AS number_of_products,
    to_char(SUM(product_price))
    || ' $'                                                                                                                                                  AS summary_price
FROM
         sa_sales
    INNER JOIN sa_products USING ( product_desc )
GROUP BY
    ROLLUP(trunc(sa_sales.event_dt, 'MM'))
ORDER BY
    month;

SELECT
    decode(GROUPING(trunc(sa_sales.event_dt, 'Q')), 1, '[All quarters]', to_char(trunc(sa_sales.event_dt, 'Q'), 'Q , YYYY'))                           AS quarter,
    COUNT(*)                                                                                                                                           AS number_of_products,
    to_char(SUM(product_price))
    || ' $'                                                                                                                                            AS summary_price
FROM
         sa_sales
    INNER JOIN sa_products USING ( product_desc )
GROUP BY
    ROLLUP(trunc(sa_sales.event_dt, 'Q'))
ORDER BY
    quarter;

SELECT
    decode(GROUPING(trunc(sa_sales.event_dt, 'YYYY')), 1, '[All years]', to_char(trunc(sa_sales.event_dt, 'YYYY'), 'YYYY'))                           AS year,
    COUNT(*)                                                                                                                                          AS number_of_products,
    to_char(SUM(product_price))
    || ' $'                                                                                                                                           AS summary_price
FROM
         sa_sales
    INNER JOIN sa_products USING ( product_desc )
GROUP BY
    ROLLUP(trunc(sa_sales.event_dt, 'YYYY'))
ORDER BY
    year










