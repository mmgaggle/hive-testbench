#!/bin/bash

QUERY_DIR=$1
run_id=0

echo "query_set,run_id,engine,format,scale_factor,query,status,start,end,tot_time,query_time,rows" > $1/tpc_stats_${run_id}.log

#run 1TB queries
perl runSuite.pl $QUERY_DIR $run_id spark parquet 1000
perl runSuite.pl $QUERY_DIR $run_id presto orc 1000
#perl runSuite.pl $QUERY_DIR $run_id hive orc 1000
#perl runSuite.pl $QUERY_DIR $run_id hive-spark orc 1000

#run 10TB queries
perl runSuite.pl $QUERY_DIR $run_id spark parquet 10000
perl runSuite.pl $QUERY_DIR $run_id presto orc 10000
#perl runSuite.pl $QUERY_DIR $run_id hive orc 10000
#perl runSuite.pl $QUERY_DIR $run_id hive-spark orc 10000

#run 100TB queries
#perl runSuite.pl $QUERY_DIR $run_id presto orc 100000
#perl runSuite.pl $QUERY_DIR $run_id spark parquet 100000
#perl runSuite.pl $QUERY_DIR $run_id hive orc 100000
#perl runSuite.pl $QUERY_DIR $run_id hive-spark orc 100000

cp $1/tpc_stats_${run_id}.log $1/tpc_stats_${run_id}.log.`date "+%F-%T"`
