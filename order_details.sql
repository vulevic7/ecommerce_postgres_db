create table order_details
(
    order_id   integer        not null
        references orders
            on delete cascade,
    product_id integer        not null
        references products,
    quantity   integer        not null,
    price      numeric(10, 2) not null,
    primary key (order_id, product_id)
);

alter table order_details
    owner to postgres;

create index idx_order_details_order_id
    on order_details (order_id);

create index idx_order_details_product_id
    on order_details (product_id);

grant delete, insert, references, select, trigger, truncate, update on order_details to admin_role;

grant insert, select, update on order_details to manager_role;

grant insert, select on order_details to staff_role;

grant select on order_details to readonly_role;

