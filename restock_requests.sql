create table restock_requests
(
    request_id         serial
        primary key,
    warehouse_id       integer
        references warehouses
            on delete cascade,
    product_id         integer
        references store.products
            on delete cascade,
    requested_quantity integer not null
        constraint restock_requests_requested_quantity_check
            check (requested_quantity > 0),
    status             text    not null
        constraint restock_requests_status_check
            check (status = ANY (ARRAY ['pending'::text, 'approved'::text, 'rejected'::text, 'fulfilled'::text])),
    requested_at       timestamp default CURRENT_TIMESTAMP
);

alter table restock_requests
    owner to postgres;

grant delete, insert, references, select, trigger, truncate, update on restock_requests to admin_role;

grant insert, select on restock_requests to manager_role;

grant select on restock_requests to readonly_role;

