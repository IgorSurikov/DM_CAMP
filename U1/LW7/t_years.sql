DROP TABLE t_years;

CREATE TABLE t_years
    AS
        ( SELECT DISTINCT
            to_number(to_char(end_of_cal_year, 'yyyy')
                      || to_char(end_of_cal_year, 'MM')
                      || to_char(end_of_cal_year, 'DD')
                      || '01')    AS year_id,
            calendar_year,
            days_in_cal_year,
            beg_of_cal_year,
            end_of_cal_year,
            'iso'       AS type
        FROM
            sa_calendar
        UNION ALL
        SELECT
            to_number(to_char(MAX(end_of_cal_quarter), 'yyyy')
                      || to_char(MAX(end_of_cal_quarter), 'MM')
                      || to_char(MAX(end_of_cal_quarter), 'DD')
                      || '02')                                                           AS year_id,
            calendar_year,
            trunc(MAX(end_of_cal_quarter) - MIN(beg_of_cal_quarter))           AS days_in_cal_quarter,
            MIN(beg_of_cal_quarter)                                            AS beg_of_cal_year,
            MAX(end_of_cal_quarter)                                            AS end_of_cal_year,
            'fin'                                                              AS type
        FROM
            (
                SELECT
                    beg_of_cal_quarter,
                    end_of_cal_quarter,
                    to_char(end_of_cal_quarter, 'YYYY') AS calendar_year
                FROM
                    t_quarters
                WHERE
                    type = 'fin'
            ) temp
        GROUP BY
            calendar_year,
            'fin'
        );

ALTER TABLE t_years ADD CONSTRAINT year_id_pk PRIMARY KEY ( year_id );