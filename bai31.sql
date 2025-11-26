-- 1️ Tạo cơ sở dữ liệu
CREATE DATABASE IF NOT EXISTS QuanLyBanHang2;
USE QuanLyBanHang2;

-- 2️ Tạo bảng Customer
CREATE TABLE Customer(
    cID INT PRIMARY KEY,
    Name VARCHAR(25),
    cAge TINYINT
);

-- 3️ Tạo bảng Product
CREATE TABLE Product(
    pID INT PRIMARY KEY,
    pName VARCHAR(25),
    pPrice INT
);

-- 4️ Tạo bảng `Order`
CREATE TABLE `Order`(
    oID INT PRIMARY KEY,
    cID INT,
    oDate DATETIME,
    oTotalPrice INT,
    FOREIGN KEY (cID) REFERENCES Customer(cID)
);

-- 5️ Tạo bảng OrderDetail
CREATE TABLE OrderDetail(
    odID INT AUTO_INCREMENT PRIMARY KEY,
    oID INT,
    pID INT,
    odQTY INT,
    FOREIGN KEY (oID) REFERENCES `Order`(oID),
    FOREIGN KEY (pID) REFERENCES Product(pID)
);

-- 6️ Thêm dữ liệu vào Customer
INSERT INTO Customer(cID, Name, cAge) VALUES
(1, 'Minh Quan', 10),
(2, 'Ngoc Oanh', 20),
(3, 'Hong Ha', 50);

-- 7️ Thêm dữ liệu vào Product
INSERT INTO Product(pID, pName, pPrice) VALUES
(1, 'May Giat', 3),
(2, 'Tu Lanh', 5),
(3, 'Dieu Hoa', 7),
(4, 'Quat', 1),
(5, 'Bep Dien', 2);

-- 8 Thêm dữ liệu vào Order
INSERT INTO `Order`(oID, cID, oDate, oTotalPrice) VALUES
(1, 1, '2006-03-21', NULL),
(2, 2, '2006-03-23', NULL),
(3, 1, '2006-03-16', NULL);

-- 9️⃣ Thêm dữ liệu vào OrderDetail
INSERT INTO OrderDetail(oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 3),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3);

-- ===============================
-- 10️ Truy vấn theo yêu cầu

-- a) Hiển thị oID, oDate, oPrice của tất cả các hóa đơn
SELECT O.oID, O.oDate, SUM(OD.odQTY * P.pPrice) AS oTotalPrice
FROM `Order` O
JOIN OrderDetail OD ON O.oID = OD.oID
JOIN Product P ON OD.pID = P.pID
GROUP BY O.oID, O.oDate;

-- b) Danh sách khách hàng đã mua hàng và sản phẩm họ mua
SELECT DISTINCT C.Name AS CustomerName, P.pName AS ProductName
FROM Customer C
JOIN `Order` O ON C.cID = O.cID
JOIN OrderDetail OD ON O.oID = OD.oID
JOIN Product P ON OD.pID = P.pID;

-- c) Tên khách hàng không mua sản phẩm nào
SELECT C.Name AS CustomerName
FROM Customer C
LEFT JOIN `Order` O ON C.cID = O.cID
WHERE O.oID IS NULL;

-- d) Mã hóa đơn, ngày bán và giá tiền từng hóa đơn
SELECT O.oID, O.oDate, SUM(OD.odQTY * P.pPrice) AS oTotalPrice
FROM `Order` O
JOIN OrderDetail OD ON O.oID = OD.oID
JOIN Product P ON OD.pID = P.pID
GROUP BY O.oID, O.oDate;
