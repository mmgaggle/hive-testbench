create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists item;

create table item
stored as ${FILE}
as select * from ${SOURCE}.item;
