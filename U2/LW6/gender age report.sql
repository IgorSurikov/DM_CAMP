SELECT DISTINCT
    LAST_VALUE(age)
    OVER(PARTITION BY gender
        ORDER BY
            age 
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) oldest, 
    FIRST_VALUE(age)
    OVER(PARTITION BY gender
         ORDER BY age 
         RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) youngest,
        gender
FROM
    t_customers;
