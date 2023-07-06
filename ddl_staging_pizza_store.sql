create schema sch_pizza_stg;

drop table if exists sch_pizza_stg.stg_pizzas;

create table sch_pizza_stg.stg_pizzas(
    pizza_id varchar(100) primary key not null,
    pizza_type_id varchar(100) not null,
    size varchar(5) not null,
    price decimal(5,2) not null
);

drop table if exists sch_pizza_stg.stg_pizzas_types;

create table sch_pizza_stg.stg_pizza_types(
    pizza_type_id varchar(100) primary key not null,
    name varchar(100) not null,
    category varchar(100) not null,
    ingredients varchar(1000) not null
);

drop table if exists sch_pizza_stg.stg_orders;

create table sch_pizza_stg.stg_orders(
    order_id integer primary key not null,
    date date not null,
    time time not null
);

drop table if exists sch_pizza_stg.stg_order_details;

create table sch_pizza_stg.stg_order_details(
    order_details_id integer primary key not null,
    order_id integer not null,
    pizza_id varchar(100),
    quantity smallint
);
