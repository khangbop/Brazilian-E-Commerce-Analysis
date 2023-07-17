
TỔNG DOANH THU CỦA TỪNG ĐƠN HÀNG

#Tổng giá trị mỗi đơn hàng (Total order value)
SELECT order_id, (sum(price)+sum(freight_value)) as total_order_value 
FROM olist_order_items_dataset ooid 
GROUP BY order_id
ORDER BY total_order_value

#Tổng giá trị mỗi đơn hàng ứng vs danh mục sp(loại)
SELECT ooid.order_id, (sum(ooid.price)+sum(ooid.freight_value)) as total_order_value, opd.product_category_name 
FROM olist_order_items_dataset ooid 
left JOIN olist_products_dataset opd 
ON ooid.product_id = opd.product_id 
GROUP BY ooid.order_id , opd.product_category_name
ORDER BY total_order_value 


-----------------------------------------------------------------------------------------------------------------


#Giá(price) của từng sp 
SELECT product_id, price 
FROM olist_order_items_dataset ooid 

#Ví dụ về 1sp có nhiều giá
SELECT ooid.product_id, ooid.price, opd.product_category_name, pcnt.product_category_name_english 
FROM olist_order_items_dataset ooid  
join olist_products_dataset opd on ooid.product_id = opd.product_id 
JOIN product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name 
where ooid.product_id in ('6ff1fc9209c7854704a4f75c9fac41b4')

#Giá TRUNG BÌNH từng sản phẩm
SELECT product_id, round(avg(price))
FROM olist_order_items_dataset ooid 
GROUP BY product_id
ORDER BY round(avg(price))

#Giá TRUNG BÌNH từng sản phẩm phân loại theo danh mục TA
SELECT ooid.product_id, round(avg(ooid.price)), pcnt.product_category_name_english 
FROM olist_order_items_dataset ooid 
join olist_products_dataset opd on ooid.product_id = opd.product_id 
join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name 
GROUP BY ooid.product_id, pcnt.product_category_name_english 
ORDER BY round(avg(price)) DESC 


-----------------------------------------------------------------------------------------------------------------
SẢN PHẨM CÓ SỐ LƯỢNG BÁN RA CAO NHẤT
-----------------------------------------------------------------------------------------------------------------


#Số lượng sp bán ra
select product_id, count(*) as num
FROM olist_order_items_dataset ooid 
group by product_id
ORDER BY num DESC 

#Số lượng sản phẩm bán ra phân loại theo danh mục
with number_product as
(select product_id, count(*) as num
FROM olist_order_items_dataset ooid 
group by product_id )
SELECT np.product_id, pcnt.product_category_name_english, np.num
FROM number_product as np
join olist_products_dataset opd on np.product_id = opd.product_id 
join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
order by np.num DESC 

-----------------------------------------------------------------------------------------------------------------
SẢN PHẨM CÓ DOANH THU CAO NHẤT
-----------------------------------------------------------------------------------------------------------------


SELECT product_id, (sum(price)+sum(freight_value)) AS product_value
FROM olist_order_items_dataset ooid 
GROUP BY product_id 
ORDER BY product_value DESC


-----------------------------------------------------------------------------------------------------------------
DANH MỤC MẶT HÀNG CÓ SỐ LƯỢNG BÁN ĐƯỢC NHIỀU NHẤT
-----------------------------------------------------------------------------------------------------------------


#Danh mục sản phẩm bán chạy nhất
with number_product as
(select product_id, count(*) as num
FROM olist_order_items_dataset ooid 
group by product_id )
SELECT pcnt.product_category_name_english, sum(np.num)
FROM number_product as np
join olist_products_dataset opd on np.product_id = opd.product_id 
join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name
group by pcnt.product_category_name_english
order by sum(np.num) DESC


-----------------------------------------------------------------------------------------------------------------
DANH MỤC MẶT HÀNG CÓ DOANH THU CAO NHẤT
-----------------------------------------------------------------------------------------------------------------


SELECT pcnt.product_category_name_english, (sum(ooid.price)+sum(ooid.freight_value)) AS total_product_value
FROM olist_order_items_dataset ooid 
JOIN olist_products_dataset opd ON ooid.product_id = opd.product_id 
JOIN product_category_name_translation pcnt ON opd.product_category_name  = pcnt.product_category_name 
GROUP BY pcnt.product_category_name_english 
ORDER BY total_product_value DESC 


-----------------------------------------------------------------------------------------------------------------


#Bảng kết hợp
SELECT product_id, round(avg(price)), count(*) 
FROM olist_order_items_dataset ooid 
GROUP BY product_id
ORDER BY round(avg(price)) DESC 

SELECT product_id, round(avg(price)), count(*) 
FROM olist_order_items_dataset ooid 
GROUP BY product_id
ORDER BY count(*) DESC

SELECT product_id, round(avg(price)), count(*) 
FROM olist_order_items_dataset ooid 
GROUP BY product_id
HAVING avg(price)>1000

SELECT product_id, round(avg(price)), count(*) 
FROM olist_order_items_dataset ooid 
GROUP BY product_id
HAVING avg(price)<1000


-----------------------------------------------------------------------------------------------------------------
PHÂN LOẠI SẢN PHẨM THEO DANH MỤC
-----------------------------------------------------------------------------------------------------------------


#Tên sản phẩm ứng vs danh mục sản phẩm(loại sp) tiếng anh
SELECT opd.product_id, opd.product_category_name, pcnt.product_category_name_english 
FROM olist_products_dataset opd 
JOIN product_category_name_translation pcnt 
ON opd.product_category_name = pcnt.product_category_name 


