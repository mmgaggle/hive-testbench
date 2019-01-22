create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists reason;

create table reason
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.reason;
