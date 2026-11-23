-- MySQL 8
CREATE DATABASE IF NOT EXISTS WarehouseLayout CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE WarehouseLayout;

CREATE TABLE Slot(
  SlotId INT AUTO_INCREMENT PRIMARY KEY,
  Warehouse VARCHAR(10) NOT NULL,       -- WH1 = คลังประตู1, WH3 = โรง 3
  Zone VARCHAR(10) NOT NULL,            -- TOP / BOTTOM / RIGHT / FLOOR
  Rack VARCHAR(20) NOT NULL,            -- RM01..RM19 หรือรหัสช่องของโรง 3
  Position INT NOT NULL,                -- ลำดับช่องในแร็ค (ซ้าย->ขวา)
  Code VARCHAR(40) NOT NULL UNIQUE,
  CapacityBags INT NOT NULL DEFAULT 40, -- ความจุโดยประมาณ ไว้ใช้ระบายสี
  SortOrder INT NOT NULL
) CHARACTER SET utf8mb4;

CREATE TABLE Stock(
  SlotId INT PRIMARY KEY,
  Resin VARCHAR(100) NULL,              -- ชนิด/เกรดเม็ด (NULL = ว่าง)
  LotNo VARCHAR(100) NULL,
  QtyBags DECIMAL(10,1) NULL,           -- NULL = ยังไม่ได้นับ
  UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UpdatedBy VARCHAR(50) NULL,
  FOREIGN KEY (SlotId) REFERENCES Slot(SlotId)
) CHARACTER SET utf8mb4;

CREATE TABLE StockLog(
  LogId BIGINT AUTO_INCREMENT PRIMARY KEY,
  SlotId INT NOT NULL,
  Resin VARCHAR(100) NULL, LotNo VARCHAR(100) NULL,
  QtyBefore DECIMAL(10,1) NULL, QtyAfter DECIMAL(10,1) NULL,
  ChangedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ChangedBy VARCHAR(50) NULL,
  FOREIGN KEY (SlotId) REFERENCES Slot(SlotId)
) CHARACTER SET utf8mb4;
