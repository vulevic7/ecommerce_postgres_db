create table addresses
(
    address_id    serial
        primary key,
    user_id       integer
        references users,
    address_line1 varchar(255),
    address_line2 varchar(255),
    city          varchar(100),
    postal_code   varchar(20),
    country       varchar(100)
);

alter table addresses
    owner to postgres;

create index idx_addresses_user_id
    on addresses (user_id);

grant delete, insert, references, select, trigger, truncate, update on addresses to admin_role;

grant insert, select, update on addresses to manager_role;

grant select on addresses to readonly_role;

