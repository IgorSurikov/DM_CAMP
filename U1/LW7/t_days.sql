DROP TABLE t_days;

CREATE TABLE t_days
    AS
        ( SELECT
            time_id,
            day_name,
            day_number_in_week,
            day_number_in_month,
            day_number_in_year
        FROM
            sa_calendar
        );

ALTER TABLE t_days ADD CONSTRAINT time_id_pk PRIMARY KEY ( time_id );