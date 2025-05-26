create table users
(
    user_id       serial
        primary key,
    first_name    varchar(100),
    last_name     varchar(100),
    email         varchar(255) not null
        unique,
    password_hash text         not null,
    reg_date      timestamp default CURRENT_TIMESTAMP
);

alter table users
    owner to postgres;

create unique index idx_users_email
    on users (email);

grant delete, insert, references, select, trigger, truncate, update on users to admin_role;

grant insert, select, update on users to manager_role;

grant select on users to readonly_role;

