select *
from order_reviews_new

select count(*)
from order_reviews_new


select review_score, count(*)
from order_reviews_raw as orr
group by orr.review_score
order by orr.review_score


select
case
	when o.delivered::date > o.estimated::date
	then 'late'
	else 'on time'
end as del_status,
orr.review_score, count(*)
from order_reviews_new orr
inner join orders_new o
on orr.order_id = o.order_id
where o.order_status = 'delivered'
and o.delivered is not null
and o.estimated is not null
group by del_status, orr.review_score
order by del_status, orr.review_score



select del_status, review_score, orders_cnt,
round(orders_cnt * 100.0 / sum(orders_cnt) over (partition by del_status),2) as percent
from (select case
	when o.delivered::date > o.estimated::date
    then 'late'
    else 'on time'
end as del_status,
orr.review_score, count(*) as orders_cnt
from order_reviews_new orr
inner join orders_new o
on orr.order_id = o.order_id
where o.order_status = 'delivered' and o.delivered is not null and o.estimated is not null
group by del_status, orr.review_score)
order by del_status, review_score


select
case
	when o.delivered::date > o.estimated::date
	then 'late'
	else 'on time'
end as del_status,
count(*) as all_cnt,
round(avg(orr.review_score), 2) as avg_score,
count(*) filter (where orr.review_score in (1,2)) as low_cnt,
round(count(*) filter (where orr.review_score in (1,2))::numeric / count(*) * 100, 2) as percent
from order_reviews_new orr
inner join orders_new o
on orr.order_id = o.order_id
where o.order_status = 'delivered'
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
count(*) as cnt,
count(*) filter (where o.carrier > oi.limit_date) as late_cnt,
round(count(*) filter (where o.carrier > oi.limit_date) * 100.0 / count(*), 2) as percent
from orders_new o
inner join (select order_id, max(shipping_limit_date::timestamp) as limit_date
from order_items
group by order_id) oi
on o.order_id = oi.order_id
where o.order_status = 'delivered'
and o.carrier is not null
and o.delivered is not null
and o.estimated is not null
group by del_status
order by del_status
