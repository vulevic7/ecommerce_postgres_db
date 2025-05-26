create table categories
(
    category_id serial
        primary key,
    name        varchar(255) not null
        unique
);

alter table categories
    owner to postgres;

create index idx_categories_name
    on categories (name);

grant delete, insert, references, select, trigger, truncate, update on categories to admin_role;

grant insert, select, update on categories to manager_role;

grant select on categories to readonly_role;

