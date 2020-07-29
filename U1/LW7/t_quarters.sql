DROP TABLE t_quarters;

CREATE TABLE t_quarters
    AS
        ( SELECT DISTINCT
            to_number(to_char(end_of_cal_quarter, 'yyyy')
                      || to_char(end_of_cal_quarter, 'MM')
                      || to_char(end_of_cal_quarter, 'DD')
                      || '01')    AS quarter_id,
            days_in_cal_quarter,
            beg_of_cal_quarter,
            end_of_cal_quarter,
            calendar_quarter_number,
            'iso'       AS type
        FROM
            sa_calendar
        UNION ALL
        SELECT
            to_number(to_char(MAX(end_of_cal_month), 'yyyy')
                      || to_char(MAX(end_of_cal_month), 'MM')
                      || to_char(MAX(end_of_cal_month), 'DD')
                      || '02')                                                       AS quarter_id,
            trunc(MAX(end_of_cal_month) - MIN(end_of_cal_month))           AS days_in_cal_quarter,
            MIN(beg_of_cal_month)                                          AS beg_of_cal_quarter,
            MAX(end_of_cal_month)                                          AS end_of_cal_quarter,
            q                                                              AS calendar_quarter_number,
            'fin'                                                          AS type
        FROM
            (
                SELECT
                    beg_of_cal_month,
                    end_of_cal_month,
                    to_char(end_of_cal_month, 'Q')       AS q,
                    to_char(end_of_cal_month, 'YYYY')    AS calendar_year
                FROM
                    t_months
                WHERE
                    type = 'fin'
            ) temp
        GROUP BY
            q,
            calendar_year,
            'fin'
        );

ALTER TABLE t_quarters ADD CONSTRAINT quarter_id_pk PRIMARY KEY ( quarter_id );