create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists store;

create table store
stored as ${FILE};
