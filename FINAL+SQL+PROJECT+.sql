# MY SQL PROJECT Submitted by Kushal Singhal

USE ORDERS;
SHOW TABLES;

# 1. Write a query to Display the product details (product_class_code, product_id, product_desc, product_price,) as per the following criteria 
# and sort them in descending order of category: a. If the category is 2050, increase the price by 2000 b. If the category is 2051, 
# increase the price by 500 c. If the category is 2052, increase the price by 600.

SELECT PRODUCT_CLASS_CODE,PRODUCT_ID,PRODUCT_DESC,PRODUCT_PRICE,
CASE
WHEN PRODUCT_CLASS_CODE = 2050 THEN PRODUCT_PRICE+2000 
WHEN PRODUCT_CLASS_CODE = 2051 THEN PRODUCT_PRICE+500 
WHEN PRODUCT_CLASS_CODE = 2052 THEN PRODUCT_PRICE+600 
ELSE PRODUCT_PRICE 
END as NEW_PRICE
FROM PRODUCT order by PRODUCT_CLASS_CODE desc;

# 2. Write a query to display (product_class_desc, product_id, product_desc, product_quantity_avail ) and Show inventory status of products 
# as below as per their available quantity: a. For Electronics and Computer categories, if available quantity is <= 10, show 'Low stock', 
# 11 <= qty <= 30, show 'In stock', >= 31, show 'Enough stock' b. For Stationery and Clothes categories, if qty <= 20, show 'Low stock', 
# 21 <= qty <= 80, show 'In stock', >= 81, show 'Enough stock' c. Rest of the categories, if qty <= 15 – 'Low Stock', 
# 16 <= qty <= 50 – 'In Stock', >= 51 – 'Enough stock' For all categories, if available quantity is 0, show 'Out of stock'.

SELECT pc.product_class_desc, p.product_id, p.product_desc, p.product_quantity_avail, 
CASE
WHEN p.product_quantity_avail > 0 THEN
(CASE
WHEN pc.product_class_desc in ('Computer','Electronics') THEN 
(CASE
WHEN p.product_quantity_avail<=10 THEN 'Low Stock'
WHEN (p.product_quantity_avail >=11 AND p.product_quantity_avail <=30) THEN 'In Stock'
WHEN p.product_quantity_avail >=31 THEN'Enough Stock'
END)
WHEN pc.product_class_desc in ('Stationery','Clothes') THEN
(CASE
WHEN p.product_quantity_avail<=20 THEN 'Low Stock'
WHEN p.product_quantity_avail >=21 AND p.product_quantity_avail <=80 THEN 'In Stock'
WHEN p.product_quantity_avail >=81 THEN'Enough Stock'
END)
WHEN pc.product_class_desc NOT IN ('Computer','Electronics','Stationery','Clothes') THEN
(CASE
WHEN p.product_quantity_avail<=15 THEN 'Low Stock'
WHEN p.product_quantity_avail >=16 AND p.product_quantity_avail <=50 THEN 'In Stock'
WHEN p.product_quantity_avail >=51 THEN'Enough Stock'
END)
ELSE 'Out of Stock'
END)
END Inventory_Status
FROM product p JOIN product_class pc
ON p.product_class_code = pc.product_class_code;

# 3. Write a query to show the number of cities in all countries other than USA & MALAYSIA, with more than 1 city, in the descending order 
# of CITIES. 

SELECT COUNTRY, COUNT(CITY) FROM ADDRESS
WHERE COUNTRY NOT IN ('USA','MALAYSIA')
GROUP BY COUNTRY 
HAVING COUNT(CITY)>1
ORDER BY COUNT(CITY) DESC;

# 4. Write a query to display the customer_id,customer full name ,city,pincode,and order details (order id, product class desc, product desc,
# subtotal(product_quantity * product_price)) for orders shipped to cities whose pin codes do not have any 0s in them. Sort the output on 
# customer name and subtotal. 

SELECT oc.customer_id,CONCAT(oc.customer_fname,oc.customer_lname) full_name,ad.city,ad.pincode,
oi.order_id, pc.product_class_desc, p.product_desc,oi.product_quantity*p.product_price AS subtotal 
FROM order_items oi JOIN product p
ON oi.product_id = p.product_id JOIN product_class pc 
ON p.product_class_code=pc.product_class_code 
LEFT JOIN order_header oh ON oh.order_id=oi.order_id 
LEFT JOIN online_Customer oc ON oh.customer_id = oc.customer_id
LEFT JOIN address ad ON oc.address_id = ad.address_id 
WHERE oh.order_status = 'Shipped' AND ad.pincode NOT LIKE '%0%';

