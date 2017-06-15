#!/bin/bash

TEXT_DIR=s3a://tpc

#generate 1TB tables for orc and parquet
./tpcds-setup.sh 1000 orc $TEXT_DIR
./tpcds-setup.sh 1000 parquet $TEXT_DIR

#generate 10TB tables for orc and parquet
./tpcds-setup.sh 10000 orc $TEXT_DIR
./tpcds-setup.sh 10000 parquet $TEXT_DIR

#generate 100TB tables for orc and parquet
./tpcds-setup.sh 100000 orc $TEXT_DIR
./tpcds-setup.sh 100000 parquet $TEXT_DIR
