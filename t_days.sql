drop table t_days;

create table t_days as
(select time_id,day_name,day_number_in_week,day_number_in_month,day_number_in_year 
from sa_calendar);

ALTER TABLE t_days
ADD CONSTRAINT time_id_pk  PRIMARY KEY (time_id);