create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists time_dim;

create table time_dim
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.time_dim;
