create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists web_page;

create table web_page
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.web_page;
