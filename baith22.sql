-- ==========================
-- BẢN SCRIPT: QuanLySinhVien
-- Mục đích: Tạo database, tạo bảng, chèn dữ liệu mẫu, cập nhật và các truy vấn kiểm tra.
-- Mình đã thêm chú thích (comment) từng dòng hoặc từng khối để giải thích rõ ý nghĩa và lý do.
-- Chạy toàn bộ file này trong MySQL Workbench.

-- ==========================
-- XÓA DATABASE NẾU TỒN TẠI
-- ==========================
-- DROP DATABASE IF EXISTS sẽ xóa database cũ (nếu có) để tránh lỗi khi tạo lại.
DROP DATABASE IF EXISTS QuanLySinhVien;

-- ==========================
-- TẠO DATABASE MỚI
-- ==========================
-- Tạo database mới và chọn database đó làm database hiện hành để các lệnh tiếp theo chạy trên DB này.
CREATE DATABASE QuanLySinhVien;
USE QuanLySinhVien; -- chuyển ngữ cảnh sang QuanLySinhVien

-- ==========================
-- 1. BẢNG LỚP HỌC (Class)
-- ==========================
-- Mô tả: lưu thông tin lớp học. ClassID là khóa chính tự tăng.
CREATE TABLE Class(
    ClassID INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Khóa chính, tự động tăng
    ClassName VARCHAR(60) NOT NULL,                  -- Tên lớp
    StartDate DATE NOT NULL,                         -- Ngày bắt đầu (chỉ ngày)
    Status BIT                                      -- Trạng thái (0: inactive, 1: active)
);

-- ==========================
-- 2. BẢNG SINH VIÊN (Student)
-- ==========================
-- Mô tả: lưu thông tin sinh viên. ClassID ở đây là khóa ngoại tham chiếu tới Class.
CREATE TABLE Student(
    StudentID INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Khóa chính
    StudentName VARCHAR(30) NOT NULL,                  -- Tên sinh viên
    Address VARCHAR(50),                               -- Địa chỉ (có thể NULL)
    Phone VARCHAR(20),                                 -- Số điện thoại (có thể NULL)
    Status BIT,                                        -- Trạng thái hoạt động
    ClassID INT NOT NULL,                              -- Khóa ngoại chỉ lớp hiện tại
    FOREIGN KEY (ClassID) REFERENCES Class (ClassID)   -- Ràng buộc FK -> Class
);

-- ==========================
-- 3. BẢNG MÔN HỌC (Subject)
-- ==========================
-- Mô tả: lưu thông tin môn học. Credit có ràng buộc CHECK >= 1.
-- Lưu ý: CHECK được thực thi kể từ MySQL 8.0.16; nếu dùng phiên bản cũ hơn, CHECK có thể bị bỏ qua.
CREATE TABLE Subject(
    SubId INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Khóa chính
    SubName VARCHAR(30) NOT NULL,                  -- Tên môn
    Credit TINYINT NOT NULL CHECK (Credit >= 1),   -- Số tín chỉ, tối thiểu 1
    Status BIT DEFAULT 1                           -- Trạng thái (mặc định 1 = active)
);

-- ==========================
-- 4. BẢNG ĐIỂM (Mark)
-- ==========================
-- Mô tả: lưu điểm sinh viên cho từng môn. Có Unique(SubId, StudentId) để tránh trùng bản ghi.
CREATE TABLE Mark(
    MarkId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,          -- Khóa chính cho bảng điểm (không bắt buộc nhưng tiện)
    SubId INT NOT NULL,                                      -- Khóa tham chiếu môn
    StudentId INT NOT NULL,                                  -- Khóa tham chiếu sinh viên
    Mark FLOAT DEFAULT 0 CHECK (Mark BETWEEN 0 AND 100),     -- Điểm (0..100)
    ExamTimes TINYINT DEFAULT 1,                             -- Số lần thi (mặc định 1)
    UNIQUE (SubId, StudentId),                              -- Mỗi sinh viên có duy nhất 1 điểm cho 1 môn
    FOREIGN KEY (SubId) REFERENCES Subject (SubId),         -- FK -> Subject
    FOREIGN KEY (StudentId) REFERENCES Student (StudentID)  -- FK -> Student
);

