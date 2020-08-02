create or replace PACKAGE BODY pkg_etl_dim_star AS

    PROCEDURE load_all_dim AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DIM_PERIODS';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DIM_CUSTOMERS';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DIM_GEO_LOCATION';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DIM_PRODUCTS_SCD';
        INSERT INTO dim_customers
            SELECT
                *
            FROM
                t_customers;

        INSERT INTO dim_periods
            SELECT
                *
            FROM
                t_periods;

        INSERT INTO dim_geo_location
            SELECT
                geo_id,
                level_code,
                country_id,
                country_code_a2,
                country_code_a3,
                country_desc,
                region_id,
                region_code,
                region_desc,
                region_childs,
                part_id,
                part_code,
                part_desc,
                part_childs,
                geo_system_id,
                geo_system_code,
                geo_system_desc,
                geo_system_childs
            FROM
                t_geo_location
            WHERE
                level_code = 'country';

        INSERT INTO dim_products_scd (
            product_id,
            product_code,
            product_desc,
            product_category,
            valid_from,
            valid_to,
            product_brand,
            product_discount,
            product_price,
            insert_dt
        )
            SELECT
                product_id,
                product_code,
                product_desc,
                product_category,
                valid_from,
                valid_to,
                product_brand,
                product_discount,
                product_price,
                insert_dt
            FROM
                t_products_scd;

        NULL;
    END load_all_dim;

END pkg_etl_dim_star;