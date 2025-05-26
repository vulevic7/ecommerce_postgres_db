create table warehouses
(
    warehouse_id serial
        primary key,
    name         text not null,
    location     text not null,
    capacity     integer
        constraint warehouses_capacity_check
            check (capacity > 0)
);

alter table warehouses
    owner to postgres;

grant delete, insert, references, select, trigger, truncate, update on warehouses to admin_role;

grant select on warehouses to manager_role;

grant select on warehouses to readonly_role;

