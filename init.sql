drop table if exists users cascade

create table user (id bigint not null, created_timestamp timestamp(6) with time zone, date_of_birth varchar(255), updated_timestamp timestamp(6) with time zone, username varchar(255), version bigint, primary key (id))