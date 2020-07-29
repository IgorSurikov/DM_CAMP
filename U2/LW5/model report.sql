WITH etl AS (
    SELECT
        p.product_id          product_id,
        p.product_code        product_code,
        p.product_desc        product_desc,
        p.product_category    product_category,
        p.valid_from          valid_from,
        p.valid_to            valid_to,
        p.product_brand       product_brand,
        p.product_discount    product_discount,
        p.product_price       product_price,
        s.sale_id             sale_id,
        s.event_dt            event_dt
    FROM
             t_products_scd p
        INNER JOIN t_sales s ON s.product_code = p.product_code
                                AND s.event_dt BETWEEN nvl(p.valid_from, TO_DATE('2010/01/01', 'yyyy/mm/dd')) AND nvl(p.valid_to,
                                TO_DATE('2050/01/01', 'yyyy/mm/dd'))
)
SELECT /*+ PARALLEL(8) */ DISTINCT
    product_id,
    product_desc,
    to_char(product_discount) || ' %' as product_discount,
    result1  total_price,
    result2  clear_total_price
FROM
    etl
MODEL
    PARTITION BY ( product_id ) DIMENSION BY ( sale_id )
    MEASURES ( 0 result1, 0 result2,
    product_desc,
    product_price,
    product_discount )
    RULES
    ( result1[ANY]= SUM ( product_price )[ANY],
    result2[ANY]= SUM ( product_price )[ANY]* ( 100 - MAX ( product_discount )[ANY]) / 100 )
    --result1[NULL, FOR product_code IN (SELECT DISTINCT product_code FROM etl)] = sum(product_price)[ANY, cv(product_code)])
ORDER BY
    product_id