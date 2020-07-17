drop table T_QUARTERS;

create table T_QUARTERS as
(select distinct 
to_number(to_char(end_of_cal_quarter,'yyyy') || to_char(end_of_cal_quarter,'MM') || to_char(end_of_cal_quarter,'DD') || '01') as quarter_id,
days_in_cal_quarter,
beg_of_cal_quarter,
end_of_cal_quarter,
calendar_quarter_number, 
'iso' as type
from sa_CALENDAR

union all

select 
to_number(to_char(max(end_of_cal_month),'yyyy') || to_char(max(end_of_cal_month),'MM') || to_char(max(end_of_cal_month),'DD') || '02') as quarter_id,
trunc(max(end_of_cal_month) - min(end_of_cal_month)) as days_in_cal_quarter,
min(beg_of_cal_month) as beg_of_cal_quarter,
max(end_of_cal_month)as end_of_cal_quarter,
q as calendar_quarter_number,
'fin' as type
from
(
select 
beg_of_cal_month,
end_of_cal_month,
TO_CHAR( end_of_cal_month, 'Q' ) as q,
TO_CHAR( end_of_cal_month, 'YYYY' ) as calendar_year
from T_MONTHS
where type = 'fin') temp
group by q, calendar_year, 'fin');

ALTER TABLE T_QUARTERS
ADD CONSTRAINT quarter_id_pk  PRIMARY KEY (quarter_id);


















