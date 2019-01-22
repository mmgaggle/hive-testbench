#!/bin/bash

QUERY_DIR=$1
run_id=0
COORDINATOR="<INSERT COORDINATOR"

echo "query_set,run_id,engine,format,scale_factor,query,status,start,end,tot_time,query_time,rows" > $1/tpc_stats_${run_id}.log

# done
perl runSuite.pl $QUERY_DIR $run_id spark parquet 1000 snappy 1
perl runSuite.pl $QUERY_DIR $run_id impala parquet 1000 snappy 1 ${COORDINATOR}

# todo
perl runSuite.pl $QUERY_DIR $run_id spark parquet 1000 snappy 10
perl runSuite.pl $QUERY_DIR $run_id impala parquet 1000 snappy 10 ${COORDINATOR}
perl runSuite.pl $QUERY_DIR $run_id spark parquet 1000 none 1
perl runSuite.pl $QUERY_DIR $run_id spark parquet 1000 none 10
perl runSuite.pl $QUERY_DIR $run_id impala parquet 1000 none 1 ${COORDINATOR}
perl runSuite.pl $QUERY_DIR $run_id impala parquet 1000 none 10 ${COORDINATOR}

cp $1/tpc_stats_${run_id}.log $1/tpc_stats_${run_id}.log.`date "+%F-%T"`
