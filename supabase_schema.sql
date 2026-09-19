-- =========================================================================
-- FERTILIZER FACTORY MANAGEMENT SYSTEM - SUPABASE SQL SCHEMA + SAMPLE DATA
-- =========================================================================

-- 1. Company Info (ข้อมูลบริษัท)
CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    thai_name VARCHAR(255) NOT NULL,
    eng_name VARCHAR(255),
    branch VARCHAR(100),
    tax_id VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Crop Years (ปีการผลิต)
CREATE TABLE IF NOT EXISTS crop_years (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    year_code VARCHAR(50) NOT NULL,
    start_date DATE,
    end_date DATE,
    status VARCHAR(50) DEFAULT 'เปิด',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. Warehouses (ตั้งค่าโกดัง)
CREATE TABLE IF NOT EXISTS warehouses (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    warehouse_type VARCHAR(100) NOT NULL,
    main_code VARCHAR(50) NOT NULL,
    sub_zone VARCHAR(50),
    capacity NUMERIC(12, 2),
    unit VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. Vendors (ข้อมูลเจ้าหนี้)
CREATE TABLE IF NOT EXISTS vendors (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    vendor_code VARCHAR(50) NOT NULL UNIQUE,
    old_code VARCHAR(50),
    prefix VARCHAR(50),
    vendor_name VARCHAR(255) NOT NULL,
    vendor_type VARCHAR(50),
    tax_id VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 5. Customers (ข้อมูลลูกค้า)
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    customer_code VARCHAR(50) NOT NULL UNIQUE,
    old_code VARCHAR(50),
    prefix VARCHAR(50),
    customer_name VARCHAR(255) NOT NULL,
    customer_type VARCHAR(50),
    credit_status VARCHAR(50) DEFAULT 'ปกติ',
    customer_grade VARCHAR(10) DEFAULT 'A',
    credit_days INTEGER DEFAULT 0,
    address TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 6. Raw Materials (รหัสแม่ปุ๋ย)
CREATE TABLE IF NOT EXISTS raw_materials (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    rm_code VARCHAR(50) NOT NULL UNIQUE,
    rm_name VARCHAR(255) NOT NULL,
    rm_type VARCHAR(100),
    n_percent NUMERIC(5, 2) DEFAULT 0,
    p_percent NUMERIC(5, 2) DEFAULT 0,
    k_percent NUMERIC(5, 2) DEFAULT 0,
    s_percent NUMERIC(5, 2) DEFAULT 0,
    cao_percent NUMERIC(5, 2) DEFAULT 0,
    mgo_percent NUMERIC(5, 2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 7. Finished Goods / Products (สินค้าสำเร็จรูป)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    product_code VARCHAR(50) NOT NULL UNIQUE,
    old_code VARCHAR(50),
    product_name VARCHAR(255) NOT NULL,
    product_type VARCHAR(50),
    brand VARCHAR(100),
    pack_size VARCHAR(50),
    formula VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 8. Packaging (บรรจุภัณฑ์)
CREATE TABLE IF NOT EXISTS packaging (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'ID-' || floor(random() * 900000 + 100000)::text,
    pkg_code VARCHAR(50) NOT NULL UNIQUE,
    old_code VARCHAR(50),
    pkg_name VARCHAR(255) NOT NULL,
    pack_size VARCHAR(50),
    unit VARCHAR(50),
    vendor VARCHAR(255),
    unit_cost NUMERIC(10, 2) DEFAULT 0,
    fg_code VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 9. Employees (ข้อมูลพนักงานและสิทธิ์)
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'EMP-' || floor(random() * 900000 + 100000)::text,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'operator',
    status VARCHAR(50) DEFAULT 'ใช้งาน',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 10. BOM Headers (หัวสูตรการผลิตปุ๋ย)
CREATE TABLE IF NOT EXISTS bom_headers (
    id SERIAL PRIMARY KEY,
    code_id VARCHAR(50) UNIQUE DEFAULT 'BOM-' || to_char(NOW(), 'YYYYMM') || '-' || lpad(floor(random() * 900 + 100)::text, 3, '0'),
    formula_name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL DEFAULT '2026-v1',
    total_weight NUMERIC(6, 2) DEFAULT 50.00,
    total_n NUMERIC(6, 2) DEFAULT 0,
    total_p NUMERIC(6, 2) DEFAULT 0,
    total_k NUMERIC(6, 2) DEFAULT 0,
    total_s NUMERIC(6, 2) DEFAULT 0,
    total_cao NUMERIC(6, 2) DEFAULT 0,
    total_mgo NUMERIC(6, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'Pending', -- Pending, Active, Inactive
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 11. BOM Details (รายละเอียดส่วนผสมแม่ปุ๋ยในสูตร)
CREATE TABLE IF NOT EXISTS bom_details (
    id SERIAL PRIMARY KEY,
    bom_code VARCHAR(50) NOT NULL,
    rm_code VARCHAR(50) NOT NULL,
    rm_name VARCHAR(255) NOT NULL,
    weight_50kg NUMERIC(6, 2) NOT NULL DEFAULT 0,
    n_kg NUMERIC(6, 2) DEFAULT 0,
    p_kg NUMERIC(6, 2) DEFAULT 0,
    k_kg NUMERIC(6, 2) DEFAULT 0,
    s_kg NUMERIC(6, 2) DEFAULT 0,
    cao_kg NUMERIC(6, 2) DEFAULT 0,
    mgo_kg NUMERIC(6, 2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-------------------------------------------------------------------------
-- DISABLE RLS
-------------------------------------------------------------------------
ALTER TABLE companies DISABLE ROW LEVEL SECURITY;
ALTER TABLE crop_years DISABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendors DISABLE ROW LEVEL SECURITY;
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE raw_materials DISABLE ROW LEVEL SECURITY;
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE packaging DISABLE ROW LEVEL SECURITY;
ALTER TABLE employees DISABLE ROW LEVEL SECURITY;
ALTER TABLE bom_headers DISABLE ROW LEVEL SECURITY;
ALTER TABLE bom_details DISABLE ROW LEVEL SECURITY;

-------------------------------------------------------------------------
-- SAMPLE DATA
-------------------------------------------------------------------------
INSERT INTO companies (thai_name, eng_name, branch, tax_id, address) VALUES
('บริษัท เวิลด์ เฟอท จำกัด', 'Worldfert Co.,Ltd.', 'สำนักงานใหญ่', '105531024397', '933 ถนนมหาไชย แขวงวังบูรพาภิรมย์ เขตพระนคร กรุงเทพมหานคร 10200')
ON CONFLICT DO NOTHING;

INSERT INTO raw_materials (rm_code, rm_name, rm_type, n_percent, p_percent, k_percent, s_percent, cao_percent, mgo_percent) VALUES
('RM-001', 'ยูเรีย (Urea)', 'ไนโตรเจน', 46.00, 0.00, 0.00, 0.00, 0.00, 0.00),
('RM-002', 'แอมโมเนียมซัลเฟต (AS)', 'ไนโตรเจน/กำมะถัน', 21.00, 0.00, 0.00, 24.00, 0.00, 0.00),
('RM-003', 'โมโนแอมโมเนียมฟอสเฟต (MAP)', 'ฟอสเฟต', 11.00, 44.00, 0.00, 0.00, 0.00, 0.00),
('RM-004', 'โพแทสเซียมคลอไรด์ (MOP)', 'โพแทสเซียม', 0.00, 0.00, 60.00, 0.00, 0.00, 0.00),
('RM-005', 'ฟิลเลอร์ (Filler / ดินขาว)', 'ตัวเติม', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00)
ON CONFLICT DO NOTHING;

INSERT INTO employees (username, password, full_name, role, status) VALUES
('admin', '123456', 'ผู้ดูแลระบบ (Administrator)', 'admin', 'ใช้งาน')
ON CONFLICT DO NOTHING;
