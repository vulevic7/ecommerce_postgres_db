create function log_product_changes() returns trigger
    language plpgsql
as
$$
DECLARE
    data JSONB;
BEGIN
    IF TG_OP = 'DELETE' THEN
        data := TO_JSONB(OLD);  -- capture deleted row
    ELSE
        data := TO_JSONB(NEW);  -- capture inserted or updated row
    END IF;

    INSERT INTO admin.audit_log (user_name, action, table_affected, changed_data)
    VALUES (
        CURRENT_USER,
        TG_OP,
        TG_TABLE_NAME,
        data
    );

    RETURN NEW;
END;
$$;

alter function log_product_changes() owner to postgres;

grant execute on function log_product_changes() to admin_role;

