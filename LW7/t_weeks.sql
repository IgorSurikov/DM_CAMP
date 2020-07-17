drop table t_weeks;

create table t_weeks as
(
select distinct 
to_number(to_char(week_ending_date,'yyyy') || to_char(week_ending_date,'MM') || to_char(week_ending_date,'DD')) as week_id,
trunc(time_id,'DAY') as week_beg_date,
week_ending_date 
from sa_CALENDAR);

ALTER TABLE t_weeks
ADD CONSTRAINT week_id_pk  PRIMARY KEY (week_id);