-- ==========================
-- INSERT DỮ LIỆU MẪU
-- ==========================
-- Thêm dữ liệu mẫu cho các bảng (dùng ID cố định để dễ kiểm tra). Nếu bạn muốn
-- để AUTO_INCREMENT tự tăng, có thể omit cột ID khi INSERT.

-- 1. Bảng Class
INSERT INTO Class (ClassID, ClassName, StartDate, Status)
VALUES (1, 'A1', '2008-12-20', 1),
       (2, 'A2', '2008-12-22', 1),
       (3, 'B3', '2008-11-05', 0);

-- 2. Bảng Student
-- Chú ý: ClassID phải tồn tại trong bảng Class (vì FK). Ở đây ClassID = 1,2 đã tồn tại.
INSERT INTO Student (StudentID, StudentName, Address, Phone, Status, ClassID)
VALUES (1, 'Hung', 'Ha Noi', '0912113113', 1, 1), -- ban đầu ClassID = 1
       (2, 'Hoa', 'Hai Phong', NULL, 1, 1),
       (3, 'Manh', 'HCM', '0123123123', 0, 2);

-- 3. Bảng Subject
INSERT INTO Subject (SubId, SubName, Credit, Status)
VALUES (1, 'CF', 5, 1),
       (2, 'C', 6, 1),
       (3, 'HDJ', 5, 1),
       (4, 'RDNMS', 10, 1);

-- 4. Bảng Mark
-- Chú ý: UNIQUE (SubId, StudentId) nên không được chèn 2 dòng có cùng SubId+StudentId.
INSERT INTO Mark (SubId, StudentID, Mark, ExamTimes)
VALUES (1, 1, 8, 1),   -- Sinh viên 1, môn 1, điểm 8
       (1, 2, 10, 2),  -- Sinh viên 2, môn 1, điểm 10 (lần thi 2)
       (2, 1, 12, 1);  -- Sinh viên 1, môn 2, điểm 12
-- Lưu ý: Mark = 12 nằm trong 0..100 (theo CHECK) nên hợp lệ. Nếu thang điểm 10 thì cần điều chỉnh CHECK.

-- ==========================
-- UPDATE AN TOÀN (Safe Update Mode OK)
-- ==========================
-- Cập nhật ClassID của Hùng dùng PRIMARY KEY StudentID
-- Luôn kèm WHERE dùng khóa chính hoặc điều kiện rõ ràng để tránh cập nhật nhầm nhiều bản ghi.
UPDATE Student
SET ClassID = 2
WHERE StudentID = 1; -- Chỉ cập nhật sinh viên có StudentID = 1

-- ==========================
-- CÁC TRUY VẤN KIỂM TRA (SELECT)
-- ==========================

-- 1. Danh sách tất cả sinh viên
-- SELECT * trả về toàn bộ cột. Dùng khi kiểm tra dữ liệu nhanh.
SELECT * FROM Student;

-- 2. Sinh viên đang hoạt động (Status = 1)
-- Chú ý: nếu bạn dùng BIT, giá trị có thể trả về là 0 hoặc 1.
SELECT * FROM Student
WHERE Status = 1;

-- 3. Môn học có Credit < 10
-- BETWEEN inclusive, ở đây dùng phép so sánh đơn giản
SELECT * FROM Subject
WHERE Credit < 10;

-- 4. Sinh viên cùng tên lớp (JOIN)
-- Giải thích:
--  FROM Student S     -> đặt alias S cho bảng Student
--  JOIN Class C ON S.ClassId = C.ClassID -> nối 2 bảng theo cột ClassID
--  SELECT S.StudentId, S.StudentName, C.ClassName -> chọn các cột cần hiển thị
SELECT S.StudentId, S.StudentName, C.ClassName
FROM Student S
JOIN Class C ON S.ClassId = C.ClassID;

-- 5. Sinh viên lớp A1 (lọc tiếp theo ClassName)
SELECT S.StudentId, S.StudentName, C.ClassName
FROM Student S
JOIN Class C ON S.ClassId = C.ClassID
WHERE C.ClassName = 'A1';

-- 6. Danh sách sinh viên học môn CF
-- Giải thích:
-- JOIN Mark M ON S.StudentId = M.StudentId -> lấy điểm của sinh viên
-- JOIN Subject Sub ON M.SubId = Sub.SubId   -> lấy thông tin môn
SELECT S.StudentId, S.StudentName, Sub.SubName, M.Mark
FROM Student S
JOIN Mark M ON S.StudentId = M.StudentId
JOIN Subject Sub ON M.SubId = Sub.SubId
WHERE Sub.SubName = 'CF';

