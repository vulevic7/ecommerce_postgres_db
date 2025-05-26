create table orders
(
    order_id     serial
        primary key,
    user_id      integer
        references users,
    order_date   timestamp   default CURRENT_TIMESTAMP,
    status       varchar(50) default 'pending'::character varying,
    total_amount numeric(10, 2) not null
);

alter table orders
    owner to postgres;

create index idx_orders_user_id
    on orders (user_id);

create index idx_orders_order_date
    on orders (order_date);

create index idx_orders_status
    on orders (status);

grant delete, insert, references, select, trigger, truncate, update on orders to admin_role;

grant insert, select, update on orders to manager_role;

grant insert, select on orders to staff_role;

grant select on orders to readonly_role;

