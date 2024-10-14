-- Table for users dimension
CREATE TABLE IF NOT EXISTS dim_users (
    user_id VARCHAR PRIMARY KEY,
    active BOOLEAN,
    created_date TIMESTAMP,
    last_login TIMESTAMP,
    role VARCHAR,
    signup_source VARCHAR,
    state VARCHAR
);

-- Table for brands dimension
CREATE TABLE IF NOT EXISTS dim_brands (
    brand_id VARCHAR PRIMARY KEY,
    barcode VARCHAR UNIQUE,
    brand_code VARCHAR,
    name VARCHAR,
    category VARCHAR,
    category_code VARCHAR,
    created_at TIMESTAMP
    top_brand BOOLEAN
);

-- Table for receipt items dimension
CREATE TABLE IF NOT EXISTS dim_receiptitems (
    receiptItem_id VARCHAR PRIMARY KEY,
    rewards_receipt_status VARCHAR
);

-- Fact table for receipt items
CREATE TABLE IF NOT EXISTS fct_receiptitems (
    receiptItem_id VARCHAR PRIMARY KEY,
    user_id VARCHAR REFERENCES dim_users(user_id),
    barcode VARCHAR REFERENCES dim_brands(barcode),
    receipt_id VARCHAR,
    final_price FLOAT,
    item_price FLOAT,
    points_earned FLOAT,
    quantity_purchased INTEGER,
    date_scanned TIMESTAMP
);
