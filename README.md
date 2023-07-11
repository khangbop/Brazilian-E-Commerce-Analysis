# Project1
My very 1st project


CÂU HỎI:


olist store là một doanh nghiệp thương mại điện tử (e-commerce business) có trụ sở tại Sao Paolo, Brazil
Nói tiếng Bồ Đào Nha. Tỷ giá 1brl = ~4k5vnd
Dưới đây là dataset của Olist store với 100k đơn hàng trong 3 năm 2016 - 2018. Dataset lấy từ kaggle.com
	https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?select=olist_order_items_dataset.csv


								REPORT KẾT QUẢ KINH DOANH CỦA CÁC LOẠI SP

QUY TRÌNH CỦA PROJECT:
	B1: LÀM SẠCH DỮ LIỆU sử dụng Python (kiểm tra Null, Duplicate,... -> xóa dòng)
	B2: PHÂN TÍCH DỮ LIỆU bằng DBeaver(MySQL)
	B3: TRỰC QUAN HÓA DỮ LIỆU(VISUALIZATION) bằng Power BI (Trực quan hóa dữ liệu lấy từ SQL)

Vậy để biết được kết quả kinh doanh của các sản phẩm.
Ta cần tìm hiểu những yếu tố sau:

- Đầu tiên ta cần tìm tổng giá trị của mỗi đơn hàng(Total order value)
  Bằng cách tổng của giá(price) và giá trị vận chuyển hàng hóa
  (freight value là tiền vận chuyển băng đg gì biển bay xe tàu,.. trọng lượng món hàng, có kèm theo gì ko, giá xăng, trọng tải,... etc)
  Ta có công thức total_order_value = price + freight_value. 
  Nhưng 1 đơn hàng có thể có nhiều sản phẩm
  Nên CT cuối cùng là total_order_value = sum(price) + sum(freight_value)
  EX:  order_id = 00143d0f86d6fbd9f9b38ab440ac16f5 có 3 product_id(cùng loại)
       The total order_item value is: 21.33 * 3 = 63.99
       The total freight value is: 15.10 * 3 = 45.30
       The total order value (product + freight) is: 45.30 + 63.99 = 109.29
  Nói chung là cộng lại toàn bộ trong 1 đơn hàng là dc tổng giá trị mỗi đơn.

* Nhưng chỉ biết tổng giá trị đơn hàng thì vẫn chưa biết dc sp bán chạy nên ta sẽ đi sâu hơn vào từng sp

+ SẢN PHẨM NÀO CÓ DOANH THU CAO NHẤT/ BÁN ĐƯỢC BAO NHIÊU?

- Giá trị của mỗi sp (product_id)										(X)
	SELECT product_id, price 			
	FROM olist_order_items_dataset ooid 
  Nhưng Olist chỉ là doanh nghiệp cầu nối giữa sellers và customers, nên 1 sản phẩm có thể có nhiều giá		(X)
  do từ nhiều nguồn khác nhau.
  Đây là ví dụ về 1sp có nhiều giá. Mình thêm cột danh mục cho dễ nhận biết sp thuộc danh mục nào.
  Và vì đây là doanh nghiệp của Brazil nen toàn tiếng BĐN nên mình thêm cột tiếng anh.
  --> vậy để biết giá trị mỗi sp ta nên tính giá trung bình vì giá của 1 sp sẽ không giao động quá nhiều	(X)
  Ta đc:
	SELECT ooid.product_id, round(avg(ooid.price)), pcnt.product_category_name_english 
	FROM olist_order_items_dataset ooid 
	join olist_products_dataset opd on ooid.product_id = opd.product_id 					(X)
	join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name 
	GROUP BY ooid.product_id, pcnt.product_category_name_english 
	ORDER BY round(avg(price)) DESC 
  Giá TB của từng sản phẩm phân loại theo danh mục								(X)

- Số lượng sản phẩm bán ra(product_id)
  Ta có:
	select product_id, count(*) 
	FROM olist_order_items_dataset ooid 
	group by product_id
  Thêm vào cột danh mục để phân loại sản phẩm
  Vậy ta biết được sản phẩm aca2eb7d00ea1a7b8ebd4e68314663af (thuộc danh mục trang trí nội thất furniture_deco) bán được nhiều nhất.
 
+ DANH MỤC MẶT HÀNG NÀO CÓ DOANH THU CAO NHẤT/ BÁN ĐƯỢC BAO NHIÊU?

- Đối với danh mục sản phẩm bán chạy nhất
  ta cũng tương tự bên trên và group by lại
  Nhưng bây giờ danh mục bán chạy nhất lại là bed_bath_table

- Ta cần tính tổng doanh thu của từng sản phẩm 
  Bởi vì tính tổng doanh thu nên ta cần cả giá sp(price) và chi phí vận chuyển(freight value)
  Kết hợp bảng tính số lượng sp bán ra và bảng tổng giá trị đơn hàng tính ở trên
  Ta được:
	SELECT product_id, (sum(price)+sum(freight_value)) as total_price
	FROM olist_order_items_dataset ooid 
	group by product_id 
	order by total_price DESC 
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

- Khu vực nào bán chạy nhất? Cái này mình sẽ tính theo Bang(state) nếu dựa vào tp thì nhiều lắm.
  join 3 bảng order_item, orders và customers.
  Đầu tiên ta tính số đơn bán dc ở từng bang
	SELECT ocd.customer_state, count(ooid.order_id) 
	FROM olist_order_items_dataset ooid 
	JOIN olist_orders_dataset ood ON ooid.order_id = ood.order_id 
	JOIN olist_customers_dataset ocd ON ood.customer_id = ocd.customer_id 
	GROUP BY ocd.customer_state 
	ORDER BY count(ooid.order_id) DESC 
  Sau đó ta tính tổng doanh thu từng bang bằng cách join bảng total_order_value
  và bảng liệt kê các đơn ở mỗi bang

/////////////////////////////////////////////////////////////////////////////////////////////////////////////  

- Số đơn bán ra theo năm
  Doanh thu bán ra theo năm
  --> năm 2018 bán được nhiều đơn nhất
  --> doanh thu năm 2018 cũng cao nhất

- Số đơn bán ra theo ngày
  Doanh thu bán ra theo ngày
  --> ngày 24/11/2017 bán nhiều đơn nhất
  --> ngày 24/11/2017 có doanh thu cao nhất
=> 24/11/2017 rơi vào BlackFriday
