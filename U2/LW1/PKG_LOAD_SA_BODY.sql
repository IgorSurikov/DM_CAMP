create or replace PACKAGE BODY pkg_load_sa AS

    PROCEDURE load_sa_calendar AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE sa_calendar';
        INSERT INTO sa_calendar
            SELECT
                trunc(sd + rn)                                                                    time_id,
                to_char(sd + rn, 'fmDay')                                                         day_name,
                to_char(sd + rn, 'D')                                                             day_number_in_week,
                to_char(sd + rn, 'DD')                                                            day_number_in_month,
                to_char(sd + rn, 'DDD')                                                           day_number_in_year,
                to_char(sd + rn, 'W')                                                             calendar_week_number,
                (
                    CASE
                        WHEN to_char(sd + rn, 'D') IN ( 1, 2, 3, 4, 5,
                                                        6 ) THEN
                            next_day(sd + rn, '¬Œ— –≈—≈Õ‹≈')
                        ELSE
                            ( sd + rn )
                    END
                )                                                                                 week_ending_date,
                to_char(sd + rn, 'MM')                                                            calendar_month_number,
                to_char(last_day(sd + rn), 'DD')                                                  days_in_cal_month,
                last_day(sd + rn)                                                                 end_of_cal_month,
                to_char(sd + rn, 'FMMonth')                                                       calendar_month_name,
                ( (
                    CASE
                        WHEN to_char(sd + rn, 'Q') = 1      THEN
                            to_date('03/31/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                        WHEN to_char(sd + rn, 'Q') = 2      THEN
                            to_date('06/30/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                        WHEN to_char(sd + rn, 'Q') = 3      THEN
                            to_date('09/30/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                        WHEN to_char(sd + rn, 'Q') = 4      THEN
                            to_date('12/31/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    END
                ) - trunc(sd + rn, 'Q') + 1 )                                                     days_in_cal_quarter,
                trunc(sd + rn, 'Q')                                                               beg_of_cal_quarter,
                (
                    CASE
                        WHEN to_char(sd + rn, 'Q') = 1      THEN
                            to_date('03/31/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                        WHEN to_char(sd + rn, 'Q') = 2      THEN
                            to_date('06/30/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                        WHEN to_char(sd + rn, 'Q') = 3      THEN
                            to_date('09/30/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                        WHEN to_char(sd + rn, 'Q') = 4      THEN
                            to_date('12/31/'
                                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    END
                )                                                                                 end_of_cal_quarter,
                to_char(sd + rn, 'Q')                                                             calendar_quarter_number,
                to_char(sd + rn, 'YYYY')                                                          calendar_year,
                ( to_date('12/31/'
                          || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY') - trunc(sd + rn, 'YEAR') )             days_in_cal_year,
                trunc(sd + rn, 'YEAR')                                                            beg_of_cal_year,
                to_date('12/31/'
                        || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')                                        end_of_cal_year
            FROM
                (
                    SELECT
                        TO_DATE('12/31/2018', 'MM/DD/YYYY')      sd,
                        ROWNUM                                   rn
                    FROM
                        dual
                    CONNECT BY
                        level <= 2190
      --2190 works better
                                                                                              );

    END load_sa_calendar;

    PROCEDURE load_sa_sales AS
    BEGIN
        DECLARE
            l_ran_time    TIMESTAMP;
            product_raw   sa_products%rowtype;
            customer_raw  sa_customers%rowtype;
            geo_raw       dim_geo_location%rowtype;
            CURSOR get_geo_raw IS
            SELECT
                *
            FROM
                (
                    SELECT
                        *
                    FROM
                        dim_geo_location SAMPLE ( 80 )
                    ORDER BY
                        dbms_random.value
                )
            WHERE
                ROWNUM <= 1;

            CURSOR get_customer_raw IS
            SELECT
                *
            FROM
                (
                    SELECT
                        *
                    FROM
                        sa_customers SAMPLE ( 0.01 )
                    ORDER BY
                        dbms_random.value
                )
            WHERE
                ROWNUM <= 1;

            CURSOR get_product_raw IS
            SELECT
                *
            FROM
                (
                    SELECT
                        *
                    FROM
                        sa_products SAMPLE ( 0.1 )
                    ORDER BY
                        dbms_random.value
                )
            WHERE
                ROWNUM <= 1;

        BEGIN
            FOR i IN 1..100000 LOOP
                SELECT
                    to_date(trunc(dbms_random.value(to_char(DATE '2019-01-01', 'J'), to_char(DATE '2024-12-20', 'J'))), 'J') + dbms_random.
                    value
                INTO l_ran_time
                FROM
                    dual;

                OPEN get_product_raw;
                OPEN get_customer_raw;
                OPEN get_geo_raw;
                FETCH get_product_raw INTO product_raw;
                FETCH get_customer_raw INTO customer_raw;
                FETCH get_geo_raw INTO geo_raw;
                INSERT INTO sa_sales VALUES (
                    customer_raw.customer_name,
                    customer_raw.customer_surname,
                    geo_raw.country_desc,
                    product_raw.product_desc,
                    l_ran_time
                );

                CLOSE get_product_raw;
                CLOSE get_customer_raw;
                CLOSE get_geo_raw;
            END LOOP;

        END;
    END load_sa_sales;

    PROCEDURE load_sa_periods AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE sa_periods';
        INSERT INTO sa_periods VALUES (
            'Founding stage',
            TO_DATE('2019/01/01', 'yyyy/mm/dd'),
            TO_DATE('2019/06/01', 'yyyy/mm/dd')
        );

        INSERT INTO sa_periods VALUES (
            'Zero exit stage',
            TO_DATE('2019/06/02', 'yyyy/mm/dd'),
            TO_DATE('2020/01/01', 'yyyy/mm/dd')
        );

        INSERT INTO sa_periods VALUES (
            'Growth stage',
            TO_DATE('2020/01/02', 'yyyy/mm/dd'),
            TO_DATE('2022/01/01', 'yyyy/mm/dd')
        );

        INSERT INTO sa_periods VALUES (
            'Maturity stage',
            TO_DATE('2022/01/02', 'yyyy/mm/dd'),
            TO_DATE('2050/01/02', 'yyyy/mm/dd')
        );

    END load_sa_periods;

    PROCEDURE load_sa_products AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE sa_products';
        INSERT INTO sa_products
            SELECT /*+ parallel(8) */
                                                    product_desc,
                product_category,
                valid_from,
                product_brand,
                discount  AS product_discount,
                price     AS product_price
            FROM
                     (
                    SELECT
                        ROWNUM                                          AS rn,
                        round(dbms_random.value(10, 500), 2)            AS price
                    FROM
                        dual
                    CONNECT BY
                        level <= 9740
                ) prices
                INNER JOIN (
                    SELECT
                        ROWNUM                                                AS rn,
                        floor(abs(dbms_random.normal() * 20 + 20))            AS discount
                    FROM
                        dual
                    CONNECT BY
                        level <= 9740
                )  discounts ON prices.rn = discounts.rn
                INNER JOIN (
                    SELECT
                        ROWNUM         AS rn,
                        to_date(trunc(dbms_random.value(to_char(DATE '2019-01-01', 'J'), to_char(DATE '2024-12-20', 'J'))),
                                'J')   AS valid_from
                    FROM
                        dual
                    CONNECT BY
                        level <= 9740
                )  dates ON prices.rn = dates.rn
                INNER JOIN (
                    SELECT
                        ROWNUM AS rn,
                        s.*
                    FROM
                        sa_shoes s
                )  sh ON sh.rn = prices.rn;

        DELETE FROM sa_products
        WHERE
            ROWID IN (
                SELECT
                    rid
                FROM
                    (
                        SELECT
                            t.rowid      rid,
                            ROW_NUMBER()
                            OVER(PARTITION BY product_desc
                                 ORDER BY product_desc
                            )  rn
                        FROM
                            sa_products t
                    )
                WHERE
                    rn > 1
            );

        DELETE FROM sa_products
        WHERE
            product_category IN (
                SELECT
                    product_category
                FROM
                    sa_products
                GROUP BY
                    product_category
                HAVING
                    COUNT(*) < 5
            );

    END load_sa_products;

    PROCEDURE load_sa_customers AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE sa_customers';
        INSERT INTO sa_customers
            SELECT
                name,
                surname,
                age,
                gender,
                postal_code
            FROM
                     (
                    SELECT /*+ parallel(8) */
                                                        s1.name    AS name,
                        s2.name    AS surname,
                        ROWNUM     AS rn
                    FROM
                        sa_names  s1,
                        sa_names  s2
                    WHERE
                        ROWNUM <= 100000
                ) names
                INNER JOIN (
                    SELECT
                        ROWNUM                                     AS rn,
                        floor(dbms_random.value(18, 90))           AS age
                    FROM
                        dual
                    CONNECT BY
                        level <= 100000
                )  ages ON names.rn = ages.rn
                INNER JOIN (
                    SELECT
                        ROWNUM  AS rn,
                        CASE floor(dbms_random.value(0, 2))
                            WHEN 1  THEN
                                'male'
                            WHEN 0  THEN
                                'female'
                        END     AS gender
                    FROM
                        dual
                    CONNECT BY
                        level <= 100000
                )  gender ON names.rn = gender.rn
                INNER JOIN (
                    SELECT
                        ROWNUM                                            AS rn,
                        floor(dbms_random.value(10000, 100000))           AS postal_code
                    FROM
                        dual
                    CONNECT BY
                        level <= 100000
                )  postal_code ON names.rn = postal_code.rn
            ORDER BY
                dbms_random.value;

    END load_sa_customers;

END pkg_load_sa;