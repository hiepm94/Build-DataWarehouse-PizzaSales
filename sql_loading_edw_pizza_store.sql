-- delete from sch_pizza_edw.dim_time;

insert into sch_pizza_edw.dim_time (time_id, timeofday, quarterhour, daytimename, daynight)
select
    row_number() over (order by second) as time_id,
    to_char(second, 'hh24:mi:ss') AS TimeOfDay,
	-- Extract and format quarter hours
	to_char(second - (extract(minute from second)::integer % 15 || 'minutes')::interval, 'hh24:mi') ||
	' – ' ||
	to_char(second - (extract(minute from second)::integer % 15 || 'minutes')::interval + '14 minutes'::interval, 'hh24:mi')
		as QuarterHour,
	-- Names of day periods
	case when to_char(second, 'hh24:mi') between '06:00' and '08:29'
		then 'Morning'
	     when to_char(second, 'hh24:mi') between '08:30' and '11:59'
		then 'AM'
	     when to_char(second, 'hh24:mi') between '12:00' and '17:59'
		then 'PM'
	     when to_char(second, 'hh24:mi') between '18:00' and '22:29'
		then 'Evening'
	     else 'Night'
	end as DaytimeName,
	-- Indicator of day or night
	case when to_char(second, 'hh24:mi') between '07:00' and '19:59' then 'Day'
	     else 'Night'
	end AS DayNight
from (SELECT '0:00:00'::time + (sequence.second || ' seconds')::interval AS second
	FROM generate_series(0,86399) AS sequence(second)
	GROUP BY sequence.second
     ) DQ
order by 1;


-- delete from sch_pizza_edw.dim_date;

insert into sch_pizza_edw.dim_date(date_id, date, year, month, monthname, day, dayofyear, weekdayname, calendarweek, quartal, weekend, is_holiday, period)
SELECT
    row_number() over (order by datum) as date_id,
	datum as Date,
	extract(year from datum) AS Year,
	extract(month from datum) AS Month,
	-- Localized month name
	to_char(datum, 'TMMonth') AS MonthName,
	extract(day from datum) AS Day,
	extract(doy from datum) AS DayOfYear,
	-- Localized weekday
	to_char(datum, 'TMDay') AS WeekdayName,
	-- ISO calendar week
	extract(week from datum) AS CalendarWeek,
	'Q' || to_char(datum, 'Q') AS Quartal,
	-- Weekend
	CASE WHEN extract(isodow from datum) in (6, 7) THEN 'Weekend' ELSE 'Weekday' END AS Weekend,
	-- Fixed holidays
        CASE WHEN to_char(datum, 'MMDD') IN ('0101', '0704', '1225', '1226')
		THEN 'Yes' ELSE 'No' END
		AS is_holiday,
    -- Some periods of the year, adjust for your organisation and country
	CASE WHEN to_char(datum, 'MMDD') BETWEEN '0701' AND '0831' THEN 'Summer break'
	     WHEN to_char(datum, 'MMDD') BETWEEN '1115' AND '1225' THEN 'Christmas season'
	     WHEN to_char(datum, 'MMDD') > '1225' OR to_char(datum, 'MMDD') <= '0106' THEN 'Winter break'
		ELSE 'Normal' END
		AS Period
	FROM (
	-- There are 3 leap years in this range, so calculate 365 * 10 + 3 records
	SELECT '2022-01-01'::DATE + sequence.day AS datum
	FROM generate_series(0,1000) AS sequence(day)
	GROUP BY sequence.day
     ) DQ
order by 1;


-- delete from sch_pizza_edw.dim_store;

insert into sch_pizza_edw.dim_store(store_sk, store_id, store_name, store_zip, store_city, store_staff, rec_source, dt_insert)
values (0,'Shop-0','temp','temp','temp',0,'temp',current_date);


-- dim_product
update sch_pizza_edw.dim_product
    set product_price = stg_pizzas.price,
        dt_update = current_date
from sch_pizza_stg.stg_pizzas
where stg_pizzas.pizza_id = dim_product.product_id
and dim_product.product_price <> stg_pizzas.price;


insert into sch_pizza_edw.dim_product (product_sk, product_id,product_type_id, product_name, product_category, product_family,
                         product_ingredients, product_size, product_price, rec_source, dt_insert, dt_update)
select row_number() over (order by 1) + max_sk.product_sk ,
       sp.pizza_id as product_id,
       spt.pizza_type_id as product_type_id,
       spt.name as product_name,
       spt.category as product_category,
       'pizza' as product_family,
       spt.ingredients as product_ingredients,
       sp.size as product_size,
       sp.price as product_price,
       'Shop-1' as rec_source,
       current_date as dt_insert,
       NULL as dt_update
    from sch_pizza_stg.stg_pizzas sp
    inner join
        sch_pizza_stg.stg_pizza_types spt on sp.pizza_type_id = spt.pizza_type_id
    left join sch_pizza_edw.dim_product dp
        on dp.product_id = sp.pizza_id
    cross join
        (select coalesce(max(product_sk),0) as product_sk from sch_pizza_edw.dim_product)max_sk
    where dp.product_id is null ;
	
-- dim_orders
delete from sch_pizza_edw.dim_orders
using sch_pizza_stg.stg_order_details
where dim_orders.order_details_id=stg_order_details.order_details_id;

insert into sch_pizza_edw.dim_orders(order_sk, order_id,order_details_id,product_id,quantity, date, time, rec_source, dt_insert)
select row_number() over (order by 1) + max_sk.order_sk as order_sk,
       so.order_id,
       sod.order_details_id,
       sod.pizza_id as product_id,
       sod.quantity ,
       so.date,
       so.time,
       'Shop-0' as rec_source,
       current_date as dt_insert
    from
        sch_pizza_stg.stg_orders so
inner join
        sch_pizza_stg.stg_order_details sod
on so.order_id = sod.order_id
cross join
        (select coalesce(max(order_sk),0) as order_sk from sch_pizza_edw.dim_orders)max_sk;
		

-- delete from sch_pizza_edw.fact_sales_order where dt_insert = '2023-07-06';

insert into sch_pizza_edw.fact_sales_order(sales_order_sk, order_sk, product_sk, store_sk, date_id, time_id,
        product_price, quantity, rec_source, dt_insert)
select row_number() over (order by 2) + max_sk.sales_order_sk as sales_order_sk,
       dos.order_sk, dp.product_sk,
       ds.store_sk,dd.date_id,dt.time_id,
       dp.product_price,
       dos.quantity,
       'Shop-0' as rec_source ,current_date as dt_insert
    from
        sch_pizza_edw.dim_orders dos
    inner join sch_pizza_edw.dim_product dp on dp.product_id = dos.product_id
    inner join sch_pizza_edw.dim_store ds on ds.store_id = dos.rec_source
    inner join sch_pizza_edw.dim_date dd on dd.date = dos.date
    inner join sch_pizza_edw.dim_time dt on dt.timeofday = cast(dos.time as varchar(10))
    cross join (select coalesce(max(sales_order_sk),0) as sales_order_sk 
				from sch_pizza_edw.fact_sales_order) max_sk
where dos.dt_insert = '2023-07-06';