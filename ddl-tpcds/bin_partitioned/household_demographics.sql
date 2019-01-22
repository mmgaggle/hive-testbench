create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists household_demographics;

create table household_demographics
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.household_demographics;
