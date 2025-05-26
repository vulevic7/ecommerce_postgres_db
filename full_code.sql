--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS ecommerce;
--
-- Name: ecommerce; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE ecommerce WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Serbian (Latin)_Serbia.1252';


ALTER DATABASE ecommerce OWNER TO postgres;

\connect ecommerce

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: admin; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA admin;


ALTER SCHEMA admin OWNER TO postgres;

--
-- Name: store; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA store;


ALTER SCHEMA store OWNER TO postgres;

--
-- Name: warehouse; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA warehouse;


ALTER SCHEMA warehouse OWNER TO postgres;

--
-- Name: log_product_changes(); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.log_product_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION admin.log_product_changes() OWNER TO postgres;

--
-- Name: auto_restock_request(); Type: FUNCTION; Schema: warehouse; Owner: postgres
--

CREATE FUNCTION warehouse.auto_restock_request() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION warehouse.auto_restock_request() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log; Type: TABLE; Schema: admin; Owner: postgres
--

CREATE TABLE admin.audit_log (
    entry_id integer NOT NULL,
    user_name text NOT NULL,
    action text NOT NULL,
    table_affected text NOT NULL,
    changed_data jsonb,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE admin.audit_log OWNER TO postgres;

--
-- Name: audit_log_entry_id_seq; Type: SEQUENCE; Schema: admin; Owner: postgres
--

CREATE SEQUENCE admin.audit_log_entry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE admin.audit_log_entry_id_seq OWNER TO postgres;

--
-- Name: audit_log_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: postgres
--

ALTER SEQUENCE admin.audit_log_entry_id_seq OWNED BY admin.audit_log.entry_id;


--
-- Name: db_users; Type: TABLE; Schema: admin; Owner: postgres
--

CREATE TABLE admin.db_users (
    username text NOT NULL,
    role text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT db_users_role_check CHECK ((role = ANY (ARRAY['admin_role'::text, 'manager_role'::text, 'staff_role'::text, 'readonly_role'::text])))
);


ALTER TABLE admin.db_users OWNER TO postgres;

--
-- Name: addresses; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.addresses (
    address_id integer NOT NULL,
    user_id integer,
    address_line1 character varying(255),
    address_line2 character varying(255),
    city character varying(100),
    postal_code character varying(20),
    country character varying(100)
);


ALTER TABLE store.addresses OWNER TO postgres;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE; Schema: store; Owner: postgres
--

CREATE SEQUENCE store.addresses_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE store.addresses_address_id_seq OWNER TO postgres;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: postgres
--

ALTER SEQUENCE store.addresses_address_id_seq OWNED BY store.addresses.address_id;


--
-- Name: categories; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.categories (
    category_id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE store.categories OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: store; Owner: postgres
--

CREATE SEQUENCE store.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE store.categories_category_id_seq OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: postgres
--

ALTER SEQUENCE store.categories_category_id_seq OWNED BY store.categories.category_id;


--
-- Name: order_details; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.order_details (
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL
);


ALTER TABLE store.order_details OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.orders (
    order_id integer NOT NULL,
    user_id integer,
    order_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(50) DEFAULT 'pending'::character varying,
    total_amount numeric(10,2) NOT NULL
);


ALTER TABLE store.orders OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: store; Owner: postgres
--

CREATE SEQUENCE store.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE store.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: postgres
--

ALTER SEQUENCE store.orders_order_id_seq OWNED BY store.orders.order_id;


--
-- Name: payments; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.payments (
    payment_id integer NOT NULL,
    order_id integer,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    payment_method character varying(50),
    amount numeric(10,2) NOT NULL
);


ALTER TABLE store.payments OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: store; Owner: postgres
--

CREATE SEQUENCE store.payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE store.payments_payment_id_seq OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: postgres
--

ALTER SEQUENCE store.payments_payment_id_seq OWNED BY store.payments.payment_id;


--
-- Name: product_categories; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.product_categories (
    product_id integer NOT NULL,
    category_id integer NOT NULL
);


ALTER TABLE store.product_categories OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.products (
    product_id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    stock_quantity integer DEFAULT 0,
    CONSTRAINT check_price CHECK ((price >= (0)::numeric)),
    CONSTRAINT check_stock CHECK ((stock_quantity >= 0))
);


ALTER TABLE store.products OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: store; Owner: postgres
--

CREATE SEQUENCE store.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE store.products_product_id_seq OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: postgres
--

ALTER SEQUENCE store.products_product_id_seq OWNED BY store.products.product_id;


--
-- Name: users; Type: TABLE; Schema: store; Owner: postgres
--

CREATE TABLE store.users (
    user_id integer NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    email character varying(255) NOT NULL,
    password_hash text NOT NULL,
    reg_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE store.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: store; Owner: postgres
--

CREATE SEQUENCE store.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE store.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: postgres
--

ALTER SEQUENCE store.users_user_id_seq OWNED BY store.users.user_id;


--
-- Name: inventory; Type: TABLE; Schema: warehouse; Owner: postgres
--

CREATE TABLE warehouse.inventory (
    warehouse_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT inventory_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE warehouse.inventory OWNER TO postgres;

--
-- Name: restock_requests; Type: TABLE; Schema: warehouse; Owner: postgres
--

CREATE TABLE warehouse.restock_requests (
    request_id integer NOT NULL,
    warehouse_id integer,
    product_id integer,
    requested_quantity integer NOT NULL,
    status text NOT NULL,
    requested_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT restock_requests_requested_quantity_check CHECK ((requested_quantity > 0)),
    CONSTRAINT restock_requests_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'fulfilled'::text])))
);


ALTER TABLE warehouse.restock_requests OWNER TO postgres;

--
-- Name: restock_requests_request_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: postgres
--

CREATE SEQUENCE warehouse.restock_requests_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.restock_requests_request_id_seq OWNER TO postgres;

--
-- Name: restock_requests_request_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: postgres
--

ALTER SEQUENCE warehouse.restock_requests_request_id_seq OWNED BY warehouse.restock_requests.request_id;


--
-- Name: warehouses; Type: TABLE; Schema: warehouse; Owner: postgres
--

CREATE TABLE warehouse.warehouses (
    warehouse_id integer NOT NULL,
    name text NOT NULL,
    location text NOT NULL,
    capacity integer,
    CONSTRAINT warehouses_capacity_check CHECK ((capacity > 0))
);


ALTER TABLE warehouse.warehouses OWNER TO postgres;

--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE; Schema: warehouse; Owner: postgres
--

CREATE SEQUENCE warehouse.warehouses_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE warehouse.warehouses_warehouse_id_seq OWNER TO postgres;

--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: warehouse; Owner: postgres
--

ALTER SEQUENCE warehouse.warehouses_warehouse_id_seq OWNED BY warehouse.warehouses.warehouse_id;


--
-- Name: audit_log entry_id; Type: DEFAULT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.audit_log ALTER COLUMN entry_id SET DEFAULT nextval('admin.audit_log_entry_id_seq'::regclass);


