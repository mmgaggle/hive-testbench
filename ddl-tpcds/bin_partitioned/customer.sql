create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists customer;

create table customer
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.customer;
