create or replace PACKAGE BODY pkg_etl_dim_periods_dw AS

    PROCEDURE load_t_periods AS
    BEGIN
        DECLARE
            TYPE periods_type IS
                TABLE OF sa_periods%rowtype INDEX BY PLS_INTEGER;
            list_periods periods_type;
            CURSOR cur_sa_periods IS
            SELECT
                *
            FROM
                sa_periods;

        BEGIN
            EXECUTE IMMEDIATE 'TRUNCATE TABLE T_PERIODS';
            OPEN cur_sa_periods;
            FETCH cur_sa_periods BULK COLLECT INTO list_periods;
            CLOSE cur_sa_periods;
            FORALL l_index IN list_periods.first..list_periods.last
                INSERT INTO t_periods (
                    period_name,
                    beg_of_period,
                    end_of_period,
                    days_in_period,
                    months_in_period
                ) VALUES (
                    list_periods(l_index).period_name,
                    list_periods(l_index).beg_of_period,
                    list_periods(l_index).end_of_period,
                    to_number(trunc(list_periods(l_index).end_of_period - list_periods(l_index).beg_of_period)),
                    floor(months_between(list_periods(l_index).end_of_period, list_periods(l_index).beg_of_period))
                );

        END;
    END load_t_periods;

END pkg_etl_dim_periods_dw;