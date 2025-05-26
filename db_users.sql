create table db_users
(
    username   text not null
        primary key,
    role       text not null
        constraint db_users_role_check
            check (role = ANY
                   (ARRAY ['admin_role'::text, 'manager_role'::text, 'staff_role'::text, 'readonly_role'::text])),
    created_at timestamp default CURRENT_TIMESTAMP
);

alter table db_users
    owner to postgres;

grant delete, insert, references, select, trigger, truncate, update on db_users to admin_role;

