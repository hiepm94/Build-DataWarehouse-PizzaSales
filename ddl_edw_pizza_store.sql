create schema sch_pizza_edw;
drop table if exists sch_pizza_edw.fact_sales_order;

create table sch_pizza_edw.fact_sales_order
(
        sales_order_sk integer primary key not null,
        order_sk integer,
        product_sk integer,
        store_sk integer,
        date_id bigint,
        time_id bigint,
        product_price decimal (5,2),
        quantity smallint,
        rec_source varchar (10),
        dt_insert date
);

drop table if exists sch_pizza_edw.dim_time;

create table sch_pizza_edw.dim_time
(
    time_id     bigint not null primary key,
    timeofday   varchar(10),
    quarterhour varchar(20),
    daytimename varchar(20),
    daynight    varchar(20)
);

drop table if exists sch_pizza_edw.dim_store;

create Table sch_pizza_edw.dim_store
(
        store_sk integer primary key not null,
        store_id varchar (100),
        store_name varchar (100),
        store_zip varchar (100),
        store_city varchar (100),
        store_staff smallint,
        rec_source varchar (10),
        dt_insert date
);

drop table if exists sch_pizza_edw.dim_product;

create table sch_pizza_edw.dim_product
(
        product_sk integer primary key not null,
        product_id varchar (100),
        product_type_id varchar(100),
        product_name varchar (100),
        product_category varchar (100),
        product_family varchar(100),
        product_ingredients varchar (1000),
        product_size varchar (5),
        product_price decimal (5,2),
        rec_source varchar (10),
        dt_insert date,
        dt_update date
);

drop table if exists sch_pizza_edw.dim_orders;

create table sch_pizza_edw.dim_orders
      (
    order_sk integer primary key not null,
    order_id integer,
    order_details_id integer,
    product_id varchar(100),
    quantity smallint,
    date date,
    time time,
    rec_source varchar(10),
    dt_insert date
);

drop table if exists sch_pizza_edw.dim_date;

create table sch_pizza_edw.dim_date
(
    date_id      bigint not null primary key,
    date         date,
    year         smallint,
    month        smallint,
    monthname    varchar(20),
    day          smallint,
    dayofyear    smallint,
    weekdayname  varchar(20),
    calendarweek smallint,
    quartal      varchar(5),
    weekend      varchar(20),
    is_holiday   varchar(3),
    period       varchar(30)
);