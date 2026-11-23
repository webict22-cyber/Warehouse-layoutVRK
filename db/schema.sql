-- SQL Server
CREATE TABLE Slot(
  SlotId INT IDENTITY PRIMARY KEY,
  Warehouse NVARCHAR(10) NOT NULL,      -- WH1 = คลังประตู1, WH3 = โรง 3
  Zone NVARCHAR(10) NOT NULL,           -- TOP / BOTTOM / RIGHT / FLOOR
  Rack NVARCHAR(20) NOT NULL,           -- RM01..RM19 หรือรหัสช่องของโรง 3
  Position INT NOT NULL,                -- ลำดับช่องในแร็ค (ซ้าย->ขวา)
  Code NVARCHAR(40) NOT NULL UNIQUE,
  CapacityBags INT NOT NULL DEFAULT 40, -- ความจุโดยประมาณ ไว้ใช้ระบายสี
  SortOrder INT NOT NULL);
CREATE TABLE Stock(
  SlotId INT PRIMARY KEY REFERENCES Slot(SlotId),
  Resin NVARCHAR(100) NULL,             -- ชนิด/เกรดเม็ด (NULL = ว่าง)
  LotNo NVARCHAR(100) NULL,
  QtyBags DECIMAL(10,1) NULL,           -- NULL = ยังไม่ได้นับ
  UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  UpdatedBy NVARCHAR(50) NULL);
CREATE TABLE StockLog(
  LogId BIGINT IDENTITY PRIMARY KEY,
  SlotId INT NOT NULL REFERENCES Slot(SlotId),
  Resin NVARCHAR(100) NULL, LotNo NVARCHAR(100) NULL,
  QtyBefore DECIMAL(10,1) NULL, QtyAfter DECIMAL(10,1) NULL,
  ChangedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  ChangedBy NVARCHAR(50) NULL);
