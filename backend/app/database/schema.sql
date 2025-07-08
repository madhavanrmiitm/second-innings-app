-- Drop tables if they exist to ensure a clean slate.
DROP TABLE IF EXISTS items;

-- Create tables
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL
);
