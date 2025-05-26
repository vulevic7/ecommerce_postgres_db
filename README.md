# E-Commerce PostgreSQL Database Project

This project is a fully developed PostgreSQL database schema for an e-commerce platform. It includes realistic data, schema design, access controls, performance tuning, and security features.

## Project structure
- Each directory includes the schema SQL, related functions, triggers, and sample data for its respective module.


## Schemas

### store schema
- Contains users, orders, products, payments, categories, etc.
- Implements RBAC, constraints, and indexing.

### warehouse schema
- Tracks inventory, restocking, and warehouse locations.
- Includes trigger-based automatic restock requests.

### admin schema
- Manages users and audit logs.
- Defines restricted roles and permissions.

## Security Features

- Row-Level Security (RLS) on sensitive tables
- Role-Based Access Control (RBAC) for different user types
- Audit logging of data changes
- Restricted access to the `public` schema

## Performance Optimization

- Strategic indexing on high-frequency queries
- Query plan analysis using EXPLAIN ANALYZE
- Data normalization with proper constraints

## Sample Data

Includes realistic names, products, orders, and addresses to simulate a real-world dataset.

# Clone the repository

```bash
git clone https://github.com/vulevic7/ecommerce_postgres_db.git
cd ecommerce_postgres_db


