select
case
	when o.delivered::date > o.estimated::date
	then 'late'
	else 'on time'
end as del_status,
count(*),
round(avg(extract(epoch from (o.approved - o.purchase)) / 86400)::numeric, 2) as one_avg,
round((percentile_cont(0.5) within group (order by extract(epoch from (o.approved - o.purchase)) / 86400))::numeric, 2) as one_median
from orders_new o
where o.order_status = 'delivered'
and o.purchase is not null
and o.approved is not null
and o.carrier is not null
and o.delivered is not null
and o.estimated is not null
group by del_status
order by del_status


select
case
	when o.delivered::date > o.estimated::date
	then 'late'
	else 'on time'
end as del_status,
count(*),
round(avg(extract(epoch from (o.carrier - o.approved)) / 86400)::numeric, 2) as two_avg,
round((percentile_cont(0.5) within group (order by extract(epoch from (o.carrier - o.approved)) / 86400))::numeric, 2) as two_median
from orders_new o
where o.order_status = 'delivered'
and o.purchase is not null
and o.approved is not null
and o.carrier is not null
and o.delivered is not null
and o.estimated is not null
group by del_status
order by del_status


select
case
	when o.delivered::date > o.estimated::date
	then 'late'
	else 'on time'
end as del_status,
count(*),
round(avg(extract(epoch from (o.delivered - o.carrier)) / 86400)::numeric, 2) as three_avg,
round((percentile_cont(0.5) within group (order by extract(epoch from (o.delivered - o.carrier)) / 86400))::numeric, 2) as three_median
from orders_new o
where o.order_status = 'delivered'
and o.purchase is not null
and o.approved is not null
and o.carrier is not null
and o.delivered is not null
and o.estimated is not null
group by del_status
order by del_status


select
case
	when c.customer_state = s.seller_state
	then 'один штат'
	else 'разные штаты'
end as states,
case
	when o.delivered::date > o.estimated::date
	then 'late'
	else 'on time'
end as del_status,
count(*) as cnt,
round(avg(extract(epoch from (o.delivered - o.carrier)) / 86400)::numeric, 2) as three_avg,
round((percentile_cont(0.5) within group (order by extract(epoch from (o.delivered - o.carrier)) / 86400))::numeric, 2) as three_median
from orders_new o
inner join customers c
on o.customer_id = c.customer_id
inner join (select order_id, min(seller_id) as seller_id
from order_items
group by order_id) oi
on o.order_id = oi.order_id
inner join sellers s
on oi.seller_id = s.seller_id
where o.order_status = 'delivered'
and o.purchase is not null
and o.approved is not null
and o.carrier is not null
and o.delivered is not null
and o.estimated is not null
group by states, del_status
order by states, del_status


