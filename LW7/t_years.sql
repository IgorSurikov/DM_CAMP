drop table T_YEARS;

create table T_YEARS as
(
select distinct
to_number(to_char(end_of_cal_year,'yyyy') || to_char(end_of_cal_year,'MM') || to_char(end_of_cal_year,'DD') || '01') as year_id,
calendar_year,
days_in_cal_year,
beg_of_cal_year,
end_of_cal_year,
'iso' as type
from sa_CALENDAR

union all

select
to_number(to_char(max(end_of_cal_quarter),'yyyy') || to_char(max(end_of_cal_quarter),'MM') || to_char(max(end_of_cal_quarter),'DD') || '02') as year_id,
calendar_year,
trunc(max(end_of_cal_quarter) - min(beg_of_cal_quarter)) as days_in_cal_quarter,
min(beg_of_cal_quarter) as beg_of_cal_year,
max(end_of_cal_quarter)as end_of_cal_year,
'fin' as type
from
(select 
beg_of_cal_quarter,
end_of_cal_quarter,
TO_CHAR( end_of_cal_quarter, 'YYYY' ) as calendar_year
from T_quarters
where type = 'fin') temp
group by calendar_year, 'fin'
);

ALTER TABLE T_YEARS
ADD CONSTRAINT year_id_pk  PRIMARY KEY (year_id);
