--
-- Name: addresses address_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.addresses ALTER COLUMN address_id SET DEFAULT nextval('store.addresses_address_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.categories ALTER COLUMN category_id SET DEFAULT nextval('store.categories_category_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.orders ALTER COLUMN order_id SET DEFAULT nextval('store.orders_order_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.payments ALTER COLUMN payment_id SET DEFAULT nextval('store.payments_payment_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.products ALTER COLUMN product_id SET DEFAULT nextval('store.products_product_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.users ALTER COLUMN user_id SET DEFAULT nextval('store.users_user_id_seq'::regclass);


--
-- Name: restock_requests request_id; Type: DEFAULT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.restock_requests ALTER COLUMN request_id SET DEFAULT nextval('warehouse.restock_requests_request_id_seq'::regclass);


--
-- Name: warehouses warehouse_id; Type: DEFAULT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.warehouses ALTER COLUMN warehouse_id SET DEFAULT nextval('warehouse.warehouses_warehouse_id_seq'::regclass);


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: admin; Owner: postgres
--

INSERT INTO admin.audit_log VALUES (1, 'postgres', 'INSERT', 'products', '{"name": "Pametni telefon X200", "price": 48999.99, "product_id": 1, "description": "Moderan pametni telefon sa 128GB memorije i trostrukom kamerom.", "stock_quantity": 35}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (2, 'postgres', 'INSERT', 'products', '{"name": "LED TV 55\"", "price": 69999.00, "product_id": 2, "description": "Ultra HD televizor sa pametnim funkcijama i HDMI ulazima.", "stock_quantity": 12}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (3, 'postgres', 'INSERT', 'products', '{"name": "Bluetooth zvučnik", "price": 4999.00, "product_id": 3, "description": "Bežični zvučnik otporan na vodu sa do 10 sati baterije.", "stock_quantity": 50}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (4, 'postgres', 'INSERT', 'products', '{"name": "Laptop ProBook 450", "price": 84999.99, "product_id": 4, "description": "Pouzdan laptop sa Intel i5 procesorom i 8GB RAM-a.", "stock_quantity": 15}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (5, 'postgres', 'INSERT', 'products', '{"name": "Bežične slušalice", "price": 11499.00, "product_id": 5, "description": "Slušalice sa aktivnim poništavanjem buke.", "stock_quantity": 42}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (6, 'postgres', 'INSERT', 'products', '{"name": "Mikrotalasna rerna", "price": 9499.00, "product_id": 6, "description": "800W mikrotalasna sa 5 nivoa snage i tajmerom.", "stock_quantity": 20}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (7, 'postgres', 'INSERT', 'products', '{"name": "Usisivač 2000W", "price": 12999.00, "product_id": 7, "description": "Moćan usisivač sa HEPA filterom i više dodataka.", "stock_quantity": 18}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (8, 'postgres', 'INSERT', 'products', '{"name": "Toster XL", "price": 3999.00, "product_id": 8, "description": "Električni toster sa opcijom za 4 kriške.", "stock_quantity": 40}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (9, 'postgres', 'INSERT', 'products', '{"name": "Kuvalo za vodu", "price": 2899.00, "product_id": 9, "description": "Kuvanje vode za manje od 2 minuta.", "stock_quantity": 33}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (10, 'postgres', 'INSERT', 'products', '{"name": "Mašina za pranje veša", "price": 44999.00, "product_id": 10, "description": "Kapacitet 8kg, 1400 obrtaja, energetska klasa A++.", "stock_quantity": 8}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (11, 'postgres', 'INSERT', 'products', '{"name": "Muška majica", "price": 1299.00, "product_id": 11, "description": "Pamučna majica kratkih rukava, razne boje.", "stock_quantity": 70}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (12, 'postgres', 'INSERT', 'products', '{"name": "Ženska bluza", "price": 2499.00, "product_id": 12, "description": "Elegantna bluza od viskoze, dostupna u više veličina.", "stock_quantity": 50}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (13, 'postgres', 'INSERT', 'products', '{"name": "Trenerka", "price": 3999.00, "product_id": 13, "description": "Sportska trenerka od pamuka sa rajsferšlusom.", "stock_quantity": 25}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (14, 'postgres', 'INSERT', 'products', '{"name": "Zimska jakna", "price": 8499.00, "product_id": 14, "description": "Vodootporna jakna sa kapuljačom i termo postavom.", "stock_quantity": 22}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (15, 'postgres', 'INSERT', 'products', '{"name": "Letnja haljina", "price": 3499.00, "product_id": 15, "description": "Lagana haljina sa cvetnim dezenom.", "stock_quantity": 30}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (16, 'postgres', 'INSERT', 'products', '{"name": "Muške patike", "price": 5999.00, "product_id": 16, "description": "Udobne sportske patike za svakodnevno nošenje.", "stock_quantity": 40}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (17, 'postgres', 'INSERT', 'products', '{"name": "Ženske sandale", "price": 4499.00, "product_id": 17, "description": "Kožne sandale sa anatomski oblikovanom tabanicom.", "stock_quantity": 35}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (18, 'postgres', 'INSERT', 'products', '{"name": "Dečije čizme", "price": 3799.00, "product_id": 18, "description": "Vodootporne zimske čizme za decu.", "stock_quantity": 28}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (19, 'postgres', 'INSERT', 'products', '{"name": "Kućne papuče", "price": 1599.00, "product_id": 19, "description": "Mekane papuče sa gumenim đonom.", "stock_quantity": 50}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (20, 'postgres', 'INSERT', 'products', '{"name": "Sportske cipele", "price": 4999.00, "product_id": 20, "description": "Obuća za trčanje i rekreativne aktivnosti.", "stock_quantity": 32}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (21, 'postgres', 'INSERT', 'products', '{"name": "Blok A5", "price": 199.00, "product_id": 21, "description": "Blok sa 80 listova, linije.", "stock_quantity": 120}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (22, 'postgres', 'INSERT', 'products', '{"name": "Hemijska olovka", "price": 249.00, "product_id": 22, "description": "Pakovanje od 5 hemijskih olovaka, plava boja.", "stock_quantity": 200}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (23, 'postgres', 'INSERT', 'products', '{"name": "Flomasteri", "price": 399.00, "product_id": 23, "description": "12 boja u kartonskoj kutiji.", "stock_quantity": 80}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (24, 'postgres', 'INSERT', 'products', '{"name": "Sveska A4", "price": 129.00, "product_id": 24, "description": "Matematika sveska sa kvadratićima.", "stock_quantity": 100}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (25, 'postgres', 'INSERT', 'products', '{"name": "Lepljivi papirići", "price": 299.00, "product_id": 25, "description": "Set od 5 boja, idealno za obeležavanje.", "stock_quantity": 90}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (26, 'postgres', 'INSERT', 'products', '{"name": "Roman \"Na Drini ćuprija\"", "price": 899.00, "product_id": 26, "description": "Ivo Andrić – dobitnik Nobelove nagrade.", "stock_quantity": 25}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (27, 'postgres', 'INSERT', 'products', '{"name": "Enciklopedija nauke", "price": 1599.00, "product_id": 27, "description": "Ilustrovana knjiga za decu i odrasle.", "stock_quantity": 18}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (28, 'postgres', 'INSERT', 'products', '{"name": "Gramatika srpskog jezika", "price": 799.00, "product_id": 28, "description": "Obavezna lektira za osnovce.", "stock_quantity": 33}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (29, 'postgres', 'INSERT', 'products', '{"name": "Kuvanje sa Miom", "price": 1199.00, "product_id": 29, "description": "Knjiga sa tradicionalnim receptima.", "stock_quantity": 14}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (30, 'postgres', 'INSERT', 'products', '{"name": "Psihologija uspeha", "price": 999.00, "product_id": 30, "description": "Popularna psihološka literatura.", "stock_quantity": 22}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (31, 'postgres', 'INSERT', 'products', '{"name": "Lego set policijska stanica", "price": 3499.00, "product_id": 31, "description": "Komplet za sklapanje sa više od 300 delova.", "stock_quantity": 15}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (32, 'postgres', 'INSERT', 'products', '{"name": "Lutka sa haljinom", "price": 2199.00, "product_id": 32, "description": "Moderna lutka sa dodatnom garderobom.", "stock_quantity": 40}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (33, 'postgres', 'INSERT', 'products', '{"name": "Autić na daljinski", "price": 2999.00, "product_id": 33, "description": "Brzi autić sa USB punjenjem.", "stock_quantity": 20}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (34, 'postgres', 'INSERT', 'products', '{"name": "Plišana igračka – meda", "price": 1499.00, "product_id": 34, "description": "Mekani plišani meda od 40 cm.", "stock_quantity": 45}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (35, 'postgres', 'INSERT', 'products', '{"name": "Puzzle 1000 delova", "price": 999.00, "product_id": 35, "description": "Slagalica sa motivom Beograda.", "stock_quantity": 30}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (36, 'postgres', 'INSERT', 'products', '{"name": "Baštenska stolica", "price": 1799.00, "product_id": 36, "description": "Plastična stolica otporna na vlagu.", "stock_quantity": 27}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (37, 'postgres', 'INSERT', 'products', '{"name": "Crevo za zalivanje 15m", "price": 2299.00, "product_id": 37, "description": "Fleksibilno crevo sa nastavcima.", "stock_quantity": 20}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (38, 'postgres', 'INSERT', 'products', '{"name": "Makaze za grane", "price": 1699.00, "product_id": 38, "description": "Oštre makaze sa ergonomskom drškom.", "stock_quantity": 19}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (39, 'postgres', 'INSERT', 'products', '{"name": "Set za sadnju", "price": 1499.00, "product_id": 39, "description": "3 saksije, lopatica i rukavice.", "stock_quantity": 35}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (40, 'postgres', 'INSERT', 'products', '{"name": "Baštenska lampa solarna", "price": 899.00, "product_id": 40, "description": "LED lampa sa senzorom i solarnim punjenjem.", "stock_quantity": 50}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (41, 'postgres', 'INSERT', 'products', '{"name": "Mlevena kafa 200g", "price": 349.00, "product_id": 41, "description": "Tradicionalna kafa bogatog ukusa.", "stock_quantity": 60}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (42, 'postgres', 'INSERT', 'products', '{"name": "Sok od jabuke 1L", "price": 179.00, "product_id": 42, "description": "100% prirodni sok bez dodatog šećera.", "stock_quantity": 80}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (43, 'postgres', 'INSERT', 'products', '{"name": "Čokolada mlečna 100g", "price": 229.00, "product_id": 43, "description": "Švajcarska čokolada sa lešnicima.", "stock_quantity": 90}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (44, 'postgres', 'INSERT', 'products', '{"name": "Tjestenina penne 500g", "price": 159.00, "product_id": 44, "description": "Italijanska testenina od durum pšenice.", "stock_quantity": 70}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (45, 'postgres', 'INSERT', 'products', '{"name": "Maslinovo ulje 750ml", "price": 799.00, "product_id": 45, "description": "Ekstra devičansko ulje iz Grčke.", "stock_quantity": 40}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (46, 'postgres', 'INSERT', 'products', '{"name": "Šampon za kosu 400ml", "price": 499.00, "product_id": 46, "description": "Protiv opadanja sa prirodnim sastojcima.", "stock_quantity": 55}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (47, 'postgres', 'INSERT', 'products', '{"name": "Pasta za zube 75ml", "price": 249.00, "product_id": 47, "description": "Osvežava dah i štiti desni.", "stock_quantity": 100}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (48, 'postgres', 'INSERT', 'products', '{"name": "Gel za tuširanje", "price": 399.00, "product_id": 48, "description": "Opuštajući miris lavande.", "stock_quantity": 70}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (49, 'postgres', 'INSERT', 'products', '{"name": "Krema za lice 50ml", "price": 899.00, "product_id": 49, "description": "Dnevna krema sa zaštitnim faktorom.", "stock_quantity": 35}', '2025-05-16 09:32:36.394385');
INSERT INTO admin.audit_log VALUES (50, 'postgres', 'INSERT', 'products', '{"name": "Brijač set 3+1", "price": 349.00, "product_id": 50, "description": "Pakovanje sa dodatnim rezervama.", "stock_quantity": 80}', '2025-05-16 09:32:36.394385');


--
-- Data for Name: db_users; Type: TABLE DATA; Schema: admin; Owner: postgres
--

INSERT INTO admin.db_users VALUES ('marko.petrovic', 'admin_role', '2025-05-20 15:28:14.406477');
INSERT INTO admin.db_users VALUES ('jelena.ivanovic', 'manager_role', '2025-05-20 15:28:14.406477');
INSERT INTO admin.db_users VALUES ('nikola.jovic', 'staff_role', '2025-05-20 15:28:14.406477');
INSERT INTO admin.db_users VALUES ('ana.kostic', 'readonly_role', '2025-05-20 15:28:14.406477');


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.addresses VALUES (1, 1, 'Kralja Petra 12', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (2, 2, 'Bulevar Kralja Aleksandra 73', 'Stan 5', 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (3, 3, 'Njegoševa 45', NULL, 'Novi Sad', '21000', 'Srbija');
INSERT INTO store.addresses VALUES (4, 4, 'Cara Dušana 9', NULL, 'Niš', '18000', 'Srbija');
INSERT INTO store.addresses VALUES (5, 5, 'Kneza Miloša 21', 'Sprat 2', 'Kragujevac', '34000', 'Srbija');
INSERT INTO store.addresses VALUES (6, 6, 'Zmaj Jovina 5', NULL, 'Subotica', '24000', 'Srbija');
INSERT INTO store.addresses VALUES (7, 7, 'Obilićeva 10', NULL, 'Čačak', '32000', 'Srbija');
INSERT INTO store.addresses VALUES (8, 8, 'Branka Radičevića 33', NULL, 'Zrenjanin', '23000', 'Srbija');
INSERT INTO store.addresses VALUES (9, 9, 'Vuka Karadžića 7', NULL, 'Pančevo', '26000', 'Srbija');
INSERT INTO store.addresses VALUES (10, 10, 'Kraljevića Marka 4', NULL, 'Smederevo', '11300', 'Srbija');
INSERT INTO store.addresses VALUES (11, 11, 'Takovska 88', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (12, 12, 'Dušanova 15', 'Stan 12', 'Niš', '18000', 'Srbija');
INSERT INTO store.addresses VALUES (13, 13, 'Laze Kostića 2', NULL, 'Kruševac', '37000', 'Srbija');
INSERT INTO store.addresses VALUES (14, 14, 'Svetosavska 19', NULL, 'Valjevo', '14000', 'Srbija');
INSERT INTO store.addresses VALUES (15, 15, 'Stevana Sremca 28', NULL, 'Leskovac', '16000', 'Srbija');
INSERT INTO store.addresses VALUES (16, 16, 'Balkanska 14', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (17, 17, 'Kneginje Zorke 11', NULL, 'Užice', '31000', 'Srbija');
INSERT INTO store.addresses VALUES (18, 18, 'Jovana Dučića 6', NULL, 'Šabac', '15000', 'Srbija');
INSERT INTO store.addresses VALUES (19, 19, 'Narodnog fronta 55', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (20, 20, 'Ivana Milutinovića 3', NULL, 'Jagodina', '35000', 'Srbija');
INSERT INTO store.addresses VALUES (21, 21, 'Nikole Tesle 77', NULL, 'Zaječar', '19000', 'Srbija');
INSERT INTO store.addresses VALUES (22, 22, 'Miloša Obilića 13', NULL, 'Požarevac', '12000', 'Srbija');
INSERT INTO store.addresses VALUES (23, 23, 'Gundulićeva 22', NULL, 'Loznica', '15300', 'Srbija');
INSERT INTO store.addresses VALUES (24, 24, 'Dositejeva 17', NULL, 'Pirot', '18300', 'Srbija');
INSERT INTO store.addresses VALUES (25, 25, 'Save Kovačevića 9', NULL, 'Bečej', '21220', 'Srbija');
INSERT INTO store.addresses VALUES (26, 26, 'Karađorđeva 42', NULL, 'Senta', '24400', 'Srbija');
INSERT INTO store.addresses VALUES (27, 27, 'Jevrejska 31', NULL, 'Novi Sad', '21000', 'Srbija');
INSERT INTO store.addresses VALUES (28, 28, 'Prvomajska 58', NULL, 'Apatin', '25260', 'Srbija');
INSERT INTO store.addresses VALUES (29, 29, 'Rade Končara 14', NULL, 'Bačka Palanka', '21400', 'Srbija');
INSERT INTO store.addresses VALUES (30, 30, 'Vojvode Mišića 23', NULL, 'Kikinda', '23300', 'Srbija');
INSERT INTO store.addresses VALUES (31, 31, 'Miloša Crnjanskog 18', NULL, 'Sombor', '25000', 'Srbija');
INSERT INTO store.addresses VALUES (32, 32, 'Trg republike 1', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (33, 33, 'Stražilovska 7', NULL, 'Sremska Mitrovica', '22000', 'Srbija');
INSERT INTO store.addresses VALUES (34, 34, 'Petra Drapšina 10', NULL, 'Vršac', '26300', 'Srbija');
INSERT INTO store.addresses VALUES (35, 35, 'Miše Dimitrijevića 4', NULL, 'Prokuplje', '18400', 'Srbija');
INSERT INTO store.addresses VALUES (36, 36, 'Bulevar oslobođenja 120', NULL, 'Novi Sad', '21000', 'Srbija');
INSERT INTO store.addresses VALUES (37, 37, 'Petefi Šandora 8', NULL, 'Kanjiža', '24420', 'Srbija');
INSERT INTO store.addresses VALUES (38, 38, 'Trg oslobođenja 3', NULL, 'Aleksinac', '18220', 'Srbija');
INSERT INTO store.addresses VALUES (39, 39, 'Njegoševa 88', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (40, 40, 'Masarikova 29', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (41, 41, 'Zeleni venac 2', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (42, 42, 'Sime Šolaje 5', NULL, 'Vrbas', '21460', 'Srbija');
INSERT INTO store.addresses VALUES (43, 43, 'Bratstva Jedinstva 9', NULL, 'Vranje', '17500', 'Srbija');
INSERT INTO store.addresses VALUES (44, 44, 'Milutina Milankovića 38', NULL, 'Beograd', '11070', 'Srbija');
INSERT INTO store.addresses VALUES (45, 45, 'Zmaj Jovina 1', NULL, 'Sremski Karlovci', '21205', 'Srbija');
INSERT INTO store.addresses VALUES (46, 46, 'Pavla Simića 6', NULL, 'Novi Sad', '21000', 'Srbija');
INSERT INTO store.addresses VALUES (47, 47, 'Majke Jevrosime 19', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (48, 48, 'Savska 24', NULL, 'Beograd', '11000', 'Srbija');
INSERT INTO store.addresses VALUES (49, 49, 'Takovska 8', NULL, 'Kraljevo', '36000', 'Srbija');
INSERT INTO store.addresses VALUES (50, 50, 'Koste Abraševića 13', NULL, 'Paraćin', '35250', 'Srbija');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.categories VALUES (1, 'Elektronika');
INSERT INTO store.categories VALUES (2, 'Kućni aparati');
INSERT INTO store.categories VALUES (3, 'Odeća');
INSERT INTO store.categories VALUES (4, 'Obuća');
INSERT INTO store.categories VALUES (5, 'Kancelarijski materijal');
INSERT INTO store.categories VALUES (6, 'Knjige');
INSERT INTO store.categories VALUES (7, 'Igračke');
INSERT INTO store.categories VALUES (8, 'Baštenska oprema');
INSERT INTO store.categories VALUES (9, 'Hrana i piće');
INSERT INTO store.categories VALUES (10, 'Kozmetika');


--
-- Data for Name: order_details; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.order_details VALUES (1, 3, 2, 2500.00);
INSERT INTO store.order_details VALUES (1, 7, 1, 1100.00);
INSERT INTO store.order_details VALUES (2, 2, 3, 1500.00);
INSERT INTO store.order_details VALUES (2, 5, 1, 3200.00);
INSERT INTO store.order_details VALUES (3, 4, 1, 1400.00);
INSERT INTO store.order_details VALUES (4, 8, 5, 900.00);
INSERT INTO store.order_details VALUES (5, 1, 2, 2400.00);
INSERT INTO store.order_details VALUES (5, 6, 1, 3700.00);
INSERT INTO store.order_details VALUES (6, 7, 4, 1100.00);
INSERT INTO store.order_details VALUES (7, 3, 2, 2500.00);
INSERT INTO store.order_details VALUES (8, 5, 3, 3200.00);
INSERT INTO store.order_details VALUES (9, 4, 2, 1400.00);
INSERT INTO store.order_details VALUES (10, 2, 1, 1500.00);
INSERT INTO store.order_details VALUES (10, 6, 2, 3700.00);
INSERT INTO store.order_details VALUES (11, 1, 3, 2400.00);
INSERT INTO store.order_details VALUES (12, 8, 1, 900.00);
INSERT INTO store.order_details VALUES (13, 7, 2, 1100.00);
INSERT INTO store.order_details VALUES (14, 3, 1, 2500.00);
INSERT INTO store.order_details VALUES (15, 5, 1, 3200.00);
INSERT INTO store.order_details VALUES (16, 4, 4, 1400.00);
INSERT INTO store.order_details VALUES (17, 6, 2, 3700.00);
INSERT INTO store.order_details VALUES (18, 1, 3, 2400.00);
INSERT INTO store.order_details VALUES (19, 7, 2, 1100.00);
INSERT INTO store.order_details VALUES (20, 2, 5, 1500.00);
INSERT INTO store.order_details VALUES (21, 3, 1, 2500.00);
INSERT INTO store.order_details VALUES (22, 5, 4, 3200.00);
INSERT INTO store.order_details VALUES (23, 8, 2, 900.00);
INSERT INTO store.order_details VALUES (24, 4, 3, 1400.00);
INSERT INTO store.order_details VALUES (25, 6, 1, 3700.00);
INSERT INTO store.order_details VALUES (26, 1, 2, 2400.00);
INSERT INTO store.order_details VALUES (27, 7, 5, 1100.00);
INSERT INTO store.order_details VALUES (28, 3, 3, 2500.00);
INSERT INTO store.order_details VALUES (29, 2, 1, 1500.00);
INSERT INTO store.order_details VALUES (30, 5, 2, 3200.00);
INSERT INTO store.order_details VALUES (31, 4, 4, 1400.00);
INSERT INTO store.order_details VALUES (32, 6, 3, 3700.00);
INSERT INTO store.order_details VALUES (33, 1, 1, 2400.00);
INSERT INTO store.order_details VALUES (34, 7, 2, 1100.00);
INSERT INTO store.order_details VALUES (35, 3, 1, 2500.00);
INSERT INTO store.order_details VALUES (36, 5, 3, 3200.00);
INSERT INTO store.order_details VALUES (37, 8, 2, 900.00);
INSERT INTO store.order_details VALUES (38, 4, 1, 1400.00);
INSERT INTO store.order_details VALUES (39, 6, 4, 3700.00);
INSERT INTO store.order_details VALUES (40, 1, 3, 2400.00);
INSERT INTO store.order_details VALUES (41, 7, 1, 1100.00);
INSERT INTO store.order_details VALUES (42, 3, 2, 2500.00);
INSERT INTO store.order_details VALUES (43, 5, 3, 3200.00);
INSERT INTO store.order_details VALUES (44, 4, 1, 1400.00);
INSERT INTO store.order_details VALUES (45, 6, 2, 3700.00);
INSERT INTO store.order_details VALUES (46, 1, 1, 2400.00);
INSERT INTO store.order_details VALUES (47, 7, 3, 1100.00);
INSERT INTO store.order_details VALUES (48, 3, 4, 2500.00);
INSERT INTO store.order_details VALUES (49, 5, 1, 3200.00);
INSERT INTO store.order_details VALUES (50, 2, 2, 1500.00);


--
-- Data for Name: orders; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.orders VALUES (1, 7, '2024-02-14 00:00:00', 'Na čekanju', 11500.75);
INSERT INTO store.orders VALUES (2, 12, '2024-07-01 00:00:00', 'Dostavljeno', 22300.50);
INSERT INTO store.orders VALUES (3, 22, '2024-03-21 00:00:00', 'Otkazano', 14700.00);
INSERT INTO store.orders VALUES (4, 5, '2024-08-08 00:00:00', 'Obrađuje se', 7800.90);
INSERT INTO store.orders VALUES (5, 41, '2024-01-12 00:00:00', 'Poslato', 19990.99);
INSERT INTO store.orders VALUES (6, 30, '2024-10-19 00:00:00', 'Dostavljeno', 8500.00);
INSERT INTO store.orders VALUES (7, 19, '2024-06-15 00:00:00', 'Na čekanju', 5600.20);
INSERT INTO store.orders VALUES (8, 9, '2024-05-05 00:00:00', 'Poslato', 12990.45);
INSERT INTO store.orders VALUES (9, 48, '2024-04-03 00:00:00', 'Obrađuje se', 17200.00);
INSERT INTO store.orders VALUES (10, 33, '2024-09-10 00:00:00', 'Dostavljeno', 20250.70);
INSERT INTO store.orders VALUES (11, 24, '2024-02-28 00:00:00', 'Na čekanju', 13450.25);
INSERT INTO store.orders VALUES (12, 3, '2024-07-22 00:00:00', 'Poslato', 11900.60);
INSERT INTO store.orders VALUES (13, 10, '2024-08-30 00:00:00', 'Otkazano', 7400.00);
INSERT INTO store.orders VALUES (14, 18, '2024-11-05 00:00:00', 'Dostavljeno', 26300.40);
INSERT INTO store.orders VALUES (15, 29, '2024-01-17 00:00:00', 'Obrađuje se', 9800.15);
INSERT INTO store.orders VALUES (16, 6, '2024-04-25 00:00:00', 'Poslato', 14500.30);
INSERT INTO store.orders VALUES (17, 43, '2024-03-12 00:00:00', 'Na čekanju', 6300.00);
INSERT INTO store.orders VALUES (18, 21, '2024-09-01 00:00:00', 'Dostavljeno', 18700.55);
INSERT INTO store.orders VALUES (19, 36, '2024-10-08 00:00:00', 'Obrađuje se', 13420.85);
INSERT INTO store.orders VALUES (20, 47, '2024-12-02 00:00:00', 'Poslato', 9000.10);
INSERT INTO store.orders VALUES (21, 11, '2024-02-05 00:00:00', 'Na čekanju', 11000.99);
INSERT INTO store.orders VALUES (22, 25, '2024-06-20 00:00:00', 'Dostavljeno', 15300.00);
INSERT INTO store.orders VALUES (23, 16, '2024-07-29 00:00:00', 'Obrađuje se', 6700.35);
INSERT INTO store.orders VALUES (24, 39, '2024-08-13 00:00:00', 'Poslato', 14150.45);
INSERT INTO store.orders VALUES (25, 14, '2024-01-23 00:00:00', 'Otkazano', 5800.00);
INSERT INTO store.orders VALUES (26, 4, '2024-05-10 00:00:00', 'Dostavljeno', 20500.00);
INSERT INTO store.orders VALUES (27, 38, '2024-03-18 00:00:00', 'Na čekanju', 7200.25);
INSERT INTO store.orders VALUES (28, 27, '2024-10-30 00:00:00', 'Poslato', 19800.60);
INSERT INTO store.orders VALUES (29, 1, '2024-11-20 00:00:00', 'Obrađuje se', 9900.00);
INSERT INTO store.orders VALUES (30, 34, '2024-12-05 00:00:00', 'Dostavljeno', 17500.75);
INSERT INTO store.orders VALUES (31, 8, '2024-02-25 00:00:00', 'Na čekanju', 6600.90);
INSERT INTO store.orders VALUES (32, 23, '2024-06-28 00:00:00', 'Poslato', 16000.00);
INSERT INTO store.orders VALUES (33, 44, '2024-07-11 00:00:00', 'Obrađuje se', 8500.50);
INSERT INTO store.orders VALUES (34, 15, '2024-09-17 00:00:00', 'Dostavljeno', 14200.40);
INSERT INTO store.orders VALUES (35, 20, '2024-04-06 00:00:00', 'Otkazano', 7400.00);
INSERT INTO store.orders VALUES (36, 26, '2024-08-22 00:00:00', 'Poslato', 11300.30);
INSERT INTO store.orders VALUES (37, 31, '2024-03-07 00:00:00', 'Na čekanju', 9200.00);
INSERT INTO store.orders VALUES (38, 35, '2024-05-15 00:00:00', 'Dostavljeno', 18100.85);
INSERT INTO store.orders VALUES (39, 13, '2024-10-25 00:00:00', 'Obrađuje se', 13200.90);
INSERT INTO store.orders VALUES (40, 37, '2024-11-12 00:00:00', 'Poslato', 10700.00);
INSERT INTO store.orders VALUES (41, 28, '2024-01-28 00:00:00', 'Na čekanju', 6900.45);
INSERT INTO store.orders VALUES (42, 42, '2024-09-09 00:00:00', 'Dostavljeno', 16500.00);
INSERT INTO store.orders VALUES (43, 46, '2024-07-23 00:00:00', 'Poslato', 19500.75);
INSERT INTO store.orders VALUES (44, 32, '2024-06-04 00:00:00', 'Obrađuje se', 12300.10);
INSERT INTO store.orders VALUES (45, 45, '2024-02-17 00:00:00', 'Na čekanju', 8300.00);
INSERT INTO store.orders VALUES (46, 40, '2024-08-27 00:00:00', 'Dostavljeno', 17700.50);
INSERT INTO store.orders VALUES (47, 49, '2024-05-18 00:00:00', 'Poslato', 15500.25);
INSERT INTO store.orders VALUES (48, 50, '2024-04-29 00:00:00', 'Obrađuje se', 9900.00);
INSERT INTO store.orders VALUES (49, 2, '2024-03-03 00:00:00', 'Dostavljeno', 11000.85);
INSERT INTO store.orders VALUES (50, 17, '2024-12-15 00:00:00', 'Poslato', 21000.40);


--
-- Data for Name: payments; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.payments VALUES (1, 1, '2025-04-01 00:00:00', 'kartica', 6100.00);
INSERT INTO store.payments VALUES (2, 2, '2025-04-02 00:00:00', 'gotovina', 7700.00);
INSERT INTO store.payments VALUES (3, 3, '2025-04-03 00:00:00', 'kartica', 1400.00);
INSERT INTO store.payments VALUES (4, 4, '2025-04-04 00:00:00', 'kartica', 4500.00);
INSERT INTO store.payments VALUES (5, 5, '2025-04-05 00:00:00', 'gotovina', 6100.00);
INSERT INTO store.payments VALUES (6, 6, '2025-04-06 00:00:00', 'kartica', 4400.00);
INSERT INTO store.payments VALUES (7, 7, '2025-04-07 00:00:00', 'kartica', 5000.00);
INSERT INTO store.payments VALUES (8, 8, '2025-04-08 00:00:00', 'gotovina', 9600.00);
INSERT INTO store.payments VALUES (9, 9, '2025-04-09 00:00:00', 'kartica', 2800.00);
INSERT INTO store.payments VALUES (10, 10, '2025-04-10 00:00:00', 'kartica', 6200.00);
INSERT INTO store.payments VALUES (11, 11, '2025-04-11 00:00:00', 'gotovina', 7200.00);
INSERT INTO store.payments VALUES (12, 12, '2025-04-12 00:00:00', 'kartica', 900.00);
INSERT INTO store.payments VALUES (13, 13, '2025-04-13 00:00:00', 'gotovina', 2200.00);
INSERT INTO store.payments VALUES (14, 14, '2025-04-14 00:00:00', 'kartica', 2500.00);
INSERT INTO store.payments VALUES (15, 15, '2025-04-15 00:00:00', 'kartica', 3200.00);
INSERT INTO store.payments VALUES (16, 16, '2025-04-16 00:00:00', 'gotovina', 5600.00);
INSERT INTO store.payments VALUES (17, 17, '2025-04-17 00:00:00', 'kartica', 7400.00);
INSERT INTO store.payments VALUES (18, 18, '2025-04-18 00:00:00', 'kartica', 7200.00);
INSERT INTO store.payments VALUES (19, 19, '2025-04-19 00:00:00', 'gotovina', 2200.00);
INSERT INTO store.payments VALUES (20, 20, '2025-04-20 00:00:00', 'kartica', 7500.00);
INSERT INTO store.payments VALUES (21, 21, '2025-04-21 00:00:00', 'kartica', 2500.00);
INSERT INTO store.payments VALUES (22, 22, '2025-04-22 00:00:00', 'gotovina', 12800.00);
INSERT INTO store.payments VALUES (23, 23, '2025-04-23 00:00:00', 'kartica', 1800.00);
INSERT INTO store.payments VALUES (24, 24, '2025-04-24 00:00:00', 'kartica', 4200.00);
INSERT INTO store.payments VALUES (25, 25, '2025-04-25 00:00:00', 'gotovina', 3700.00);
INSERT INTO store.payments VALUES (26, 26, '2025-04-26 00:00:00', 'kartica', 4800.00);
INSERT INTO store.payments VALUES (27, 27, '2025-04-27 00:00:00', 'gotovina', 5500.00);
INSERT INTO store.payments VALUES (28, 28, '2025-04-28 00:00:00', 'kartica', 7500.00);
INSERT INTO store.payments VALUES (29, 29, '2025-04-29 00:00:00', 'kartica', 1500.00);
INSERT INTO store.payments VALUES (30, 30, '2025-04-30 00:00:00', 'gotovina', 6400.00);
INSERT INTO store.payments VALUES (31, 31, '2025-05-01 00:00:00', 'kartica', 5600.00);
INSERT INTO store.payments VALUES (32, 32, '2025-05-02 00:00:00', 'gotovina', 11100.00);
INSERT INTO store.payments VALUES (33, 33, '2025-05-03 00:00:00', 'kartica', 2400.00);
INSERT INTO store.payments VALUES (34, 34, '2025-05-04 00:00:00', 'kartica', 2200.00);
INSERT INTO store.payments VALUES (35, 35, '2025-05-05 00:00:00', 'gotovina', 2500.00);
INSERT INTO store.payments VALUES (36, 36, '2025-05-06 00:00:00', 'kartica', 9600.00);
INSERT INTO store.payments VALUES (37, 37, '2025-05-07 00:00:00', 'gotovina', 1800.00);
INSERT INTO store.payments VALUES (38, 38, '2025-05-08 00:00:00', 'kartica', 1400.00);
INSERT INTO store.payments VALUES (39, 39, '2025-05-09 00:00:00', 'kartica', 14800.00);
INSERT INTO store.payments VALUES (40, 40, '2025-05-10 00:00:00', 'gotovina', 7200.00);
INSERT INTO store.payments VALUES (41, 41, '2025-05-11 00:00:00', 'kartica', 1100.00);
INSERT INTO store.payments VALUES (42, 42, '2025-05-12 00:00:00', 'kartica', 5000.00);
INSERT INTO store.payments VALUES (43, 43, '2025-05-13 00:00:00', 'gotovina', 9600.00);
INSERT INTO store.payments VALUES (44, 44, '2025-05-14 00:00:00', 'kartica', 1400.00);
INSERT INTO store.payments VALUES (45, 45, '2025-05-15 00:00:00', 'kartica', 7400.00);
INSERT INTO store.payments VALUES (46, 46, '2025-05-16 00:00:00', 'gotovina', 2400.00);
INSERT INTO store.payments VALUES (47, 47, '2025-05-17 00:00:00', 'kartica', 3300.00);
INSERT INTO store.payments VALUES (48, 48, '2025-05-18 00:00:00', 'kartica', 10000.00);
INSERT INTO store.payments VALUES (49, 49, '2025-05-19 00:00:00', 'gotovina', 3200.00);
INSERT INTO store.payments VALUES (50, 50, '2025-05-20 00:00:00', 'kartica', 3000.00);


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.product_categories VALUES (1, 1);
INSERT INTO store.product_categories VALUES (2, 1);
INSERT INTO store.product_categories VALUES (3, 1);
INSERT INTO store.product_categories VALUES (4, 1);
INSERT INTO store.product_categories VALUES (5, 1);
INSERT INTO store.product_categories VALUES (6, 2);
INSERT INTO store.product_categories VALUES (7, 2);
INSERT INTO store.product_categories VALUES (8, 2);
INSERT INTO store.product_categories VALUES (9, 2);
INSERT INTO store.product_categories VALUES (10, 2);
INSERT INTO store.product_categories VALUES (11, 3);
INSERT INTO store.product_categories VALUES (12, 3);
INSERT INTO store.product_categories VALUES (13, 3);
INSERT INTO store.product_categories VALUES (14, 3);
INSERT INTO store.product_categories VALUES (15, 3);
INSERT INTO store.product_categories VALUES (16, 4);
INSERT INTO store.product_categories VALUES (17, 4);
INSERT INTO store.product_categories VALUES (18, 4);
INSERT INTO store.product_categories VALUES (19, 4);
INSERT INTO store.product_categories VALUES (20, 4);
INSERT INTO store.product_categories VALUES (21, 5);
INSERT INTO store.product_categories VALUES (22, 5);
INSERT INTO store.product_categories VALUES (23, 5);
INSERT INTO store.product_categories VALUES (24, 5);
INSERT INTO store.product_categories VALUES (25, 5);
INSERT INTO store.product_categories VALUES (26, 6);
INSERT INTO store.product_categories VALUES (27, 6);
INSERT INTO store.product_categories VALUES (28, 6);
INSERT INTO store.product_categories VALUES (29, 6);
INSERT INTO store.product_categories VALUES (30, 6);
INSERT INTO store.product_categories VALUES (31, 7);
INSERT INTO store.product_categories VALUES (32, 7);
INSERT INTO store.product_categories VALUES (33, 7);
INSERT INTO store.product_categories VALUES (34, 7);
INSERT INTO store.product_categories VALUES (35, 7);
INSERT INTO store.product_categories VALUES (36, 8);
INSERT INTO store.product_categories VALUES (37, 8);
INSERT INTO store.product_categories VALUES (38, 8);
INSERT INTO store.product_categories VALUES (39, 8);
INSERT INTO store.product_categories VALUES (40, 8);
INSERT INTO store.product_categories VALUES (41, 9);
INSERT INTO store.product_categories VALUES (42, 9);
INSERT INTO store.product_categories VALUES (43, 9);
INSERT INTO store.product_categories VALUES (44, 9);
INSERT INTO store.product_categories VALUES (45, 9);
INSERT INTO store.product_categories VALUES (46, 10);
INSERT INTO store.product_categories VALUES (47, 10);
INSERT INTO store.product_categories VALUES (48, 10);
INSERT INTO store.product_categories VALUES (49, 10);
INSERT INTO store.product_categories VALUES (50, 10);


--
-- Data for Name: products; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.products VALUES (1, 'Pametni telefon X200', 'Moderan pametni telefon sa 128GB memorije i trostrukom kamerom.', 48999.99, 35);
INSERT INTO store.products VALUES (2, 'LED TV 55"', 'Ultra HD televizor sa pametnim funkcijama i HDMI ulazima.', 69999.00, 12);
INSERT INTO store.products VALUES (3, 'Bluetooth zvučnik', 'Bežični zvučnik otporan na vodu sa do 10 sati baterije.', 4999.00, 50);
INSERT INTO store.products VALUES (4, 'Laptop ProBook 450', 'Pouzdan laptop sa Intel i5 procesorom i 8GB RAM-a.', 84999.99, 15);
INSERT INTO store.products VALUES (5, 'Bežične slušalice', 'Slušalice sa aktivnim poništavanjem buke.', 11499.00, 42);
INSERT INTO store.products VALUES (6, 'Mikrotalasna rerna', '800W mikrotalasna sa 5 nivoa snage i tajmerom.', 9499.00, 20);
INSERT INTO store.products VALUES (7, 'Usisivač 2000W', 'Moćan usisivač sa HEPA filterom i više dodataka.', 12999.00, 18);
INSERT INTO store.products VALUES (8, 'Toster XL', 'Električni toster sa opcijom za 4 kriške.', 3999.00, 40);
INSERT INTO store.products VALUES (9, 'Kuvalo za vodu', 'Kuvanje vode za manje od 2 minuta.', 2899.00, 33);
INSERT INTO store.products VALUES (10, 'Mašina za pranje veša', 'Kapacitet 8kg, 1400 obrtaja, energetska klasa A++.', 44999.00, 8);
INSERT INTO store.products VALUES (11, 'Muška majica', 'Pamučna majica kratkih rukava, razne boje.', 1299.00, 70);
INSERT INTO store.products VALUES (12, 'Ženska bluza', 'Elegantna bluza od viskoze, dostupna u više veličina.', 2499.00, 50);
INSERT INTO store.products VALUES (13, 'Trenerka', 'Sportska trenerka od pamuka sa rajsferšlusom.', 3999.00, 25);
INSERT INTO store.products VALUES (14, 'Zimska jakna', 'Vodootporna jakna sa kapuljačom i termo postavom.', 8499.00, 22);
INSERT INTO store.products VALUES (15, 'Letnja haljina', 'Lagana haljina sa cvetnim dezenom.', 3499.00, 30);
INSERT INTO store.products VALUES (16, 'Muške patike', 'Udobne sportske patike za svakodnevno nošenje.', 5999.00, 40);
INSERT INTO store.products VALUES (17, 'Ženske sandale', 'Kožne sandale sa anatomski oblikovanom tabanicom.', 4499.00, 35);
INSERT INTO store.products VALUES (18, 'Dečije čizme', 'Vodootporne zimske čizme za decu.', 3799.00, 28);
INSERT INTO store.products VALUES (19, 'Kućne papuče', 'Mekane papuče sa gumenim đonom.', 1599.00, 50);
INSERT INTO store.products VALUES (20, 'Sportske cipele', 'Obuća za trčanje i rekreativne aktivnosti.', 4999.00, 32);
INSERT INTO store.products VALUES (21, 'Blok A5', 'Blok sa 80 listova, linije.', 199.00, 120);
INSERT INTO store.products VALUES (22, 'Hemijska olovka', 'Pakovanje od 5 hemijskih olovaka, plava boja.', 249.00, 200);
INSERT INTO store.products VALUES (23, 'Flomasteri', '12 boja u kartonskoj kutiji.', 399.00, 80);
INSERT INTO store.products VALUES (24, 'Sveska A4', 'Matematika sveska sa kvadratićima.', 129.00, 100);
INSERT INTO store.products VALUES (25, 'Lepljivi papirići', 'Set od 5 boja, idealno za obeležavanje.', 299.00, 90);
INSERT INTO store.products VALUES (26, 'Roman "Na Drini ćuprija"', 'Ivo Andrić – dobitnik Nobelove nagrade.', 899.00, 25);
INSERT INTO store.products VALUES (27, 'Enciklopedija nauke', 'Ilustrovana knjiga za decu i odrasle.', 1599.00, 18);
INSERT INTO store.products VALUES (28, 'Gramatika srpskog jezika', 'Obavezna lektira za osnovce.', 799.00, 33);
INSERT INTO store.products VALUES (29, 'Kuvanje sa Miom', 'Knjiga sa tradicionalnim receptima.', 1199.00, 14);
INSERT INTO store.products VALUES (30, 'Psihologija uspeha', 'Popularna psihološka literatura.', 999.00, 22);
INSERT INTO store.products VALUES (31, 'Lego set policijska stanica', 'Komplet za sklapanje sa više od 300 delova.', 3499.00, 15);
INSERT INTO store.products VALUES (32, 'Lutka sa haljinom', 'Moderna lutka sa dodatnom garderobom.', 2199.00, 40);
INSERT INTO store.products VALUES (33, 'Autić na daljinski', 'Brzi autić sa USB punjenjem.', 2999.00, 20);
INSERT INTO store.products VALUES (34, 'Plišana igračka – meda', 'Mekani plišani meda od 40 cm.', 1499.00, 45);
INSERT INTO store.products VALUES (35, 'Puzzle 1000 delova', 'Slagalica sa motivom Beograda.', 999.00, 30);
INSERT INTO store.products VALUES (36, 'Baštenska stolica', 'Plastična stolica otporna na vlagu.', 1799.00, 27);
INSERT INTO store.products VALUES (37, 'Crevo za zalivanje 15m', 'Fleksibilno crevo sa nastavcima.', 2299.00, 20);
INSERT INTO store.products VALUES (38, 'Makaze za grane', 'Oštre makaze sa ergonomskom drškom.', 1699.00, 19);
INSERT INTO store.products VALUES (39, 'Set za sadnju', '3 saksije, lopatica i rukavice.', 1499.00, 35);
INSERT INTO store.products VALUES (40, 'Baštenska lampa solarna', 'LED lampa sa senzorom i solarnim punjenjem.', 899.00, 50);
INSERT INTO store.products VALUES (41, 'Mlevena kafa 200g', 'Tradicionalna kafa bogatog ukusa.', 349.00, 60);
INSERT INTO store.products VALUES (42, 'Sok od jabuke 1L', '100% prirodni sok bez dodatog šećera.', 179.00, 80);
INSERT INTO store.products VALUES (43, 'Čokolada mlečna 100g', 'Švajcarska čokolada sa lešnicima.', 229.00, 90);
INSERT INTO store.products VALUES (44, 'Tjestenina penne 500g', 'Italijanska testenina od durum pšenice.', 159.00, 70);
INSERT INTO store.products VALUES (45, 'Maslinovo ulje 750ml', 'Ekstra devičansko ulje iz Grčke.', 799.00, 40);
INSERT INTO store.products VALUES (46, 'Šampon za kosu 400ml', 'Protiv opadanja sa prirodnim sastojcima.', 499.00, 55);
INSERT INTO store.products VALUES (47, 'Pasta za zube 75ml', 'Osvežava dah i štiti desni.', 249.00, 100);
INSERT INTO store.products VALUES (48, 'Gel za tuširanje', 'Opuštajući miris lavande.', 399.00, 70);
INSERT INTO store.products VALUES (49, 'Krema za lice 50ml', 'Dnevna krema sa zaštitnim faktorom.', 899.00, 35);
INSERT INTO store.products VALUES (50, 'Brijač set 3+1', 'Pakovanje sa dodatnim rezervama.', 349.00, 80);


--
-- Data for Name: users; Type: TABLE DATA; Schema: store; Owner: postgres
--

INSERT INTO store.users VALUES (1, 'Luka', 'Petrović', 'luka.p@gmail.com', 'hashed_1', '2023-01-15 00:00:00');
INSERT INTO store.users VALUES (2, 'Milica', 'Jovanović', 'milica.jovanovic@yahoo.com', 'hashed_2', '2023-02-11 00:00:00');
INSERT INTO store.users VALUES (3, 'Marko', 'Nikolić', 'marko.nikolic@hotmail.com', 'hashed_3', '2023-02-25 00:00:00');
INSERT INTO store.users VALUES (4, 'Ivana', 'Stojanov', 'ivana.st@gmail.com', 'hashed_4', '2023-03-03 00:00:00');
INSERT INTO store.users VALUES (5, 'Stefan', 'Lazarević', 'stefan.lz@gmail.com', 'hashed_5', '2023-03-18 00:00:00');
INSERT INTO store.users VALUES (6, 'Ana', 'Matić', 'ana.matic@outlook.com', 'hashed_6', '2023-04-01 00:00:00');
INSERT INTO store.users VALUES (7, 'Nikola', 'Simić', 'nikola.simic@gmail.com', 'hashed_7', '2023-04-14 00:00:00');
INSERT INTO store.users VALUES (8, 'Jelena', 'Popović', 'jelena.popovic@yahoo.com', 'hashed_8', '2023-04-22 00:00:00');
INSERT INTO store.users VALUES (9, 'Vuk', 'Đorđević', 'vuk.d@gmail.com', 'hashed_9', '2023-05-07 00:00:00');
INSERT INTO store.users VALUES (10, 'Tamara', 'Ilić', 'tamara.ilic@hotmail.com', 'hashed_10', '2023-05-15 00:00:00');
INSERT INTO store.users VALUES (11, 'Filip', 'Milinković', 'filip.m@gmail.com', 'hashed_11', '2023-05-20 00:00:00');
INSERT INTO store.users VALUES (12, 'Katarina', 'Blagojević', 'katarina.b@gmail.com', 'hashed_12', '2023-06-01 00:00:00');
INSERT INTO store.users VALUES (13, 'Aleksandar', 'Vujić', 'aleksandar.v@hotmail.com', 'hashed_13', '2023-06-12 00:00:00');
INSERT INTO store.users VALUES (14, 'Nevena', 'Radić', 'nevena.r@gmail.com', 'hashed_14', '2023-06-18 00:00:00');
INSERT INTO store.users VALUES (15, 'Ognjen', 'Kovačević', 'ognjen.k@yahoo.com', 'hashed_15', '2023-06-30 00:00:00');
INSERT INTO store.users VALUES (16, 'Teodora', 'Marković', 'teodora.m@outlook.com', 'hashed_16', '2023-07-05 00:00:00');
INSERT INTO store.users VALUES (17, 'Miloš', 'Savović', 'milos.s@gmail.com', 'hashed_17', '2023-07-17 00:00:00');
INSERT INTO store.users VALUES (18, 'Sara', 'Lukić', 'sara.lukic@gmail.com', 'hashed_18', '2023-07-29 00:00:00');
INSERT INTO store.users VALUES (19, 'Andrija', 'Janković', 'andrija.jankovic@yahoo.com', 'hashed_19', '2023-08-02 00:00:00');
INSERT INTO store.users VALUES (20, 'Jovana', 'Mirković', 'jovana.mirkovic@hotmail.com', 'hashed_20', '2023-08-10 00:00:00');
INSERT INTO store.users VALUES (21, 'Uroš', 'Todorović', 'uros.t@gmail.com', 'hashed_21', '2023-08-18 00:00:00');
INSERT INTO store.users VALUES (22, 'Marija', 'Petković', 'marija.p@gmail.com', 'hashed_22', '2023-08-24 00:00:00');
INSERT INTO store.users VALUES (23, 'Đorđe', 'Zorić', 'djordje.zoric@outlook.com', 'hashed_23', '2023-09-01 00:00:00');
INSERT INTO store.users VALUES (24, 'Sofija', 'Ivanović', 'sofija.i@gmail.com', 'hashed_24', '2023-09-09 00:00:00');
INSERT INTO store.users VALUES (25, 'Bogdan', 'Ristić', 'bogdan.ristic@gmail.com', 'hashed_25', '2023-09-17 00:00:00');
INSERT INTO store.users VALUES (26, 'Anđela', 'Pavlović', 'andjela.p@gmail.com', 'hashed_26', '2023-09-25 00:00:00');
INSERT INTO store.users VALUES (27, 'Vladimir', 'Stević', 'vladimir.stevic@gmail.com', 'hashed_27', '2023-10-01 00:00:00');
INSERT INTO store.users VALUES (28, 'Natalija', 'Babić', 'natalija.babic@yahoo.com', 'hashed_28', '2023-10-10 00:00:00');
INSERT INTO store.users VALUES (29, 'Nenad', 'Krstić', 'nenad.krstic@gmail.com', 'hashed_29', '2023-10-15 00:00:00');
INSERT INTO store.users VALUES (30, 'Milena', 'Stamenković', 'milena.s@gmail.com', 'hashed_30', '2023-10-22 00:00:00');
INSERT INTO store.users VALUES (31, 'Igor', 'Perić', 'igor.peric@outlook.com', 'hashed_31', '2023-11-01 00:00:00');
INSERT INTO store.users VALUES (32, 'Dunja', 'Bošković', 'dunja.b@gmail.com', 'hashed_32', '2023-11-09 00:00:00');
INSERT INTO store.users VALUES (33, 'Lazar', 'Ćirić', 'lazar.ciric@gmail.com', 'hashed_33', '2023-11-17 00:00:00');
INSERT INTO store.users VALUES (34, 'Jasmina', 'Grujić', 'jasmina.grujic@gmail.com', 'hashed_34', '2023-11-24 00:00:00');
INSERT INTO store.users VALUES (35, 'Petar', 'Rakić', 'petar.rakic@gmail.com', 'hashed_35', '2023-12-01 00:00:00');
INSERT INTO store.users VALUES (36, 'Tijana', 'Trifunović', 'tijana.t@gmail.com', 'hashed_36', '2023-12-08 00:00:00');
INSERT INTO store.users VALUES (37, 'Vesna', 'Aleksić', 'vesna.aleksic@gmail.com', 'hashed_37', '2023-12-15 00:00:00');
INSERT INTO store.users VALUES (38, 'Kristijan', 'Vasiljević', 'kristijan.vasiljevic@gmail.com', 'hashed_38', '2023-12-22 00:00:00');
INSERT INTO store.users VALUES (39, 'Martina', 'Jovičić', 'martina.j@gmail.com', 'hashed_39', '2024-01-01 00:00:00');
INSERT INTO store.users VALUES (40, 'Željko', 'Obradović', 'zeljko.obradovic@gmail.com', 'hashed_40', '2024-01-09 00:00:00');
INSERT INTO store.users VALUES (41, 'Isidora', 'Tasić', 'isidora.tasic@yahoo.com', 'hashed_41', '2024-01-16 00:00:00');
INSERT INTO store.users VALUES (42, 'Matija', 'Knežević', 'matija.k@gmail.com', 'hashed_42', '2024-01-23 00:00:00');
INSERT INTO store.users VALUES (43, 'Ena', 'Vidić', 'ena.vidic@gmail.com', 'hashed_43', '2024-01-30 00:00:00');
INSERT INTO store.users VALUES (44, 'Ilija', 'Šarić', 'ilija.saric@gmail.com', 'hashed_44', '2024-02-07 00:00:00');
INSERT INTO store.users VALUES (45, 'Lana', 'Pantić', 'lana.pantic@gmail.com', 'hashed_45', '2024-02-14 00:00:00');
INSERT INTO store.users VALUES (46, 'Borislav', 'Veselinović', 'borislav.v@gmail.com', 'hashed_46', '2024-02-21 00:00:00');
INSERT INTO store.users VALUES (47, 'Tamara', 'Vuković', 'tamara.vukovic@gmail.com', 'hashed_47', '2024-02-28 00:00:00');
INSERT INTO store.users VALUES (48, 'Radovan', 'Živković', 'radovan.zivkovic@gmail.com', 'hashed_48', '2024-03-06 00:00:00');
INSERT INTO store.users VALUES (49, 'Andrea', 'Stefanović', 'andrea.s@gmail.com', 'hashed_49', '2024-03-13 00:00:00');
INSERT INTO store.users VALUES (50, 'Dušan', 'Kostić', 'dusan.kostic@gmail.com', 'hashed_50', '2024-03-20 00:00:00');


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: warehouse; Owner: postgres
--

INSERT INTO warehouse.inventory VALUES (1, 3, 120, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (1, 8, 250, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (1, 15, 60, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (1, 21, 330, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (1, 33, 90, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (2, 2, 75, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (2, 9, 410, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (2, 14, 0, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (2, 17, 95, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (2, 29, 122, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (3, 1, 30, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (3, 7, 270, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (3, 10, 150, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (3, 19, 500, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (4, 4, 140, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (4, 11, 390, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (4, 22, 0, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (4, 36, 35, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (5, 5, 400, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (5, 13, 10, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (5, 18, 5, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (6, 6, 90, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (6, 20, 280, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (6, 32, 120, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (7, 16, 0, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (7, 24, 75, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (8, 12, 40, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (8, 27, 150, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (8, 34, 310, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (9, 30, 5, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (9, 35, 95, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (10, 26, 320, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (10, 28, 230, '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.inventory VALUES (10, 38, 100, '2025-05-20 15:04:14.0471');


--
-- Data for Name: restock_requests; Type: TABLE DATA; Schema: warehouse; Owner: postgres
--

INSERT INTO warehouse.restock_requests VALUES (1, 2, 14, 100, 'pending', '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.restock_requests VALUES (2, 4, 22, 100, 'pending', '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.restock_requests VALUES (3, 5, 18, 100, 'pending', '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.restock_requests VALUES (4, 7, 16, 100, 'pending', '2025-05-20 15:04:14.0471');
INSERT INTO warehouse.restock_requests VALUES (5, 9, 30, 100, 'pending', '2025-05-20 15:04:14.0471');


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: warehouse; Owner: postgres
--

INSERT INTO warehouse.warehouses VALUES (1, 'Magacin Beograd', 'Beograd, Srbija', 10000);
INSERT INTO warehouse.warehouses VALUES (2, 'Magacin Novi Sad', 'Novi Sad, Srbija', 8000);
INSERT INTO warehouse.warehouses VALUES (3, 'Magacin Niš', 'Niš, Srbija', 7000);
INSERT INTO warehouse.warehouses VALUES (4, 'Magacin Kragujevac', 'Kragujevac, Srbija', 6000);
INSERT INTO warehouse.warehouses VALUES (5, 'Magacin Subotica', 'Subotica, Srbija', 5000);
INSERT INTO warehouse.warehouses VALUES (6, 'Magacin Zrenjanin', 'Zrenjanin, Srbija', 4000);
INSERT INTO warehouse.warehouses VALUES (7, 'Magacin Čačak', 'Čačak, Srbija', 3000);
INSERT INTO warehouse.warehouses VALUES (8, 'Magacin Pančevo', 'Pančevo, Srbija', 3500);
INSERT INTO warehouse.warehouses VALUES (9, 'Magacin Kraljevo', 'Kraljevo, Srbija', 4500);
INSERT INTO warehouse.warehouses VALUES (10, 'Magacin Sombor', 'Sombor, Srbija', 2500);


--
-- Name: audit_log_entry_id_seq; Type: SEQUENCE SET; Schema: admin; Owner: postgres
--

SELECT pg_catalog.setval('admin.audit_log_entry_id_seq', 50, true);


--
-- Name: addresses_address_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.addresses_address_id_seq', 1, false);


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.categories_category_id_seq', 1, false);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.orders_order_id_seq', 1, false);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.payments_payment_id_seq', 1, false);


--
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.products_product_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: store; Owner: postgres
--

SELECT pg_catalog.setval('store.users_user_id_seq', 1, false);


--
-- Name: restock_requests_request_id_seq; Type: SEQUENCE SET; Schema: warehouse; Owner: postgres
--

SELECT pg_catalog.setval('warehouse.restock_requests_request_id_seq', 5, true);


--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE SET; Schema: warehouse; Owner: postgres
--

SELECT pg_catalog.setval('warehouse.warehouses_warehouse_id_seq', 10, true);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (entry_id);


--
-- Name: db_users db_users_pkey; Type: CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.db_users
    ADD CONSTRAINT db_users_pkey PRIMARY KEY (username);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: order_details order_details_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (order_id, product_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (product_id, category_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (warehouse_id, product_id);


--
-- Name: restock_requests restock_requests_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.restock_requests
    ADD CONSTRAINT restock_requests_pkey PRIMARY KEY (request_id);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (warehouse_id);


--
-- Name: idx_addresses_user_id; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_addresses_user_id ON store.addresses USING btree (user_id);


--
-- Name: idx_categories_name; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_categories_name ON store.categories USING btree (name);


--
-- Name: idx_order_details_order_id; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_order_details_order_id ON store.order_details USING btree (order_id);


--
-- Name: idx_order_details_product_id; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_order_details_product_id ON store.order_details USING btree (product_id);


--
-- Name: idx_orders_order_date; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_orders_order_date ON store.orders USING btree (order_date);


--
-- Name: idx_orders_status; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_orders_status ON store.orders USING btree (status);


--
-- Name: idx_orders_user_id; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_orders_user_id ON store.orders USING btree (user_id);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_payments_order_id ON store.payments USING btree (order_id);


--
-- Name: idx_product_categories_category_id; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_product_categories_category_id ON store.product_categories USING btree (category_id);


--
-- Name: idx_products_name; Type: INDEX; Schema: store; Owner: postgres
--

CREATE INDEX idx_products_name ON store.products USING btree (name);


--
-- Name: idx_users_email; Type: INDEX; Schema: store; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_email ON store.users USING btree (email);


--
-- Name: products trg_log_product_changes; Type: TRIGGER; Schema: store; Owner: postgres
--

CREATE TRIGGER trg_log_product_changes AFTER INSERT OR DELETE OR UPDATE ON store.products FOR EACH ROW EXECUTE FUNCTION admin.log_product_changes();


--
-- Name: inventory trg_auto_restock; Type: TRIGGER; Schema: warehouse; Owner: postgres
--

CREATE TRIGGER trg_auto_restock AFTER INSERT OR UPDATE ON warehouse.inventory FOR EACH ROW EXECUTE FUNCTION warehouse.auto_restock_request();


--
-- Name: addresses addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES store.users(user_id);


--
-- Name: order_details order_details_order_id_fkey; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.order_details
    ADD CONSTRAINT order_details_order_id_fkey FOREIGN KEY (order_id) REFERENCES store.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_details order_details_product_id_fkey; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.order_details
    ADD CONSTRAINT order_details_product_id_fkey FOREIGN KEY (product_id) REFERENCES store.products(product_id);


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES store.users(user_id);


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES store.orders(order_id);


--
-- Name: product_categories product_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.product_categories
    ADD CONSTRAINT product_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES store.categories(category_id) ON DELETE CASCADE;


--
-- Name: product_categories product_categories_product_id_fkey; Type: FK CONSTRAINT; Schema: store; Owner: postgres
--

ALTER TABLE ONLY store.product_categories
    ADD CONSTRAINT product_categories_product_id_fkey FOREIGN KEY (product_id) REFERENCES store.products(product_id) ON DELETE CASCADE;


--
-- Name: inventory inventory_product_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.inventory
    ADD CONSTRAINT inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES store.products(product_id) ON DELETE CASCADE;


--
-- Name: inventory inventory_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.inventory
    ADD CONSTRAINT inventory_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse.warehouses(warehouse_id) ON DELETE CASCADE;


--
-- Name: restock_requests restock_requests_product_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.restock_requests
    ADD CONSTRAINT restock_requests_product_id_fkey FOREIGN KEY (product_id) REFERENCES store.products(product_id) ON DELETE CASCADE;


--
-- Name: restock_requests restock_requests_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: postgres
--

ALTER TABLE ONLY warehouse.restock_requests
    ADD CONSTRAINT restock_requests_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES warehouse.warehouses(warehouse_id) ON DELETE CASCADE;


--
-- Name: orders; Type: ROW SECURITY; Schema: store; Owner: postgres
--

ALTER TABLE store.orders ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA admin; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA admin TO admin_role;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- Name: SCHEMA store; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA store TO admin_role;
GRANT USAGE ON SCHEMA store TO manager_role;
GRANT USAGE ON SCHEMA store TO staff_role;
GRANT USAGE ON SCHEMA store TO readonly_role;


--
-- Name: SCHEMA warehouse; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA warehouse TO admin_role;
GRANT USAGE ON SCHEMA warehouse TO manager_role;
GRANT USAGE ON SCHEMA warehouse TO staff_role;
GRANT USAGE ON SCHEMA warehouse TO readonly_role;


--
-- Name: FUNCTION log_product_changes(); Type: ACL; Schema: admin; Owner: postgres
--

REVOKE ALL ON FUNCTION admin.log_product_changes() FROM PUBLIC;
GRANT ALL ON FUNCTION admin.log_product_changes() TO admin_role;


--
-- Name: FUNCTION auto_restock_request(); Type: ACL; Schema: warehouse; Owner: postgres
--

REVOKE ALL ON FUNCTION warehouse.auto_restock_request() FROM PUBLIC;
GRANT ALL ON FUNCTION warehouse.auto_restock_request() TO admin_role;


--
-- Name: TABLE audit_log; Type: ACL; Schema: admin; Owner: postgres
--

GRANT ALL ON TABLE admin.audit_log TO admin_role;


--
-- Name: TABLE db_users; Type: ACL; Schema: admin; Owner: postgres
--

GRANT ALL ON TABLE admin.db_users TO admin_role;


--
-- Name: TABLE addresses; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.addresses TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.addresses TO manager_role;
GRANT SELECT ON TABLE store.addresses TO readonly_role;


--
-- Name: TABLE categories; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.categories TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.categories TO manager_role;
GRANT SELECT ON TABLE store.categories TO readonly_role;


--
-- Name: TABLE order_details; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.order_details TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.order_details TO manager_role;
GRANT SELECT,INSERT ON TABLE store.order_details TO staff_role;
GRANT SELECT ON TABLE store.order_details TO readonly_role;


--
-- Name: TABLE orders; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.orders TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.orders TO manager_role;
GRANT SELECT,INSERT ON TABLE store.orders TO staff_role;
GRANT SELECT ON TABLE store.orders TO readonly_role;


--
-- Name: TABLE payments; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.payments TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.payments TO manager_role;
GRANT SELECT ON TABLE store.payments TO readonly_role;


--
-- Name: TABLE product_categories; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.product_categories TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.product_categories TO manager_role;
GRANT SELECT ON TABLE store.product_categories TO readonly_role;


--
-- Name: TABLE products; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.products TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.products TO manager_role;
GRANT SELECT ON TABLE store.products TO staff_role;
GRANT SELECT ON TABLE store.products TO readonly_role;


--
-- Name: TABLE users; Type: ACL; Schema: store; Owner: postgres
--

GRANT ALL ON TABLE store.users TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE store.users TO manager_role;
GRANT SELECT ON TABLE store.users TO readonly_role;


--
-- Name: TABLE inventory; Type: ACL; Schema: warehouse; Owner: postgres
--

GRANT ALL ON TABLE warehouse.inventory TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE warehouse.inventory TO manager_role;
GRANT SELECT ON TABLE warehouse.inventory TO staff_role;
GRANT SELECT ON TABLE warehouse.inventory TO readonly_role;


--
-- Name: TABLE restock_requests; Type: ACL; Schema: warehouse; Owner: postgres
--

GRANT ALL ON TABLE warehouse.restock_requests TO admin_role;
GRANT SELECT,INSERT ON TABLE warehouse.restock_requests TO manager_role;
GRANT SELECT ON TABLE warehouse.restock_requests TO readonly_role;


--
-- Name: TABLE warehouses; Type: ACL; Schema: warehouse; Owner: postgres
--

GRANT ALL ON TABLE warehouse.warehouses TO admin_role;
GRANT SELECT ON TABLE warehouse.warehouses TO readonly_role;
GRANT SELECT ON TABLE warehouse.warehouses TO manager_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: store; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA store GRANT SELECT,INSERT,UPDATE ON TABLES TO manager_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA store GRANT SELECT,INSERT ON TABLES TO staff_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA store GRANT SELECT ON TABLES TO readonly_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: warehouse; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA warehouse GRANT SELECT,INSERT,UPDATE ON TABLES TO manager_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA warehouse GRANT SELECT ON TABLES TO staff_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA warehouse GRANT SELECT ON TABLES TO readonly_role;


--
-- PostgreSQL database dump complete
--

