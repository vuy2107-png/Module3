-- =============================
-- BƯỚC 1: TẠO CƠ SỞ DỮ LIỆU
-- =============================
CREATE DATABASE demo;
USE demo;


-- =============================
-- BƯỚC 2: TẠO BẢNG + INSERT DATA
-- =============================
CREATE TABLE Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(50) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DOUBLE NOT NULL,
    productAmount INT NOT NULL,
    productDescription VARCHAR(255),
    productStatus TINYINT
);

INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
VALUES
('P001', 'iPhone 15', 25000000, 10, 'New model', 1),
('P002', 'Samsung S23', 18000000, 15, 'Flagship Samsung', 1),
('P003', 'Xiaomi Note 13', 6000000, 30, 'Best budget', 1),
('P004', 'Oppo Reno 10', 9000000, 20, 'Good camera', 1);


-- =============================
-- BƯỚC 3: TẠO INDEX
-- =============================

-- 1. UNIQUE INDEX trên productCode
CREATE UNIQUE INDEX idx_code ON Products(productCode);

-- 2. COMPOSITE INDEX trên productName + productPrice
CREATE INDEX idx_name_price ON Products(productName, productPrice);

-- 3. EXPLAIN kiểm tra hiệu suất
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';
EXPLAIN SELECT * FROM Products WHERE productName = 'iPhone 15' AND productPrice = 25000000;


-- =============================
-- BƯỚC 4: VIEW
-- =============================

-- 1. Tạo view
CREATE VIEW v_product_info AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

-- 2. Sửa view
ALTER VIEW v_product_info AS
SELECT productCode, productName, productPrice, productAmount, productStatus
FROM Products;

-- 3. Xóa view
-- DROP VIEW v_product_info;


-- =============================
-- BƯỚC 5: STORED PROCEDURE
-- =============================

-- 1. Lấy tất cả sản phẩm
DELIMITER //
CREATE PROCEDURE getAllProducts()
BEGIN
    SELECT * FROM Products;
END //
DELIMITER ;

-- 2. Thêm sản phẩm mới
DELIMITER //
CREATE PROCEDURE addProduct(
    IN p_code VARCHAR(50),
    IN p_name VARCHAR(100),
    IN p_price DOUBLE,
    IN p_amount INT,
    IN p_desc VARCHAR(255),
    IN p_status TINYINT
)
BEGIN
    INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_desc, p_status);
END //
DELIMITER ;

-- 3. Sửa sản phẩm theo Id
DELIMITER //
CREATE PROCEDURE updateProductById(
    IN p_id INT,
    IN p_code VARCHAR(50),
    IN p_name VARCHAR(100),
    IN p_price DOUBLE,
    IN p_amount INT,
    IN p_desc VARCHAR(255),
    IN p_status TINYINT
)
BEGIN
    UPDATE Products
    SET
        productCode = p_code,
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_desc,
        productStatus = p_status
    WHERE Id = p_id;
END //
DELIMITER ;

-- 4. Xóa sản phẩm theo Id
DELIMITER //
CREATE PROCEDURE deleteProductById(IN p_id INT)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //
DELIMITER ;