-- 7. Sinh viên có tên bắt đầu bằng chữ 'H'
-- LIKE 'H%' tìm các chuỗi bắt đầu bằng H
SELECT * FROM Student
WHERE StudentName LIKE 'H%';

-- 8. Lớp học bắt đầu vào tháng 12
-- Hàm MONTH(StartDate) trả về số tháng từ 1..12
SELECT * FROM Class
WHERE MONTH(StartDate) = 12;

-- 9. Môn học có Credit từ 3 đến 5
-- BETWEEN a AND b tương đương >= a AND <= b
SELECT * FROM Subject
WHERE Credit BETWEEN 3 AND 5;

-- 10. Hiển thị StudentName, SubName, Mark
-- Sắp xếp theo Mark giảm dần, nếu trùng thì theo StudentName tăng dần
-- ORDER BY hỗ trợ nhiều cột, thứ tự xác định mức ưu tiên sắp xếp
SELECT S.StudentName, Sub.SubName, M.Mark
FROM Student S
JOIN Mark M ON S.StudentID = M.StudentID
JOIN Subject Sub ON M.SubId = Sub.SubId
ORDER BY M.Mark DESC, S.StudentName ASC;

-- 11. Đếm số lượng sinh viên theo Address
-- COUNT() là hàm tổng hợp, GROUP BY gom nhóm theo Address
SELECT Address, COUNT(StudentId) AS 'Số lượng sinh viên'
FROM Student
GROUP BY Address;

-- 12. Trung bình điểm (AVG) theo sinh viên
-- AVG(Mark) tính trung bình điểm của mỗi sinh viên (theo tất cả môn họ có trong Mark)
SELECT S.StudentId, S.StudentName, AVG(Mark) AS AvgMark
FROM Student S
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName;

-- 13. Lọc nhóm bằng HAVING: chỉ lấy sinh viên có AVG(Mark) > 15
-- WHERE không thể lọc theo AVG vì AVG là hàm tổng hợp trên nhóm
SELECT S.StudentId, S.StudentName, AVG(Mark) AS AvgMark
FROM Student S
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName
HAVING AVG(Mark) > 15;

-- 14. Sinh viên có AVG(Mark) cao nhất
-- Giải thích:
--  HAVING AVG(Mark) >= ALL (SELECT AVG(Mark) FROM Mark GROUP BY Mark.StudentId)
--  - subquery: lấy danh sách AVG(Mark) cho từng StudentId
--  - ALL (...) so sánh AVG(Mark) của từng nhóm với toàn bộ các giá trị trung bình đó
--  Kết quả là nhóm nào có AVG bằng giá trị lớn nhất sẽ được chọn
SELECT S.StudentId, S.StudentName, AVG(Mark) AS AvgMark
FROM Student S
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName
HAVING AVG(Mark) >= ALL (SELECT AVG(Mark) FROM Mark GROUP BY Mark.StudentId);

-- Hiển thị tất cả các môn học có Credit lớn nhất
SELECT * FROM Subject
WHERE Credit = (SELECT MAX(Credit) FROM Subject);

-- Hiển thị tất cả các môn học có Credit lớn nhất
SELECT * FROM Subject
WHERE Credit = (SELECT MAX(Credit) FROM Subject);

-- Hiển thị các thông tin môn học có điểm thi lớn nhất
SELECT Sub.SubId, Sub.SubName, Sub.Credit, Sub.Status, M.Mark
FROM Subject Sub
JOIN Mark M ON Sub.SubId = M.SubId
WHERE M.Mark = (SELECT MAX(Mark) FROM Mark);

-- Hiển thị các thông tin sinh viên và điểm trung bình của mỗi sinh viên, xếp hạng theo điểm giảm dần
SELECT S.StudentId, S.StudentName, S.Address, S.Phone, S.Status, S.ClassID,
       AVG(M.Mark) AS AvgMark
FROM Student S
JOIN Mark M ON S.StudentId = M.StudentId
GROUP BY S.StudentId, S.StudentName, S.Address, S.Phone, S.Status, S.ClassID
ORDER BY AvgMark DESC;
