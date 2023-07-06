delete from sch_pizza_stg.stg_pizzas;

copy sch_pizza_stg.stg_pizzas
from 'C:/Users/hiepm/OneDrive/Documents/Pizza+Place+Sales/pizza_sales/pizzas.csv'
delimiter ',' csv header;

delete from sch_pizza_stg.stg_pizza_types;

copy sch_pizza_stg.stg_pizza_types
from 'C:/Users/hiepm/OneDrive/Documents/Pizza+Place+Sales/pizza_sales/pizza_types.csv'
delimiter ',' csv header;

delete from sch_pizza_stg.stg_orders;

copy sch_pizza_stg.stg_orders
from 'C:/Users/hiepm/OneDrive/Documents/Pizza+Place+Sales/pizza_sales/orders.csv'
delimiter ',' csv header;



delete from sch_pizza_stg.stg_order_details;

copy sch_pizza_stg.stg_order_details
from 'C:/Users/hiepm/OneDrive/Documents/Pizza+Place+Sales/pizza_sales/order_details.csv'
delimiter ',' csv header;
