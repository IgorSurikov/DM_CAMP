DROP TABLE t_months;

CREATE TABLE t_months
    AS
        ( SELECT DISTINCT
            to_number(to_char(end_of_cal_month, 'yyyy')
                      || to_char(end_of_cal_month, 'MM')
                      || to_char(end_of_cal_month, 'DD')
                      || '01')                  AS month_id,
            calendar_month_number,
            days_in_cal_month,
            trunc(time_id, 'mm')      AS beg_of_cal_month,
            end_of_cal_month,
            calendar_month_name,
            'iso'                     AS type
        FROM
            sa_calendar
        UNION ALL
        SELECT
            to_number(to_char(MAX(m.end_of_cal_month), 'yyyy')
                      || to_char(MAX(m.end_of_cal_month), 'MM')
                      || to_char(MAX(m.end_of_cal_month), 'DD')
                      || '02')                                                                        AS month_id,
            to_char(MAX(m.end_of_cal_month), 'MM')                                          AS calendar_month_number,
            to_char(trunc(MAX(m.end_of_cal_month) - MIN(m.week_beg_date)))                  AS days_in_cal_month,
            MIN(m.week_beg_date)                                                            AS beg_of_cal_month,
            MAX(m.end_of_cal_month)                                                         AS end_of_cal_month,
            m.calendar_month_name,
            'fin'                                                                           AS type
        FROM
            (
                SELECT
                    trunc(time_id, 'DAY')                     AS week_beg_date,
                    to_char(week_ending_date, 'YYYY')         AS calendar_year,
                    to_char(week_ending_date, 'MM')           AS calendar_month_number,
                    week_ending_date                          AS end_of_cal_month,
                    to_char(week_ending_date, 'FMMonth')      AS calendar_month_name,
                    'fin'                                     AS type
                FROM
                    sa_calendar
            ) m
        GROUP BY
            m.calendar_month_name,
            calendar_year,
            'fin'
        );

ALTER TABLE t_months ADD CONSTRAINT month_id_pk PRIMARY KEY ( month_id );