-- Insert sample products data
-- Version: 1.1
-- Description: Sample product data for testing

INSERT INTO products (name, description, sku, price, category_id, stock_quantity, is_active) VALUES
('Laptop Pro 15"', 'High-performance laptop with 16GB RAM and 512GB SSD', 'LAPTOP-PRO-15', 1299.99, 1, 50, true),
('Wireless Mouse', 'Ergonomic wireless mouse with USB receiver', 'MOUSE-WIRELESS-01', 29.99, 2, 200, true),
('Mechanical Keyboard', 'RGB mechanical keyboard with Cherry MX switches', 'KEYBOARD-MECH-01', 149.99, 2, 75, true),
('Monitor 27"', '4K Ultra HD monitor with HDR support', 'MONITOR-27-4K', 399.99, 3, 30, true),
('USB-C Hub', 'Multi-port USB-C hub with HDMI, USB-A, and Ethernet', 'HUB-USBC-01', 79.99, 4, 100, true),
('Discontinued Product', 'This product is no longer available', 'DISCONTINUED-01', 0.00, 1, 0, false)
ON CONFLICT (sku) DO NOTHING;

-- Update sequence
SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));
