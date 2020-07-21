DROP TABLE sa_calendar;

CREATE TABLE sa_calendar
    AS
        ( SELECT
            trunc(sd + rn)                                                                  time_id,
            to_char(sd + rn, 'fmDay')                                                       day_name,
            to_char(sd + rn, 'D')                                                           day_number_in_week,
            to_char(sd + rn, 'DD')                                                          day_number_in_month,
            to_char(sd + rn, 'DDD')                                                         day_number_in_year,
            to_char(sd + rn, 'W')                                                           calendar_week_number,
            (
                CASE
                    WHEN to_char(sd + rn, 'D') IN ( 1, 2, 3, 4, 5,
                                                    6 ) THEN
                        next_day(sd + rn, '¬Œ— –≈—≈Õ‹≈')
                    ELSE
                        ( sd + rn )
                END
            )                                                                                 week_ending_date,
            to_char(sd + rn, 'MM')                                                          calendar_month_number,
            to_char(last_day(sd + rn), 'DD')                                              days_in_cal_month,
            last_day(sd + rn)                                                               end_of_cal_month,
            to_char(sd + rn, 'FMMonth')                                                     calendar_month_name,
            ( (
                CASE
                    WHEN to_char(sd + rn, 'Q') = 1    THEN
                        to_date('03/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 2    THEN
                        to_date('06/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 3    THEN
                        to_date('09/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 4    THEN
                        to_date('12/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                END
            ) - trunc(sd + rn, 'Q') + 1 )                                                   days_in_cal_quarter,
            trunc(sd + rn, 'Q')                                                             beg_of_cal_quarter,
            (
                CASE
                    WHEN to_char(sd + rn, 'Q') = 1    THEN
                        to_date('03/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 2    THEN
                        to_date('06/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 3    THEN
                        to_date('09/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 4    THEN
                        to_date('12/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                END
            )                                                                                 end_of_cal_quarter,
            to_char(sd + rn, 'Q')                                                           calendar_quarter_number,
            to_char(sd + rn, 'YYYY')                                                        calendar_year,
            ( to_date('12/31/'
                      || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY') - trunc(sd + rn, 'YEAR') )   days_in_cal_year,
            trunc(sd + rn, 'YEAR')                                                          beg_of_cal_year,
            to_date('12/31/'
                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')                                     end_of_cal_year
        FROM
            (
                SELECT
                    TO_DATE('12/31/2018', 'MM/DD/YYYY')    sd,
                    ROWNUM                                   rn
                FROM
                    dual
                CONNECT BY
                    level <= 2190
      --2190 works better
              )
        )