drop table t_months;

create table t_months as
(select DISTINCT
to_number(to_char(end_of_cal_month,'yyyy') || to_char(end_of_cal_month,'MM') || to_char(end_of_cal_month,'DD') || '01') as month_id,
calendar_month_number,
days_in_cal_month,
trunc(time_id,'mm') as beg_of_cal_month,
end_of_cal_month,
calendar_month_name, 
'iso' as type
from sa_CALENDAR

union all

select
to_number(to_char(max(m.end_of_cal_month),'yyyy') || to_char(max(m.end_of_cal_month),'MM') || to_char(max(m.end_of_cal_month),'DD') || '02') as month_id,
TO_CHAR( max(m.end_of_cal_month), 'MM' ) calendar_month_number,
TO_CHAR(trunc(max(m.end_of_cal_month) - min(m.week_beg_date))) as days_in_cal_month,
min(m.week_beg_date) as beg_of_cal_month ,
max(m.end_of_cal_month) as end_of_cal_month ,
m.calendar_month_name,
'fin' as type
from(
    select 
    trunc(time_id,'DAY') as week_beg_date,
    TO_CHAR( week_ending_date, 'YYYY' ) as calendar_year,
    TO_CHAR( week_ending_date, 'MM' ) calendar_month_number,
    week_ending_date as end_of_cal_month,
    TO_CHAR( week_ending_date, 'FMMonth' ) calendar_month_name,
    'fin' as type
    from sa_CALENDAR) m
group by m.calendar_month_name, calendar_year, 'fin');

ALTER TABLE t_months
ADD CONSTRAINT month_id_pk  PRIMARY KEY (month_id);














