create or replace PACKAGE BODY pkg_etl_dim_sales_dw AS

    PROCEDURE load_t_sales AS
    BEGIN
        DECLARE BEGIN
            EXECUTE IMMEDIATE 'TRUNCATE TABLE t_sales';
            INSERT /*+ PARALLEL */ INTO t_sales (
                event_dt,
                geo_id,
                customer_id,
                product_code,
                period_id,
                insert_dt,
                update_dt
            )
                SELECT
                    sa.event_dt      event_dt,
                    g.geo_id         geo_id,
                    c.customer_id    customer_id,
                    p.product_code     product_code,
                    ps.period_id     period_id,
                    sysdate,
                    sysdate
                FROM
                         sa_sales sa
                    INNER JOIN t_customers     c ON ( sa.customer_name = c.customer_name
                                                  AND sa.customer_surname = c.customer_surname )
                    INNER JOIN t_products      p ON ( sa.product_desc = p.product_desc )
                    INNER JOIN t_periods       ps ON ( sa.event_dt BETWEEN ps.beg_of_period AND ps.end_of_period )
                    INNER JOIN t_geo_location  g ON ( sa.country_desc = g.country_desc
                                                     AND g.level_code = 'country' );

        END;
    END load_t_sales;

END pkg_etl_dim_sales_dw;