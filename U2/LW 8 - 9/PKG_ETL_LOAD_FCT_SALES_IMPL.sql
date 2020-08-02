create or replace PACKAGE BODY pkg_etl_load_fct_sales AS

    PROCEDURE load_fct_sales_dd AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE fct_sales_dd';
        INSERT INTO fct_sales_dd (
            event_dt,
            geo_id,
            customer_id,
            product_id,
            period_id,
            sales_quantity,
            sale_amount,
            insert_dt,
            update_dt
        )
            WITH temp AS (
                SELECT
                    s.sale_id                                             sale_id,
                    s.event_dt                                            event_dt,
                    s.geo_id                                              geo_id,
                    s.customer_id                                         customer_id,
                    s.product_code                                        product_code,
                    s.period_id                                           period_id,
                    p.product_id                                          product_id,
                    ( ( 100 - product_discount ) / 100 ) * product_price  AS sale_amount
                FROM
                         t_sales s
                    INNER JOIN t_products      p ON s.product_code = p.product_code
                    INNER JOIN t_products_scd  scd ON scd.product_id = p.product_id
            )
            SELECT
                trunc(event_dt)         AS event_dt,
                geo_id,
                customer_id,
                product_id,
                period_id,
                COUNT(product_code)     AS quantity,
                SUM(sale_amount)        AS sale_amount,
                sysdate,
                sysdate
            FROM
                temp
            GROUP BY
                trunc(event_dt),
                event_dt,
                geo_id,
                customer_id,
                product_code,
                product_id,
                period_id,
                sysdate;

    END load_fct_sales_dd;

    PROCEDURE load_fct_sales_dd_slow AS
    BEGIN
        DECLARE
            c_sales_dw  SYS_REFCURSOR;
            fct_sale    fct_sales_dd%rowtype;
            TYPE c_sales_dw_type IS RECORD (
                event_dt          DATE,
                geo_id            NUMBER(22, 0),
                customer_id       NUMBER(22, 0),
                product_id        NUMBER(22, 0),
                period_id         NUMBER,
                sales_quantity    NUMBER,
                sale_amount       NUMBER(22, 0),
                sale_id           NUMBER,
                event_dt_f        TIMESTAMP(6),
                geo_id_f          NUMBER,
                customer_id_f     NUMBER,
                product_id_f      NUMBER,
                period_id_f       NUMBER,
                sales_quantity_f  NUMBER,
                sale_amount_f     NUMBER(22, 0)
            );
            sale_dw     c_sales_dw_type;
        BEGIN
            OPEN c_sales_dw FOR SELECT
                                    temp.event_dt       event_dt,
                                    temp.geo_id         geo_id,
                                    temp.customer_id    customer_id,
                                    temp.product_id     product_id,
                                    temp.period_id      period_id,
                                    temp.quantity       sales_quantity,
                                    temp.sale_amount    sale_amount,
                                    f.sale_id,
                                    f.event_dt          event_dt_f,
                                    f.geo_id            geo_id_f,
                                    f.customer_id       customer_id_f,
                                    f.product_id        product_id_f,
                                    f.period_id         period_id_f,
                                    f.sales_quantity    sale_quantity_f,
                                    f.sale_amount       sale_amount_f
                                FROM
                                    (
                                        WITH temp AS (
                                            SELECT
                                                s.sale_id                                             sale_id,
                                                s.event_dt                                            event_dt,
                                                s.geo_id                                              geo_id,
                                                s.customer_id                                         customer_id,
                                                s.product_code                                        product_code,
                                                s.period_id                                           period_id,
                                                p.product_id                                          product_id,
                                                ( ( 100 - product_discount ) / 100 ) * product_price  AS sale_amount
                                            FROM
                                                     t_sales s
                                                INNER JOIN t_products      p ON s.product_code = p.product_code
                                                INNER JOIN t_products_scd  scd ON scd.product_id = p.product_id
                                        )
                                        SELECT
                                            trunc(event_dt)         AS event_dt,
                                            geo_id,
                                            customer_id,
                                            product_id,
                                            period_id,
                                            COUNT(product_code)     AS quantity,
                                            SUM(sale_amount)        AS sale_amount
                                        FROM
                                            temp
                                        GROUP BY
                                            trunc(event_dt),
                                            event_dt,
                                            geo_id,
                                            customer_id,
                                            product_code,
                                            product_id,
                                            period_id
                                    )             temp
                                    LEFT JOIN fct_sales_dd  f ON ( temp.event_dt = f.event_dt
                                                                  AND temp.geo_id = f.geo_id
                                                                  AND temp.customer_id = f.customer_id
                                                                  AND temp.product_id = f.product_id
                                                                  AND temp.period_id = f.period_id );

            LOOP
                FETCH c_sales_dw INTO sale_dw;
                EXIT WHEN c_sales_dw%notfound;
                IF sale_dw.sale_id IS NULL THEN
                    INSERT INTO fct_sales_dd (
                        event_dt,
                        geo_id,
                        customer_id,
                        product_id,
                        period_id,
                        sales_quantity,
                        sale_amount,
                        insert_dt,
                        update_dt
                    ) VALUES (
                        sale_dw.event_dt,
                        sale_dw.geo_id,
                        sale_dw.customer_id,
                        sale_dw.product_id,
                        sale_dw.period_id,
                        sale_dw.sales_quantity,
                        sale_dw.sale_amount,
                        sysdate,
                        sysdate
                    );

                ELSE
                    SELECT
                        *
                    INTO fct_sale
                    FROM
                        fct_sales_dd
                    WHERE
                        sale_id = sale_dw.sale_id;

                    IF ( ( fct_sale.sales_quantity <> sale_dw.sales_quantity ) OR ( fct_sale.sale_amount <> sale_dw.sale_amount ) )
                    THEN
                        UPDATE fct_sales_dd
                        SET
                            sales_quantity = sale_dw.sales_quantity,
                            sale_amount = sale_dw.sale_amount,
                            update_dt = sysdate
                        WHERE
                            sale_id = sale_dw.sale_id;

                    END IF;

                END IF;

            END LOOP;

        END;
    END load_fct_sales_dd_slow;

END pkg_etl_load_fct_sales;