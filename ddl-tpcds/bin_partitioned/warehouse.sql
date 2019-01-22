create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists warehouse;

create table warehouse
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.warehouse;
