create database if not exists ${DB} location "${LOCATION}";
use ${DB};

drop table if exists inventory;

create table inventory
(
    inv_item_sk          bigint,
    inv_warehouse_sk		bigint,
    inv_quantity_on_hand	int
)
partitioned by (inv_date_sk bigint)
stored as ${FILE};
