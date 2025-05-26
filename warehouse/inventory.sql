create table inventory
(
    warehouse_id integer not null
        references warehouses
            on delete cascade,
    product_id   integer not null
        references store.products
            on delete cascade,
    quantity     integer not null
        constraint inventory_quantity_check
            check (quantity >= 0),
    last_updated timestamp default CURRENT_TIMESTAMP,
    primary key (warehouse_id, product_id)
);

alter table inventory
    owner to postgres;

create trigger trg_auto_restock
    after insert or update
    on inventory
    for each row
execute procedure auto_restock_request();

grant delete, insert, references, select, trigger, truncate, update on inventory to admin_role;

grant insert, select, update on inventory to manager_role;

grant select on inventory to staff_role;

grant select on inventory to readonly_role;

