create view orders_new as
select order_id, customer_id, order_status,
nullif(order_purchase_timestamp, '')::timestamp as purchase,
nullif(order_approved_at, '')::timestamp as approved,
nullif(order_delivered_carrier_date, '')::timestamp as carrier,
nullif(order_delivered_customer_date, '')::timestamp as delivered,
nullif(order_estimated_delivery_date, '')::timestamp as estimated
from orders


select *
from orders_new


select count(*), count(distinct order_id)
from orders_new


select order_status, count(*) as cnt
from orders_new
group by order_status
order by cnt desc


select count(*)
from orders_new
where order_status = 'delivered'
and delivered is not null
and estimated is not null


select count(*) as delivered_total,
count(*) filter (where delivered::date > estimated::date) as late
from orders_new
where order_status = 'delivered'
and delivered is not null
and estimated is not null


select order_id, delivered, estimated,
(delivered::date - estimated::date) as del_days
from orders_new
where order_status = 'delivered'
and delivered is not null
and estimated is not null
and delivered::date > estimated::date
order by del_days desc


select count(*) as late_cnt,
round(count(*) * 100.0 / (select count(*)
from orders_new
where order_status = 'delivered' and delivered is not null and estimated is not null), 2) as late_pct,
round(avg(del_days), 2) as avg_del,
round((percentile_cont(0.5) within group (order by del_days))::numeric, 1) as median_del,
round((percentile_cont(0.9) within group (order by del_days))::numeric, 1) as p90_del,
max(del_days) as max_del
from (select delivered::date - estimated::date as del_days
from orders_new
where order_status = 'delivered' and delivered is not null and estimated is not null and delivered::date > estimated::date)


select
(case
	when del_days <= 3
	then '1-3 дня'
	when del_days <= 7
	then 'от 4 до 7 дней'
	when del_days <= 14
	then 'от 8 до 14 дней'
	when del_days <= 30
	then 'от 15 до 30 дней'
	else 'больше 30 дней'
end) as group_cnt,
count(*) as cnt,
round(count(*) * 100.0 / sum(count(*)) over (), 2) as percent
from (select delivered::date - estimated::date as del_days
from orders_new
where order_status = 'delivered' and delivered is not null and estimated is not null and delivered::date > estimated::date)
group by group_cnt
order by min(del_days)

