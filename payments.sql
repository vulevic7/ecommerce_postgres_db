create table payments
(
    payment_id     serial
        primary key,
    order_id       integer
        references orders,
    payment_date   timestamp default CURRENT_TIMESTAMP,
    payment_method varchar(50),
    amount         numeric(10, 2) not null
);

alter table payments
    owner to postgres;

create index idx_payments_order_id
    on payments (order_id);

grant delete, insert, references, select, trigger, truncate, update on payments to admin_role;

grant insert, select, update on payments to manager_role;

grant select on payments to readonly_role;

