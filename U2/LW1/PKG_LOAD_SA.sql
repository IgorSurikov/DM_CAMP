create or replace PACKAGE pkg_load_sa AS
    PROCEDURE load_sa_calendar;

    PROCEDURE load_sa_sales;

    PROCEDURE load_sa_periods;

    PROCEDURE load_sa_products;

    PROCEDURE load_sa_customers;
END pkg_load_sa;