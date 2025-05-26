create table audit_log
(
    entry_id       serial
        primary key,
    user_name      text not null,
    action         text not null,
    table_affected text not null,
    changed_data   jsonb,
    timestamp      timestamp default CURRENT_TIMESTAMP
);

alter table audit_log
    owner to postgres;

grant delete, insert, references, select, trigger, truncate, update on audit_log to admin_role;

