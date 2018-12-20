from pyspark.context import SparkContext
from pyspark.sql import HiveContext
sc = SparkContext(appName = "query43")
sqlContext = HiveContext(sc)
sqlContext.sql("use tpcds_bin_partitioned_parquet_1000")
sqlContext.sql("""
select  s_store_name, s_store_id,
        sum(case when (d_day_name='Sunday') then ss_sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then ss_sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then ss_sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then ss_sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then ss_sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then ss_sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then ss_sales_price else null end) sat_sales
 from date_dim, store_sales, store
 where date_dim.d_date_sk = store_sales.ss_sold_date_sk and
       store.s_store_sk = store_sales.ss_store_sk and
       s_gmt_offset = -6 and
       d_year = 1998
 group by s_store_name, s_store_id
 order by s_store_name, s_store_id,sun_sales,mon_sales,tue_sales,wed_sales,thu_sales,fri_sales,sat_sales
 limit 100
""");
