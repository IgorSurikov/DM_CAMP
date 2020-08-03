create or replace PACKAGE BODY pkg_etl_dim_customers_dw AS

    PROCEDURE load_t_customers AS
    BEGIN
        DECLARE BEGIN
            MERGE INTO t_customers t
            USING (
                      SELECT
                          sa.customer_name,
                          sa.customer_surname,
                          sa.age,
                          sa.gender,
                          sa.postal_code,
                          t.customer_name                                                                                                                              AS customer_name_t,
                          t.customer_surname                                                                                                                           AS customer_surname_t,
                          decode(sa.gender, t.gender, 1, 0) + decode(sa.postal_code, t.postal_code, 1, 0) + decode(sa.age, t.age,
                          1, 0)                                AS flag
                      FROM
                          sa_customers  sa
                          LEFT JOIN t_customers   t ON ( t.customer_name = sa.customer_name
                                                       AND t.customer_surname = sa.customer_surname )
                  )
            sa ON ( t.customer_name = sa.customer_name_t
                    AND t.customer_surname = sa.customer_surname_t )
            WHEN MATCHED THEN UPDATE
            SET t.age = sa.age,
                t.gender = sa.gender,
                t.postal_code = sa.postal_code,
                t.update_dt = decode(sa.flag, 3, t.update_dt, 2, sysdate,
                                     1, sysdate, 0,
                                     sysdate)
            WHEN NOT MATCHED THEN
            INSERT (
                t.customer_name,
                t.customer_surname,
                t.age,
                t.gender,
                t.postal_code,
                t.insert_dt,
                t.update_dt )
            VALUES
                ( sa.customer_name,
                  sa.customer_surname,
                  sa.age,
                  sa.gender,
                  sa.postal_code,
                  sysdate,
                  sysdate );

        END;
    END load_t_customers;

END pkg_etl_dim_customers_dw;