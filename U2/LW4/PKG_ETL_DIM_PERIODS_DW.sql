create or replace PACKAGE BODY pkg_etl_dim_periods_dw AS

    PROCEDURE load_t_periods AS
    BEGIN
        DECLARE
            TYPE periods_type IS
                TABLE OF sa_periods%rowtype INDEX BY PLS_INTEGER;
            list_periods    periods_type;
            list_t_periods  periods_type;
            list_result     periods_type;
            k               NUMBER;
            CURSOR cur_sa_periods IS
            SELECT
                *
            FROM
                sa_periods;

            CURSOR cur_t_periods IS
            SELECT
                period_name,
                beg_of_period,
                end_of_period
            FROM
                t_periods;

            FUNCTION find_period (
                i IN NUMBER
            ) RETURN NUMBER AS
                idx NUMBER;
            BEGIN
                idx := NULL;
                FOR j IN 1..list_t_periods.count LOOP
                    IF (
                        list_periods(i).period_name = list_t_periods(j).period_name
                        AND list_periods(i).beg_of_period = list_t_periods(j).beg_of_period
                        AND list_periods(i).end_of_period = list_t_periods(j).end_of_period
                    ) THEN
                        idx := -1;
                    ELSIF ( list_periods(i).period_name = list_t_periods(j).period_name ) THEN
                        idx := j;
                        EXIT;
                    END IF;
                END LOOP;

                RETURN idx;
            END;

        BEGIN
            OPEN cur_sa_periods;
            FETCH cur_sa_periods BULK COLLECT INTO list_periods;
            CLOSE cur_sa_periods;
            OPEN cur_t_periods;
            FETCH cur_t_periods BULK COLLECT INTO list_t_periods;
            CLOSE cur_t_periods;
            FOR i IN 1..list_periods.count LOOP
                k := find_period(i);
                IF k = -1 THEN
                    CONTINUE;
                END IF;
                IF k IS NULL THEN
                    INSERT INTO t_periods (
                        period_name,
                        beg_of_period,
                        end_of_period,
                        days_in_period,
                        months_in_period,
                        insert_dt,
                        update_dt
                    ) VALUES (
                        list_periods(i).period_name,
                        list_periods(i).beg_of_period,
                        list_periods(i).end_of_period,
                        to_number(trunc(list_periods(i).end_of_period - list_periods(i).beg_of_period)),
                        floor(months_between(list_periods(i).end_of_period, list_periods(i).beg_of_period)),
                        sysdate,
                        sysdate
                    );

                ELSE
                    dbms_output.put_line('test');
                    UPDATE t_periods
                    SET
                        beg_of_period = list_periods(i).beg_of_period,
                        end_of_period = list_periods(i).end_of_period,
                        days_in_period = to_number(trunc(list_periods(i).end_of_period - list_periods(i).beg_of_period)),
                        months_in_period = floor(months_between(list_periods(i).end_of_period, list_periods(i).beg_of_period)),
                        update_dt = sysdate
                    WHERE
                        period_name = list_t_periods(k).period_name;

                END IF;

            END LOOP;

        END;
    END load_t_periods;

END pkg_etl_dim_periods_dw;