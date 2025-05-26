create table products
(
    product_id     serial
        primary key,
    name           varchar(255)   not null,
    description    text,
    price          numeric(10, 2) not null
        constraint check_price
            check (price >= (0)::numeric),
    stock_quantity integer default 0
        constraint check_stock
            check (stock_quantity >= 0)
);

alter table products
    owner to postgres;

create index idx_products_name
    on products (name);

create trigger trg_log_product_changes
    after insert or update or delete
    on products
    for each row
execute procedure admin.log_product_changes();

grant delete, insert, references, select, trigger, truncate, update on products to admin_role;

grant insert, select, update on products to manager_role;

grant select on products to staff_role;

grant select on products to readonly_role;

