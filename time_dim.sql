drop table dim_gen_time;
truncate table dim_gen_time;
create table dim_gen_time
(
    CALENDAR_ID	NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    TIME_ID	DATE,
    DAY_ID	NUMBER(38,0),
    DAY_NAME VARCHAR2(44 BYTE),
    DAY_NUMBER_IN_WEEK	VARCHAR2(1 BYTE),
    DAY_NUMBER_IN_MONTH	VARCHAR2(2 BYTE),
    DAY_NUMBER_IN_YEAR	VARCHAR2(3 BYTE),
    WEEK_ID	NUMBER(38,0),
    CALENDAR_WEEK_NUMBER VARCHAR2(1 BYTE),
    WEEK_ENDING_DATE	DATE,
    MONTH_ID NUMBER(38,0),
    CALENDAR_MONTH_NUMBER	VARCHAR2(2 BYTE),
    --week_month_number VARCHAR2(2 BYTE),
    DAYS_IN_CAL_MONTH	VARCHAR2(2 BYTE),
    END_OF_CAL_MONTH	DATE,
    CALENDAR_MONTH_NAME	VARCHAR2(32 BYTE),
    QUARTER_ID NUMBER(38,0),
    DAYS_IN_CAL_QUARTER	NUMBER,
    BEG_OF_CAL_QUARTER	DATE,
    END_OF_CAL_QUARTER	DATE,
    CALENDAR_QUARTER_NUMBER	VARCHAR2(1 BYTE),
    year_ID NUMBER(38,0),
    CALENDAR_YEAR	VARCHAR2(4 BYTE),
    DAYS_IN_CAL_YEAR	NUMBER,
    BEG_OF_CAL_YEAR	DATE,
    END_OF_CAL_YEAR	DATE,
    CONSTRAINT CALENDAR_ID_PK PRIMARY KEY (CALENDAR_ID)
);

ALTER TABLE dim_gen_time
ADD CONSTRAINT DAY_ID_fk
  FOREIGN KEY (DAY_ID)
  REFERENCES T_DAYS(DAY_ID);
  
ALTER TABLE dim_gen_time
ADD CONSTRAINT WEEK_ID_fk
  FOREIGN KEY (WEEK_ID)
  REFERENCES T_WEEKs(WEEK_ID);
  
ALTER TABLE dim_gen_time
ADD CONSTRAINT MONTH_ID_fk
  FOREIGN KEY (MONTH_ID)
  REFERENCES T_MONTHs(MONTH_ID);
  
ALTER TABLE dim_gen_time
ADD CONSTRAINT QUARTER_ID_fk
  FOREIGN KEY (QUARTER_ID)
  REFERENCES T_QUARTERs(QUARTER_ID);
  
ALTER TABLE dim_gen_time
ADD CONSTRAINT year_ID_fk
  FOREIGN KEY (year_ID)
  REFERENCES T_years(year_ID);
  

select * from t_days
inner join t_weeks on t_days.time_id between week_beg_date and week_ending_date
inner join t_months on t_days.time_id between beg_of_cal_month and end_of_cal_month and type = 'iso'
inner join t_months m on t_days.time_id between m.beg_of_cal_month and m.end_of_cal_month and m.type = 'fin'
inner join t_quarters on t_days.time_id between t_quarters.beg_of_cal_quarter and t_quarters.end_of_cal_quarter and t_quarters.type = 'iso'
inner join t_quarters q on t_days.time_id between q.beg_of_cal_quarter and q.end_of_cal_quarter and q.type = 'fin'
order by time_id;







