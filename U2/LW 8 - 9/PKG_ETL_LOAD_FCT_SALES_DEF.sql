create or replace PACKAGE PKG_ETL_LOAD_FCT_SALES AS 
    
    PROCEDURE load_fct_sales_dd;
    
    PROCEDURE load_fct_sales_dd_slow;

END PKG_ETL_LOAD_FCT_SALES;