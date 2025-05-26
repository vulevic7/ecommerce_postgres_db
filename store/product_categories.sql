create table product_categories
(
    product_id  integer not null
        references products
            on delete cascade,
    category_id integer not null
        references categories
            on delete cascade,
    primary key (product_id, category_id)
);

alter table product_categories
    owner to postgres;

create index idx_product_categories_category_id
    on product_categories (category_id);

grant delete, insert, references, select, trigger, truncate, update on product_categories to admin_role;

grant insert, select, update on product_categories to manager_role;

grant select on product_categories to readonly_role;

