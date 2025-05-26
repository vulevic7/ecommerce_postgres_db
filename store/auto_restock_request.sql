create function auto_restock_request() returns trigger
    language plpgsql
as
$$
BEGIN
    IF NEW.quantity < 10 THEN
        IF NOT EXISTS (
            SELECT 1 FROM warehouse.restock_requests
            WHERE warehouse_id = NEW.warehouse_id
            AND product_id = NEW.product_id
            AND status = 'pending'
        ) THEN
            INSERT INTO warehouse.restock_requests(

                warehouse_id,
                product_id,
                requested_quantity,
                status) VALUES (

                NEW.warehouse_id,
            NEW.product_id,
                                100,
                                'pending'

                                );
            END IF;
        END IF;
    RETURN NEW;
    END;


$$;

alter function auto_restock_request() owner to postgres;

grant execute on function auto_restock_request() to admin_role;

