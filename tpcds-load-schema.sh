#!/bin/bash

STATS_ENGINE=$1
COORDINATOR=$2

function usage {
  echo "usage: tpcds-load-schema <STATS ENGINE> <COORDINATOR>"
  echo "valid values for STATS_ENGINE are 'hive' or 'impala'"
  return 
}

function load_tables {
  hive -i settings/load-flat.sql \
       -f ddl-tpcds/create_externals.sql \
       -d DB=tpcds_bin_partitioned_parquet_1000 \
       -d LOCATION=s3a://tpc/parquet/1000 \
       -d FILE=PARQUET
}

function compute_stats {
  cat settings/impala.sql ddl-tpcds/bin_partitioned/compute.sql | impala-shell -i $coordinator \ 
    -d tpcds_bin_partitioned_parquet_1000 \
    -f -- 2>&1
}

function analyze_tables {
  hive -i settings/load-flat.sql \
       -f ddl-tpcds/bin_partitioned/analyze.sql \
       -d DB=tpcds_bin_partitioned_parquet_1000 \
       -d LOCATION=s3a://tpc/parquet/1000 \
       -d FILE=PARQUET
}

# Sanity checking.
if [ X"$STATS_ENGINE" = "X" ]; then
  usage
fi

if [ $STATS_ENGINE == 'hive' ];then
  load_tables
  analyze_tables
elif [ $STATS_ENGINE == 'impala' ];then
  if [ X"$COORDINATOR" = "X" ]; then
    usage
    return
  fi
  load_tables
  compute_stats
else
  usage
fi
