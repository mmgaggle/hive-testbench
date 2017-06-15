#!/bin/bash

QUERY_DIR=$1
CONCURRENCY=$2

for x in `seq 1 $CONCURRENCY`
do
   echo "query_set,run_id,engine,format,scale_factor,query,status,start,end,tot_time,query_time,rows" > $1/tpc_stats_$x.log
done


#for scale in 1000 10000 100000 
for scale in 1000 10000 
do
   #for engine_format in "presto orc" "spark parquet" "hive orc" "hive-spark orc" 
   for engine_format in "spark parquet" "presto orc"   
   do
      for x in `seq 1 $CONCURRENCY`
      do
      perl runSuite.pl $QUERY_DIR $x $engine_format $scale &
      done
      wait
   done
done

cp $1/tpc_stats_$x.log $1/tpc_stats_$x.log.`date "+%F-%T"`
