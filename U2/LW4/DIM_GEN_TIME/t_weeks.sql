DROP TABLE t_weeks;

CREATE TABLE t_weeks
    AS
        ( SELECT DISTINCT
            to_number(to_char(week_ending_date, 'yyyy')
                      || to_char(week_ending_date, 'MM')
                      || to_char(week_ending_date, 'DD'))        AS week_id,
            trunc(time_id, 'DAY')                      AS week_beg_date,
            week_ending_date
        FROM
            sa_calendar
        );

ALTER TABLE t_weeks ADD CONSTRAINT week_id_pk PRIMARY KEY ( week_id );