# 5. Write a Query to display product id,product description,totalquantity(sum(product quantity) for a given item whose product id is 201 
# and which item has been bought along with it maximum no. of times. Display only one record which has the maximum value for total quantity
#  in this scenario. 

SELECT oi.product_id,p.product_desc,SUM(oi.product_quantity) AS totalquantity
FROM order_items oi JOIN product p ON oi.product_id=oi.product_id
WHERE oi.order_id IN (SELECT DISTINCT order_id FROM order_items oi WHERE product_id = 201) AND oi.product_id !=201
GROUP BY oi.product_id,p.product_desc ORDER BY totalquantity desc LIMIT 1;

# 6. Write a query to display the customer_id,customer name, email and order details (order id, product desc,product qty, 
# subtotal(product_quantity * product_price)) for all customers even if they have not ordered any item

SELECT oc.customer_id,oc.customer_fname,oc.customer_email,oh.order_id,oi.product_id,oi.product_quantity,p.product_desc,
oi.product_quantity * p.product_price AS subtotal
FROM online_customer oc LEFT JOIN order_header oh ON oc.customer_id = oh.customer_id
LEFT JOIN order_items oi ON oh.order_id=oi.order_id
LEFT JOIN product p ON oi.product_id=p.product_id;

# 7. Write a query to display carton id, (len*width*height) as carton_vol and identify the optimum carton (carton with the least volume 
# whose volume is greater than the total volume of all items (len * width * height * product_quantity)) for a given order whose order id 
# is 10006, Assume all items of an order are packed into one single carton

SELECT CARTON_ID,(len*width*height) AS CARTON_VOLUME FROM carton 
HAVING CARTON_VOLUME > ((SELECT SUM((oi.PRODUCT_QUANTITY*p.len*p.width*p.height)) as TOTAL_VOLUME
FROM order_items AS oi JOIN product AS P ON oi.product_id=p.product_id where ORDER_ID=10006)) ORDER BY CARTON_VOLUME LIMIT 1;

# 8.  Write a query to display details (customer id,customer fullname,order id,product quantity) of customers who bought more than ten
# (i.e. total order qty) products with credit card or Net banking as the mode of payment per shipped order.

SELECT oc.CUSTOMER_ID,Concat(oc.CUSTOMER_FNAME,' ',oc.Customer_lname) as Customer_fullname,oh.ORDER_ID,oh.Payment_Mode,
SUM(oi.PRODUCT_QUANTITY) as PRODUCT_QUANTITY
FROM online_customer oc JOIN order_header oh on oc.CUSTOMER_ID=oh.CUSTOMER_ID JOIN order_items as oi ON oh.order_id=oi.order_id
WHERE oh.order_status='Shipped' AND oh.order_id IN (SELECT ORDER_ID FROM order_items GROUP BY ORDER_ID HAVING SUM(PRODUCT_QUANTITY)>10) 
GROUP BY ORDER_ID Having oh.Payment_Mode in ('Net Banking','Credit Card');

# 9. Write a query to display the order_id, customer id and cutomer full name of customers starting with the alphabet "A" along with 
# (product_quantity) as total quantity of products shipped for order ids > 10030. 

SELECT oc.customer_id,Concat(customer_fname,'',customer_lname) AS customer_full_name,oh.order_id,SUM(oi.product_quantity) AS Total_Quantity
FROM Online_Customer oc JOIN order_header oh ON oh.customer_id = oc.customer_id
JOIN order_items oi ON oh.order_id = oi.order_id 
WHERE (oh.order_status ='Shipped'AND oh.order_id > 10030 AND customer_fname LIKE "A%")
GROUP BY oh.order_id;

# 10. Write a query to display product class description ,total quantity (sum(product_quantity),Total value (product_quantity * product price)
# and show which class of products have been shipped highest(Quantity) to countries outside India other than USA? Also show the total value
# of those items.

SELECT c.PRODUCT_CLASS_DESC,SUM(PRODUCT_QUANTITY) AS TOTAL_QUANTITY ,SUM(b.PRODUCT_PRICE*a.PRODUCT_QUANTITY) AS TOTAL_VALUE
FROM order_items AS a JOIN product AS b ON a.product_id = b.product_id 
JOIN product_class AS c ON b.PRODUCT_CLASS_CODE = c.PRODUCT_CLASS_CODE 
JOIN order_header AS d ON a.ORDER_ID=d.ORDER_ID
JOIN online_customer AS e ON d.CUSTOMER_ID=e.CUSTOMER_ID
JOIN address AS f ON e.ADDRESS_ID=f.ADDRESS_ID
WHERE COUNTRY NOT IN ('India','USA')
GROUP BY PRODUCT_CLASS_DESC
ORDER BY Total_Quantity DESC
LIMIT 1;