-----------------------------------------------------------------------------------------------------------------
KHU VỰC NÀO CÓ TỔNG DOANH THU CAO NHẤT/BÁN ĐƯỢC BAO NHIÊU ĐƠN/BAO NHIÊU SP?
-----------------------------------------------------------------------------------------------------------------


#Khu vực(Bang) nào số đơn nhiều nhất
SELECT ocd.customer_state, count(ooid.order_id) 
FROM olist_order_items_dataset ooid 
JOIN olist_orders_dataset ood ON ooid.order_id = ood.order_id 
JOIN olist_customers_dataset ocd ON ood.customer_id = ocd.customer_id 
GROUP BY ocd.customer_state 
ORDER BY count(ooid.order_id) DESC 

#Khu vực(Bang) nào có tổng doanh thu cao nhất
WITH order_state AS
    (SELECT ocd.customer_state, ooid.order_id
    FROM olist_order_items_dataset ooid 
    INNER JOIN olist_orders_dataset ood ON ooid.order_id = ood.order_id 
    INNER JOIN olist_customers_dataset ocd ON ood.customer_id = ocd.customer_id),
     
    total_order AS 
    (SELECT ooid2.order_id, (sum(ooid2.price)+sum(ooid2.freight_value)) as total_order_value 
    FROM olist_order_items_dataset ooid2 
    GROUP BY ooid2.order_id)
    
SELECT order_state.customer_state, sum(total_order.total_order_value)
FROM order_state
JOIN total_order
ON order_state.order_id = total_order.order_id
GROUP BY order_state.customer_state
ORDER BY round(sum(total_order.total_order_value)) DESC 

#Khu vực bán bao nhiêu sp
SELECT ocd.customer_state, count(ooid.product_id) AS num_product
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood ON ocd.customer_id = ood.customer_id 
JOIN olist_order_items_dataset ooid ON ood.order_id = ooid.order_id 
GROUP BY ocd.customer_state 
ORDER BY num_product DESC

#Khu Vực bán bn sp theo danh mục
SELECT ocd.customer_state, pcnt.product_category_name_english, count(ooid.product_id)
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood ON ocd.customer_id = ood.customer_id 
JOIN olist_order_items_dataset ooid ON ood.order_id = ooid.order_id 
JOIN olist_products_dataset opd ON opd.product_id = ooid.product_id 
JOIN product_category_name_translation pcnt ON opd.product_category_name = pcnt.product_category_name
GROUP BY ocd.customer_state, pcnt.product_category_name_english 
ORDER BY ocd.customer_state DESC 


-----------------------------------------------------------------------------------------------------------------
DOANH THU, SỐ LƯỢNG ĐƠN, SỐ LƯỢNG SP BÁN RA THEO NĂM 
-----------------------------------------------------------------------------------------------------------------


#số đơn bán ra theo năm
SELECT count(order_id), order_status, YEAR(order_purchase_timestamp) 
FROM olist_orders_dataset ood 
WHERE order_status IN ('delivered','approved','created','shipped','processing','invoiced')
GROUP BY YEAR(order_purchase_timestamp)

#Doanh thu bán ra theo năm
WITH total_order AS 
(SELECT order_id, (sum(price)+sum(freight_value)) as total_order_value 
FROM olist_order_items_dataset ooid 
GROUP BY order_id
ORDER BY total_order_value)
SELECT YEAR(ood.order_purchase_timestamp), sum(total_order.total_order_value) 
FROM olist_orders_dataset ood 
JOIN total_order
ON total_order.order_id = ood.order_id 
WHERE ood.order_status IN ('delivered','approved','created','shipped','processing','invoiced')
GROUP BY YEAR(ood.order_purchase_timestamp)

#SỐ lượng sp bán ra theo năm
SELECT YEAR(ood.order_purchase_timestamp), count(ooid.product_id)  
FROM olist_orders_dataset ood 
JOIN olist_order_items_dataset ooid 
ON ood.order_id = ooid.order_id 
GROUP BY YEAR(ood.order_purchase_timestamp)

#số đơn bán ra theo ngày
SELECT count(order_id), order_status, date(order_purchase_timestamp) 
FROM olist_orders_dataset ood 
WHERE order_status IN ('delivered','approved','created','shipped','processing','invoiced')
GROUP BY date(order_purchase_timestamp)
ORDER BY count(order_id) DESC 

#Doanh thu bán ra theo ngày
WITH total_order AS 
(SELECT order_id, (sum(price)+sum(freight_value)) as total_order_value 
FROM olist_order_items_dataset ooid 
GROUP BY order_id
ORDER BY total_order_value)
SELECT Date(ood.order_purchase_timestamp), sum(total_order.total_order_value) 
FROM olist_orders_dataset ood 
JOIN total_order
ON total_order.order_id = ood.order_id 
WHERE ood.order_status IN ('delivered','approved','created','shipped','processing','invoiced')
GROUP BY date(ood.order_purchase_timestamp)
ORDER BY sum(total_order.total_order_value) DESC 

#Số lượng sản phẩm bán ra theo ngày
SELECT DATE(ood.order_purchase_timestamp), count(ooid.product_id)  
FROM olist_orders_dataset ood 
JOIN olist_order_items_dataset ooid 
ON ood.order_id = ooid.order_id 
GROUP BY DATE(ood.order_purchase_timestamp)
ORDER BY count(ooid.product_id) DESC 
