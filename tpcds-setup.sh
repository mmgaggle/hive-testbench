#!/bin/bash

function usage {
  echo "Usage: "
  echo "       tpcds-setup.sh <scale factor> text <target>"
  echo "       tpcds-setup.sh <scale factor> [ parquet | orc ] <text location> <target location> ... [ snappy | zlib | none ] <files per partition>"
  exit 1
}

function runcommand {
  if [ "X$DEBUG_SCRIPT" != "X" ]; then
    $1
  else
    $1 2>/dev/null
  fi
}

function generate {
  hdfs dfs -ls ${DIR}/${SCALE} > /dev/null
  if [ $? -ne 0 ]; then
    echo "Generating data at scale factor $SCALE."
    (cd tpcds-gen; hadoop jar target/*.jar -d ${DIR}/${SCALE}/ -s ${SCALE})
  fi
  hdfs dfs -ls ${DIR}/text/${SCALE} > /dev/null
  if [ $? -ne 0 ]; then
    echo "Data generation failed, exiting."
    exit 1
  fi
  echo "TPC-DS text data generation complete."
}

function etl {
  # Create the text/flat tables as external tables. These will be later be converted to a columnar format
  echo "Loading text data into external tables."
  runcommand "hive -i settings/load-flat.sql -f ddl-tpcds/text/alltables.sql -d DB=tpcds_text_${SCALE} -d LOCATION=${DIR}/${SCALE}"

  # Create the partitioned and bucketed tables.
  LOAD_FILE="load_${FORMAT}_${SCALE}.mk"
  SILENCE="2> /dev/null 1> /dev/null" 
  if [ "X$DEBUG_SCRIPT" != "X" ]; then
    SILENCE=""
  fi

  echo -e "all: ${DIMS} ${FACTS}" > $LOAD_FILE

  i=1
  total=24
  DATABASE=tpcds_bin_partitioned_${FORMAT}_${SCALE}_${COMPRESSION}_${PART_FILES}

  # Populate the smaller tables.
#  for t in ${DIMS}; do
#    COMMAND="hive -i settings/load-partitioned.sql \
#                  -f ddl-tpcds/bin_partitioned/${t}.sql \
#                  -d DB=tpcds_bin_partitioned_${FORMAT}_${SCALE}_${COMPRESSION}_${PART_FILES} \
#                  -d SOURCE=tpcds_text_${SCALE} \
#                  -d SCALE=${SCALE} \
#	          -d FILE=${FORMAT} \
#                  -d LOCATION=${LOCATION} \
#                  -d COMPRESSION=${COMPRESSION} \
#	 	  -d FILES=${PART_FILES} "
#    echo -e "${t}:\n\t@$COMMAND $SILENCE && echo 'Optimizing table $t ($i/$total).'" >> $LOAD_FILE
#    i=`expr $i + 1`
#  done
  for t in ${FACTS}; do
    COMMAND="hive -i settings/load-partitioned.sql \
                  -f ddl-tpcds/bin_partitioned/${t}.sql \
	          -d DB=tpcds_bin_partitioned_${FORMAT}_${SCALE}_${COMPRESSION}_${PART_FILES} \
                  -d SCALE=${SCALE} \
	          -d SOURCE=tpcds_text_${SCALE} \
                  -d FILE=${FORMAT} \
                  -d LOCATION=${LOCATION} \
                  -d COMPRESSION=${COMPRESSION} \
                  -d PART_FILES=${PART_FILES} "
    echo -e "${t}:\n\t@$COMMAND $SILENCE && echo 'Optimizing table $t ($i/$total).'" >> $LOAD_FILE
    i=`expr $i + 1`
  done

  make -j 1 -f $LOAD_FILE

  echo "Data loaded into database ${DATABASE}."
}

if [ ! -f tpcds-gen/target/tpcds-gen-1.0-SNAPSHOT.jar ]; then
  echo "Please build the data generator with ./tpcds-build.sh first"
  exit 1
fi
which hive > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Script must be run where Hive is installed"
  exit 1
fi

# Tables in the TPC-DS schema.
#DIMS="date_dim time_dim item customer customer_demographics household_demographics customer_address store promotion warehouse ship_mode reason income_band call_center web_page catalog_page web_site"
DIMS=""
#FACTS="store_sales store_returns web_sales web_returns catalog_sales catalog_returns inventory"
FACTS="store_sales web_sales web_returns catalog_sales catalog_returns inventory"

# Get the parameters.
SCALE=$1
FORMAT=$2
DIR=$3
LOCATION=$4
COMPRESSION=${5:-snappy}
PART_FILES=${6:-1}

if [ "X$DEBUG_SCRIPT" != "X" ]; then
  set -x
fi

# Sanity checking.
if [ X"$SCALE" = "X" ]; then
  usage
fi
if [ X"$FORMAT" = "X" ]; then
  usage
fi
if [ X"$DIR" = "X" ]; then
  DIR=/tmp/tpcds-generate
fi
if [ $SCALE -eq 1 ]; then
  echo "Scale factor must be greater than 1"
  exit 1
fi

if [ "$FORMAT" = "text" ];then
  generate
elif [ "$FORMAT" = "orc" ] || [ "$FORMAT" = "parquet" ];then
  if [ "$COMPRESSION" = "snappy" ] || [ "$COMPRESSION" = "zlib" ] || [ "$COMPRESSION" = "none" ];then
    etl
  else
    echo "Compression must be set to [snappy|gzip|none]"
    usage
  fi
else
  echo "Format must be set to [text|orc|parquet]"
  usage
fi

