from pyspark.context import SparkContext
from pyspark.sql import HiveContext
sc = SparkContext(appName = "query32")
sqlContext = HiveContext(sc)
sqlContext.sql("use tpcds_bin_partitioned_parquet_1000")
sqlContext.sql("""
SELECT sum(cs1.cs_ext_discount_amt) as excess_discount_amount
FROM (SELECT cs.cs_item_sk as cs_item_sk,
                             cs.cs_ext_discount_amt as cs_ext_discount_amt
             FROM catalog_sales cs
             JOIN date_dim d ON (d.d_date_sk = cs.cs_sold_date_sk)
             WHERE d.d_date between '2000-01-27' and '2000-04-27') cs1
JOIN item i ON (i.i_item_sk = cs1.cs_item_sk)
JOIN (SELECT cs2.cs_item_sk as cs_item_sk,
                          1.3 * avg(cs_ext_discount_amt) as avg_cs_ext_discount_amt
           FROM (SELECT cs.cs_item_sk as cs_item_sk,
                                        cs.cs_ext_discount_amt as cs_ext_discount_amt
                        FROM catalog_sales cs
                        JOIN date_dim d ON (d.d_date_sk = cs.cs_sold_date_sk)
                        WHERE d.d_date between '2000-01-27' and '2000-04-27') cs2
                        GROUP BY cs2.cs_item_sk) tmp1
ON (i.i_item_sk = tmp1.cs_item_sk)
WHERE i.i_manufact_id = 436 and
               cs1.cs_ext_discount_amt > tmp1.avg_cs_ext_discount_amt
""");
