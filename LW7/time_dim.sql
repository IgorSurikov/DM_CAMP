drop table dim_gen_time;
truncate table dim_gen_time;
create table dim_gen_time
as
(
select t_days.TIME_ID TIME_ID,
t_days.DAY_NAME DAY_NAME,
t_days.DAY_NUMBER_IN_WEEK DAY_NUMBER_IN_WEEK_ISO,
t_days.DAY_NUMBER_IN_MONTH DAY_NUMBER_IN_MONTH_ISO,
t_days.DAY_NUMBER_IN_YEAR DAY_NUMBER_IN_YEAR_ISO,
t_weeks.WEEK_ID WEEK_ID,
t_weeks.WEEK_BEG_DATE WEEK_BEG_DATE,
t_weeks.WEEK_ENDING_DATE WEEK_ENDING_DATE,
t_months.MONTH_ID MONTH_ID_ISO,
t_months.CALENDAR_MONTH_NUMBER CALENDAR_MONTH_NUMBER_ISO,
t_months.DAYS_IN_CAL_MONTH DAYS_IN_CAL_MONTH_ISO,
t_months.BEG_OF_CAL_MONTH BEG_OF_CAL_MONTH_ISO,
t_months.END_OF_CAL_MONTH END_OF_CAL_MONTH_ISO,
t_months.CALENDAR_MONTH_NAME CALENDAR_MONTH_NAME_ISO,
m.MONTH_ID MONTH_ID_fin,
m.CALENDAR_MONTH_NUMBER CALENDAR_MONTH_NUMBER_fin,
m.DAYS_IN_CAL_MONTH DAYS_IN_CAL_MONTH_fin,
m.BEG_OF_CAL_MONTH BEG_OF_CAL_MONTH_fin,
m.END_OF_CAL_MONTH END_OF_CAL_MONTH_fin,
m.CALENDAR_MONTH_NAME CALENDAR_MONTH_NAME_fin,
t_quarters.QUARTER_ID QUARTER_ID_ISO,
t_quarters.DAYS_IN_CAL_QUARTER DAYS_IN_CAL_QUARTER_ISO,
t_quarters.BEG_OF_CAL_QUARTER BEG_OF_CAL_QUARTER_ISO,
t_quarters.END_OF_CAL_QUARTER END_OF_CAL_QUARTER_ISO,
t_quarters.CALENDAR_QUARTER_NUMBER CALENDAR_QUARTER_NUMBER_ISO,
q.QUARTER_ID QUARTER_ID_fin,
q.DAYS_IN_CAL_QUARTER DAYS_IN_CAL_QUARTER_fin,
q.BEG_OF_CAL_QUARTER BEG_OF_CAL_QUARTER_fin,
q.END_OF_CAL_QUARTER END_OF_CAL_QUARTER_fin,
q.CALENDAR_QUARTER_NUMBER CALENDAR_QUARTER_NUMBER_fin,
t_years.YEAR_ID YEAR_ID_ISO,
t_years.CALENDAR_YEAR CALENDAR_YEAR_ISO,
t_years.DAYS_IN_CAL_YEAR DAYS_IN_CAL_YEAR_ISO,
t_years.BEG_OF_CAL_YEAR BEG_OF_CAL_YEAR_ISO,
t_years.END_OF_CAL_YEAR END_OF_CAL_YEAR_ISO,
y.YEAR_ID YEAR_ID_fin,
y.CALENDAR_YEAR CALENDAR_YEAR_fin,
y.DAYS_IN_CAL_YEAR DAYS_IN_CAL_YEAR_fin,
y.BEG_OF_CAL_YEAR BEG_OF_CAL_YEAR_fin,
y.END_OF_CAL_YEAR END_OF_CAL_YEAR_fin
from t_days
inner join t_weeks on t_days.time_id between week_beg_date and week_ending_date
inner join t_months on t_days.time_id between beg_of_cal_month and end_of_cal_month and type = 'iso'
inner join t_months m on t_days.time_id between m.beg_of_cal_month and m.end_of_cal_month and m.type = 'fin'
inner join t_quarters on t_days.time_id between t_quarters.beg_of_cal_quarter and t_quarters.end_of_cal_quarter and t_quarters.type = 'iso'
inner join t_quarters q on t_days.time_id between q.beg_of_cal_quarter and q.end_of_cal_quarter and q.type = 'fin'
inner join t_years on t_days.time_id between t_years.beg_of_cal_year and t_years.end_of_cal_year and t_years.type = 'iso'
inner join t_years y on t_days.time_id between y.beg_of_cal_year and y.end_of_cal_year and y.type = 'fin'
);

ALTER TABLE dim_gen_time
ADD CONSTRAINT calendar_id_pk  PRIMARY KEY (time_id);












