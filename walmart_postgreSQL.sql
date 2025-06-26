select * from walmart;

drop table walmart;

select count(*) From walmart;

Select 
payment_method,
count(*)
from walmart
group by payment_method

select 
count(distinct branch)
branch
from walmart;

select MIN(quantity) FROM walmart;

-- Business Problems
Q.1 Find different payment methods and number of transactions, number of qty sold

Select 
payment_method,
count(*) as no_payments,
sum(Quantity) as no_qty_sold
from walmart
group by payment_method

Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

Select *
From
( select
branch,
category,
  AVG(rating) as avg_rating,
  RANK() over(partition by branch order by AVG(rating) DESC) as rank
  From walmart
group BY 1, 2
)
where rank = 1

--Q.3 Identify the busiest day for each branch based on the number of transactions

Select *
From
(select
branch,
To_char(to_date(date, 'DD/MM?YY'), 'Day') as day_name,
count(*) as no_transactions,
Rank() over(partition by branch order by count(*) DESC) as rank
from walmart
group by 1, 2
)
where rank =1


--Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity

Select 
payment_method,
count(*) as no_payments,
sum(quantity) as no_quantity_sold
from walmart
group by payment_method


Q.5 
-- Determine the average, minimum, maximum rating of category for each city.
-- List the city, average_rating, min_rating, and max_rating

Select
city, category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart
group by 1, 2

Q.6 
-- Calculate the total profit for each category by considering total_profit as 
-- (unit_price * Quantity * profit_margin).
-- List category and total_profits, ordered from highest to lowest profit.

select 
category,
sum(total) as total_revenue,
sum(total * profit_margin) as profit
from walmart
group by 1

Q.7
--Determine the most common payment method for each branch.
-- Display branch and the preferred_payment_method.

with cte
AS
(Select
branch,
payment_method,
count(*) as total_trans,
rank() Over(partition by branch order by count(*) Desc) as rank
from walmart
group by 1, 2
)
select *
from cte
where rank = 1


Q.8
-- Categorize sales into 3 group Morning, Afternoon, Evening
-- Find out each of the shift and number of invoices

Select
branch,
Case 
when extract(hour from(time::time)) < 12 then 'Morning'
when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
else 'Evening'
end day_time,
count(*) 
from walmart
group by 1, 2
order by 1, 3 DESC\


-- Q.9
-- Identify 5 branch with highest decrease ratio in
-- revenue compare to last year(current year 2023 and last yar 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

select *,
extract(year from To_date(date, 'DD/MM/YY')) as formated_date
from walmart

-- 2022 sales
with revenue_2022
AS
(
select
branch,
sum(total) as revenue
from walmart
where extract(year from To_date(date, 'DD/MM/YY')) = 2022
group by 1
),

revenue_2023
AS
(
select
branch,
sum(total) as revenue
from walmart
where extract(year from To_date(date, 'DD/MM/YY')) = 2023

group by 1
)
select 
ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as cr_year_revenue,
round((ls.revenue - cs.revenue)::numeric/
ls.revenue::numeric * 100,2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by 4 DESC
limit 5