create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists promotion;

create table promotion
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.promotion;
