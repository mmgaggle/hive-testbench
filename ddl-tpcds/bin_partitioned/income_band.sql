create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists income_band;

create table income_band
stored as ${FILE} TBLPROPERTIES ("${FILE}.compress"="${COMPRESSION}")
as select * from ${SOURCE}.income_band;
