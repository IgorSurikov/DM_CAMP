create or replace PACKAGE BODY pkg_etl_dim_products_dw AS

    PROCEDURE load_t_products AS
    BEGIN
        DECLARE BEGIN
            EXECUTE IMMEDIATE 'TRUNCATE TABLE t_products';
            INSERT INTO t_products
                SELECT
                    product_id,
                    product_code,
                    product_desc
                FROM
                    t_products_scd
                WHERE
                    valid_to IS NULL;

        END;
    END load_t_products;

    PROCEDURE load_t_products_scd AS
    BEGIN
        DECLARE
            TYPE product_scd_type IS RECORD (
                product_code      NUMBER,
                product_desc      VARCHAR2(200 BYTE),
                product_category  VARCHAR2(100 BYTE),
                product_brand     VARCHAR2(50 BYTE),
                product_discount  NUMBER,
                product_price     NUMBER,
                valid_from        DATE,
                valid_to          DATE,
                is_first          NUMBER
            );
            TYPE product_cur IS REF CURSOR RETURN product_scd_type;
            product_cv   product_cur;
            product_rec  product_scd_type;
        BEGIN
            OPEN product_cv FOR SELECT
                                    RANK()
                                    OVER(
                                        ORDER BY sa.product_desc
                                    )  product_code,
                                    sa.product_desc,
                                    sa.product_category,
                                    sa.product_brand,
                                    sa.product_discount,
                                    sa.product_price,
                                    sa.valid_from,
                                    LEAD(sa.valid_from)
                                    OVER(PARTITION BY sa.product_desc
                                         ORDER BY
                                             sa.valid_from
                                    )  valid_to,
                                    ROW_NUMBER()
                                    OVER(PARTITION BY sa.product_desc
                                         ORDER BY sa.valid_from
                                    )  is_first
                                FROM
                                    sa_products sa
                                    LEFT JOIN t_products_scd ON sa.product_desc = t_products_scd.product_desc
                                WHERE
                                    t_products_scd.product_desc IS NULL
                                ORDER BY
                                    product_desc;

            LOOP
                FETCH product_cv INTO product_rec;
                EXIT WHEN product_cv%notfound;
                IF product_rec.is_first = 1 THEN
                    INSERT INTO t_products_scd (
                        product_code,
                        product_desc,
                        product_category,
                        valid_from,
                        valid_to,
                        product_brand,
                        product_discount,
                        product_price,
                        insert_dt
                    ) VALUES (
                        product_rec.product_code,
                        product_rec.product_desc,
                        product_rec.product_category,
                        NULL,
                        product_rec.valid_from,
                        product_rec.product_brand,
                        floor(abs(dbms_random.normal() * 20 + 20)),
                        product_rec.product_price,
                        sysdate
                    );

                END IF;

                INSERT INTO t_products_scd (
                    product_code,
                    product_desc,
                    product_category,
                    valid_from,
                    valid_to,
                    product_brand,
                    product_discount,
                    product_price,
                    insert_dt
                ) VALUES (
                    product_rec.product_code,
                    product_rec.product_desc,
                    product_rec.product_category,
                    product_rec.valid_from,
                    product_rec.valid_to,
                    product_rec.product_brand,
                    product_rec.product_discount,
                    product_rec.product_price,
                    sysdate
                );

            END LOOP;

        END;
    END load_t_products_scd;

END pkg_etl_dim_products_dw;