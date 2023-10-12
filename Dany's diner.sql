create table sales(
    customer_id varchar (10),
    order_date date,
    product_id int 
);
insert into sales VALUES('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

  describe table sales;
  select*from sales;

  create table menu(
      product_id int,
      product_name varchar (20),
      price int
  );

  alter table menu
  add primary key (product_id);

  insert into menu VALUES
('1', 'Sushi', '10'),
('2','Ramen','12'),
('3','Curry', '15');


update menu
set product_name='Curry', price='15'
where product_id=2;

update menu
set product_name='Ramen', price='12'
where product_id=3;

select* from menu;


alter table sales
add foreign key (product_id)
references menu(product_id)
on delete cascade;



  update sales
        set customer_id='1A'
        where customer_id='A';
    update sales
        set customer_id='2B'
        where customer_id='B';
    update sales
        set customer_id='3C'
        where customer_id='C';

       drop table members; 
       

CREATE TABLE members (
  customer_id VARCHAR(5),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('1A', '2023-01-07'),
  ('2B', '2023-01-09');

  alter table members
  add primary key(customer_id);

  update members
  set join_date='2021-01-07'
        where customer_id='1A';

    update members
  set join_date='2021-01-09'
        where customer_id='2B';


  alter table members
  drop primary key;


  select*from sales;
  select*from members;
  select*from menu;

  --1. TOTALAMOUNTSPENTBYEACHCUSTOMER (SOLUTION)
  Select S.customer_id, Sum(M.price)
From Menu m
join Sales s
On m.product_id = s.product_id
group by S.customer_id;

--MYVERSION
select customer_id from sales,
select sum(price) from menu 
join sales
on sales.product_id=menu.product_id
group by customer_id;

--2. number of days each customer visited
Select customer_id,
count(distinct(order_date)) 
From sales
group by customer_id;

--3. first item from menu purchased
  With first_item as(
  SELECT 
  sales.customer_id,
  menu.product_name,
  sales.order_date,
    DENSE_RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY sales.order_date asc) as ranking
  from sales
  join menu
  on menu.product_id=sales.product_id)
Select Customer_id, product_name
From first_item
Where ranking = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
Select menu.product_name , Count(Sales.product_id)
From menu 
join sales 
On menu.product_id = sales.product_id
Group by Menu.product_name
Order by Count(sales.product_id) desc;

--5.  most popular item for each customer
--my version
Select sales.customer_id, menu.product_name, count(sales.product_id) as count
From sales 
join menu 
On menu.product_id = sales.product_id
group by sales.customer_id, sales.product_id, menu.product_name
order by customer_id asc,count desc;

--suggested
With rank as
(
Select S.customer_ID ,
       M.product_name, 
       Count(S.product_id) as Count,
       Dense_rank()  Over (Partition by S.Customer_ID order by Count(S.product_id) DESC ) as Rank
From Menu m
join Sales s
On m.product_id = s.product_id
group by S.customer_id,S.product_id,M.product_name
)
Select Customer_id,Product_name,Count
From rank
where rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
with orderr as(
select sales.customer_id, menu.product_name,sales.order_date,
DENSE_RANK() OVER(partition by sales.customer_id ORDER BY sales.order_date) as ranking
from sales
join menu
on sales.product_id=menu.product_id
join members
on members.customer_id=sales.customer_id
Where Sales.order_date>=members.join_date  
)
select * 
from orderr
where ranking = 1;

-- 7. Which item was purchased just before the customer became a member?
with orderr as(
select sales.customer_id, menu.product_name,sales.order_date,
DENSE_RANK() OVER(partition by sales.customer_id ORDER BY sales.order_date DESC) as ranking
from sales
join menu
on sales.product_id=menu.product_id
join members
on members.customer_id=sales.customer_id
Where Sales.order_date<members.join_date  
)
select * 
from orderr
where ranking = 1;


-- 8. What is the total items and amount spent for each member before they became a member?


select sales.customer_id,count (sales.product_id) as total_items,sum(menu.price) as amount_spent
from sales
join menu
on sales.product_id=menu.product_id
join members
on members.customer_id=sales.customer_id
Where Sales.order_date<members.join_date
group by sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
With Points as
(
Select *, Case When product_name ='sushi' THEN price*20
Else price*10
End as Points
From Menu
)
Select Sales.customer_id, Sum(Points.points) as Points
From Sales 
Join Points 
On points.product_id = Sales.product_id
Group by Sales.customer_id;


--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
Select
        sales.customer_id,
  Sum(CASE
                 When (DATEDIFF(DAY, members.join_date, sales.order_date) between 0 and 7) or (menu.product_ID = 1) Then menu.price * 20
                 Else menu.price * 10
              END) As Points
From members 
    Inner Join sales  on sales.customer_id = members.customer_id
    Inner Join menu on menu.product_id = sales.product_id
where sales.order_date >= members.join_date and sales.order_date <= CAST('2021-01-31' AS DATE)
Group by sales.customer_id;


