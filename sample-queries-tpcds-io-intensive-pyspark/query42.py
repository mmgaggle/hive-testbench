from pyspark.context import SparkContext
from pyspark.sql import HiveContext
sc = SparkContext(appName = "query42")
sqlContext = HiveContext(sc)
sqlContext.sql("use tpcds_bin_partitioned_parquet_1000")
sqlContext.sql("""
select  dt.d_year
 	,item.i_category_id
 	,item.i_category
 	,sum(ss_ext_sales_price) as s
 from 	date_dim dt
 	,store_sales
 	,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
 	and store_sales.ss_item_sk = item.i_item_sk
 	and item.i_manager_id = 1  	
 	and dt.d_moy=12
 	and dt.d_year=1998
 group by 	dt.d_year
 		,item.i_category_id
 		,item.i_category
 order by       s desc,dt.d_year
 		,item.i_category_id
 		,item.i_category
limit 100
""");
