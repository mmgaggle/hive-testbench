#!/bin/bash

# done
./tpcds-setup.sh 1000 text s3a://tpc
./tpcds-setup.sh 1000 parquet s3a://tpc s3a://tpc/parquet snappy 1

# todo
time ./tpcds-setup.sh 1000 parquet s3a://tpc s3a://tpc/parquet snappy 10 2>&1 | tee etl-1000-parquet-snappy-10.log
time ./tpcds-setup.sh 1000 parquet s3a://tpc s3a://tpc/parquet none 1 2>&1 | tee etl-1000-parquet-none-1.log
time ./tpcds-setup.sh 1000 parquet s3a://tpc s3a://tpc/parquet none 10 2>&1 | tee etl-1000-parquet-none-10.log
