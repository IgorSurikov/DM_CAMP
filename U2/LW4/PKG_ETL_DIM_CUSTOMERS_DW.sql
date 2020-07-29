create or replace PACKAGE BODY pkg_etl_dim_customers_dw AS

    PROCEDURE load_t_customers AS
    BEGIN
        DECLARE BEGIN
            MERGE INTO t_customers t
            USING sa_customers sa ON ( t.customer_name = sa.customer_name
                                       AND t.customer_surname = sa.customer_surname )
            WHEN MATCHED THEN UPDATE
            SET t.age = sa.age,
                t.gender = sa.gender,
                t.postal_code = sa.postal_code
            WHEN NOT MATCHED THEN
            INSERT (
                t.customer_name,
                t.customer_surname,
                t.age,
                t.gender,
                t.postal_code )
            VALUES
                ( sa.customer_name,
                  sa.customer_surname,
                  sa.age,
                  sa.gender,
                  sa.postal_code );

        END;
    END load_t_customers;

END pkg_etl_dim_customers_dw;