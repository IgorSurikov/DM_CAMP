DROP TABLE dim_gen_time;

TRUNCATE TABLE dim_gen_time;

CREATE TABLE dim_gen_time
    AS
        ( SELECT
            t_days.time_id                        time_id,
            t_days.day_name                       day_name,
            t_days.day_number_in_week             day_number_in_week_iso,
            t_days.day_number_in_month            day_number_in_month_iso,
            t_days.day_number_in_year             day_number_in_year_iso,
            t_weeks.week_id                       week_id,
            t_weeks.week_beg_date                 week_beg_date,
            t_weeks.week_ending_date              week_ending_date,
            t_months.month_id                     month_id_iso,
            t_months.calendar_month_number        calendar_month_number_iso,
            t_months.days_in_cal_month            days_in_cal_month_iso,
            t_months.beg_of_cal_month             beg_of_cal_month_iso,
            t_months.end_of_cal_month             end_of_cal_month_iso,
            t_months.calendar_month_name          calendar_month_name_iso,
            m.month_id                            month_id_fin,
            m.calendar_month_number               calendar_month_number_fin,
            m.days_in_cal_month                   days_in_cal_month_fin,
            m.beg_of_cal_month                    beg_of_cal_month_fin,
            m.end_of_cal_month                    end_of_cal_month_fin,
            m.calendar_month_name                 calendar_month_name_fin,
            t_quarters.quarter_id                 quarter_id_iso,
            t_quarters.days_in_cal_quarter        days_in_cal_quarter_iso,
            t_quarters.beg_of_cal_quarter         beg_of_cal_quarter_iso,
            t_quarters.end_of_cal_quarter         end_of_cal_quarter_iso,
            t_quarters.calendar_quarter_number    calendar_quarter_number_iso,
            q.quarter_id                          quarter_id_fin,
            q.days_in_cal_quarter                 days_in_cal_quarter_fin,
            q.beg_of_cal_quarter                  beg_of_cal_quarter_fin,
            q.end_of_cal_quarter                  end_of_cal_quarter_fin,
            q.calendar_quarter_number             calendar_quarter_number_fin,
            t_years.year_id                       year_id_iso,
            t_years.calendar_year                 calendar_year_iso,
            t_years.days_in_cal_year              days_in_cal_year_iso,
            t_years.beg_of_cal_year               beg_of_cal_year_iso,
            t_years.end_of_cal_year               end_of_cal_year_iso,
            y.year_id                             year_id_fin,
            y.calendar_year                       calendar_year_fin,
            y.days_in_cal_year                    days_in_cal_year_fin,
            y.beg_of_cal_year                     beg_of_cal_year_fin,
            y.end_of_cal_year                     end_of_cal_year_fin
        FROM
                 t_days
            INNER JOIN t_weeks ON t_days.time_id BETWEEN week_beg_date AND week_ending_date
            INNER JOIN t_months ON t_days.time_id BETWEEN beg_of_cal_month AND end_of_cal_month
                                   AND type = 'iso'
            INNER JOIN t_months    m ON t_days.time_id BETWEEN m.beg_of_cal_month AND m.end_of_cal_month
                                     AND m.type = 'fin'
            INNER JOIN t_quarters ON t_days.time_id BETWEEN t_quarters.beg_of_cal_quarter AND t_quarters.end_of_cal_quarter
                                     AND t_quarters.type = 'iso'
            INNER JOIN t_quarters  q ON t_days.time_id BETWEEN q.beg_of_cal_quarter AND q.end_of_cal_quarter
                                       AND q.type = 'fin'
            INNER JOIN t_years ON t_days.time_id BETWEEN t_years.beg_of_cal_year AND t_years.end_of_cal_year
                                  AND t_years.type = 'iso'
            INNER JOIN t_years     y ON t_days.time_id BETWEEN y.beg_of_cal_year AND y.end_of_cal_year
                                    AND y.type = 'fin'
        );

ALTER TABLE dim_gen_time ADD CONSTRAINT calendar_id_pk PRIMARY KEY ( time_id );



