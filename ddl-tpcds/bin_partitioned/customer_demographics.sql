create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists customer_demographics;

create table customer_demographics
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.customer_demographics;
