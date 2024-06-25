﻿USE TN_CSDLPT
GO
--ĐĂNG KÍ THI VỚI TÊN LỚP, TÊN MÔN HỌC...
CREATE PROC [dbo].[SP_DangKiThi]
@MAGV NCHAR(8),
@TENLOP NVARCHAR(50),
@TENMH NVARCHAR(50),
@TRINHDO NCHAR(1), --CODE CHECK
@NGAYTHI DATETIME,
@LAN SMALLINT,
@SOCAUTHI SMALLINT,--CODE CHECK
@THOIGIAN SMALLINT --CODE CHECK
AS
	DECLARE @MALOP NCHAR(15)
	DECLARE @MAMH NCHAR(5)
	SET @MALOP = (SELECT MALOP FROM LOP WHERE TENLOP=@TENLOP)
	SET @MAMH = (SELECT MAMH FROM MONHOC WHERE TENMH=@TENMH AND TrangThaiXoa=0)
	IF @NGAYTHI<GETDATE()
		RAISERROR('NGAY DANG KI THI KHONG HOP LE',16,1,50011)
	ELSE
	IF @LAN=1
		IF EXISTS(SELECT LAN FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
			RAISERROR('LOP HOC DA DUOC DANG KI THI CHO MON HOC NAY',16,1,50012)
		ELSE
			INSERT INTO GV_DANGKY(MAGV,MALOP,MAMH,TRINHDO,NGAYTHI,LAN,SOCAUTHI,THOIGIAN)
			VALUES (@MAGV,@MALOP,@MAMH,@TRINHDO,@NGAYTHI,@LAN,@SOCAUTHI,@THOIGIAN)
	ELSE --@LAN=2
		IF EXISTS(SELECT LAN FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
			IF (SELECT TOP 1 LAN FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH ORDER BY LAN DESC)=@LAN
				RAISERROR('LOP HOC DA DUOC DANG KI DU SO LAN THI CHO MON HOC NAY',16,1,50013)
			ELSE
				IF @NGAYTHI>(SELECT NGAYTHI FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
					IF @TRINHDO=(SELECT TRINHDO FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
						INSERT INTO GV_DANGKY(MAGV,MALOP,MAMH,TRINHDO,NGAYTHI,LAN,SOCAUTHI,THOIGIAN)
						VALUES (@MAGV,@MALOP,@MAMH,@TRINHDO,@NGAYTHI,@LAN,@SOCAUTHI,@THOIGIAN)
					ELSE RAISERROR('TRINH DO THI KHONG DONG NHAT',16,1,50016)
				ELSE RAISERROR('NGAY DANG KI THI LAN 2 PHAI SAU NGAY DANG KI THI DAU TIEN',16,1,50015)
		ELSE RAISERROR('LOP HOC CHUA DUOC DANG KI LAN THI DAU TIEN CHO MON HOC NAY',16,1,50014)
GO
--HOẶC ĐĂNG KÍ THI VỚI MÃ LỚP, MÃ MÔN HỌC...
CREATE PROC [dbo].[SP_DangKiThi]
@MAGV NCHAR(8),
@MALOP NCHAR(15),
@MAMH NCHAR(5),
@TRINHDO NCHAR(1), --CODE CHECK
@NGAYTHI DATETIME,
@LAN SMALLINT,
@SOCAUTHI SMALLINT,--CODE CHECK
@THOIGIAN SMALLINT --CODE CHECK
AS
	IF @NGAYTHI<GETDATE()
		RAISERROR('NGAY DANG KI THI KHONG HOP LE',16,1,50011)
	ELSE
	IF @LAN=1
		IF EXISTS(SELECT LAN FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
			RAISERROR('LOP HOC DA DUOC DANG KI THI CHO MON HOC NAY',16,1,50012)
		ELSE
			INSERT INTO GV_DANGKY(MAGV,MALOP,MAMH,TRINHDO,NGAYTHI,LAN,SOCAUTHI,THOIGIAN)
			VALUES (@MAGV,@MALOP,@MAMH,@TRINHDO,@NGAYTHI,@LAN,@SOCAUTHI,@THOIGIAN)
	ELSE --@LAN=2
		IF EXISTS(SELECT LAN FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
			IF (SELECT TOP 1 LAN FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH ORDER BY LAN DESC)=@LAN
				RAISERROR('LOP HOC DA DUOC DANG KI DU SO LAN THI CHO MON HOC NAY',16,1,50013)
			ELSE
				IF @NGAYTHI>(SELECT NGAYTHI FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
					IF @TRINHDO=(SELECT TRINHDO FROM GV_DANGKY WHERE MALOP=@MALOP AND MAMH=@MAMH)
						INSERT INTO GV_DANGKY(MAGV,MALOP,MAMH,TRINHDO,NGAYTHI,LAN,SOCAUTHI,THOIGIAN)
						VALUES (@MAGV,@MALOP,@MAMH,@TRINHDO,@NGAYTHI,@LAN,@SOCAUTHI,@THOIGIAN)
					ELSE RAISERROR('TRINH DO THI KHONG DONG NHAT',16,1,50016)
				ELSE RAISERROR('NGAY DANG KI THI LAN 2 PHAI SAU NGAY DANG KI THI DAU TIEN',16,1,50015)
		ELSE RAISERROR('LOP HOC CHUA DUOC DANG KI LAN THI DAU TIEN CHO MON HOC NAY',16,1,50014)
GO