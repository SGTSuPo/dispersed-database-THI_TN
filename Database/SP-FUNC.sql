﻿USE TN_CSDLPT
GO
--CHỌN CƠ SỞ (TỪ SITE CHỦ)
CREATE VIEW Get_Subscribes
AS
	SELECT TENCS=PUBS.description, TENSERVER=subscriber_server
	 FROM sysmergepublications  PUBS, sysmergesubscriptions SUBS
	 WHERE PUBS.pubid = SUBS.pubid AND  publisher <> subscriber_server
GO
--LẤY THÔNG TIN TÀI KHOẢN TỪ LOGIN
CREATE PROC SP_Lay_Thong_Tin_Tu_Login @TENLOGIN NVARCHAR(100)
AS
	BEGIN
		DECLARE @UID INT
		DECLARE @UNAME VARCHAR(10)

		IF EXISTS(SELECT * FROM sys.sysusers WHERE sid = SUSER_SID(@TENLOGIN))
		BEGIN
			SELECT @UID=uid , @UNAME=NAME FROM sys.sysusers WHERE sid = SUSER_SID(@TENLOGIN)
			--NHÓM COSO & GIAOVIEN
			IF EXISTS(SELECT TEN FROM GIAOVIEN WHERE MAGV=@TENLOGIN)
				SELECT LOGINNAME= @UNAME, 
				   NGUOIDUNG = (SELECT HO+ ' '+TEN FROM GIAOVIEN WHERE MAGV=@UNAME), 
				   TENNHOM=NAME
				FROM sys.sysusers
				WHERE uid = (SELECT groupuid FROM sys.sysmembers WHERE memberuid=@UID)
			-- NHÓM TRUONG
			ELSE
				SELECT LOGINNAME= @UNAME, 
				   NGUOIDUNG = 'HOC VIEN',
				   TENNHOM=NAME
				FROM sys.sysusers
				WHERE UID = (SELECT groupuid FROM sys.sysmembers WHERE memberuid=@UID)
		END
		--NHÓM SINHVIEN
		ELSE IF EXISTS(SELECT MASV,PASSWORD FROM SINHVIEN WHERE MASV=@TENLOGIN)
		BEGIN
				SELECT LOGINNAME='SV', --TK LOGIN VÀO SERVER
					NGUOIDUNG = (SELECT HO+' '+TEN FROM SINHVIEN WHERE MASV=@TENLOGIN),
					TENNHOM=S.NAME --'SINHVIEN'
				-- vvv CÓ THỂ BỎ
				FROM sys.sysusers S
				WHERE S.UID = (SELECT groupuid FROM sys.sysmembers WHERE memberuid=(SELECT uid FROM sys.sysusers WHERE name='SV'))--USERNAME TRUY CẬP DB VỚI ROLE SINHVIEN
				-- ^^^	
		END
		ELSE RAISERROR('KHONG TIM THAY TEN DANG NHAP',16,1,50001)
	END

GO
--THÊM GIÁO VIÊN
ALTER PROC [dbo].[SP_ThemGiaoVien]
@MAGV nchar(8),
@HO NVARCHAR(50),
@TEN NVARCHAR(10),
@HOCVI NVARCHAR(40),
@MAKH nchar(8)
AS
if exists(select MAGV FROM GIAOVIEN WHERE MAGV=@MAGV) RAISERROR('DA TON TAI MA GIAO VIEN NAY',16,1,50002)
ELSE
	insert into GIAOVIEN (MAGV, HO, TEN, HOCVI, MAKH) 
	VALUES (@MAGV, @HO, @TEN, @HOCVI, @MAKH)
GO
--THÊM SINH VIÊN
ALTER PROC [dbo].[SP_ThemSinhVien]
@MASV nchar(8),
@HO NVARCHAR(50),
@TEN NVARCHAR(10),
@NGAYSINH date,
@DIACHI NVARCHAR(100),
@MALOP nchar(15),
@PASSWORD NVARCHAR(30)
AS
if exists(select MASV FROM SINHVIEN WHERE MASV=@MASV) RAISERROR('DA TON TAI MA SINH VIEN NAY',16,1,50006)
ELSE
insert into SINHVIEN (MASV, HO, TEN, NGAYSINH, DIACHI, MALOP, PASSWORD) 
VALUES (@MASV, @HO, @TEN, @NGAYSINH, @DIACHI, @MALOP, @PASSWORD)
GO
--THÊM MÔN HỌC
ALTER PROC [dbo].[SP_ThemMonHoc]
@MAMH nchar(5),
@TENMH NVARCHAR(50)
AS
if exists(select MAMH FROM MONHOC WHERE MAMH=@MAMH) RAISERROR('DA TON TAI MA MON HOC NAY',16,1,50005)
ELSE
insert into MONHOC(MAMH, TENMH) 
VALUES (@MAMH, @TENMH)
GO
--THÊM LỚP
ALTER PROC [dbo].[SP_ThemLop]
@MALOP nchar(8),
@TENLOP NVARCHAR(50),
@MAKH nchar(3)
AS
if exists(select MALOP FROM LOP WHERE MALOP=@MALOP) RAISERROR('DA TON TAI MA LOP NAY',16,1,50004)
ELSE
insert into LOP (MALOP, TENLOP, MAKH) 
VALUES (@MALOP, @TENLOP, @MAKH)
GO
--THÊM KHOA
ALTER PROC [dbo].[SP_ThemKhoa]
@MAKH nchar(8),
@TENKH NVARCHAR(50),
@MACS nchar(3)
AS
if exists(select MAKH FROM KHOA WHERE MAKH=@MAKH) RAISERROR('DA TON TAI MA KHOA NAY',16,1,50003)
ELSE
insert into KHOA (MAKH, TENKH, MACS) 
VALUES (@MAKH, @TENKH, @MACS)

GO
--SỬA GIÁO VIÊN
create PROC [dbo].[SP_SuaGiaoVien]
@MAGV nchar(8),
@HO NVARCHAR(50),
@TEN NVARCHAR(10),
@HOCVI NVARCHAR(40),
@MAKH nchar(8),
@TT INT
AS
BEGIN
	Update GIAOVIEN
	Set HO=@HO,TEN=@TEN,HOCVI=@HOCVI,MAKH=@MAKH,TrangThaiXoa=@TT
	where MAGV = @MAGV
END
GO
--SỬA KHOA
create PROC [dbo].[SP_SuaKhoa]
@MAKH nchar(8),
@TENKH NVARCHAR(50),
@MACS nchar(3)
AS
BEGIN
	Update KHOA
	Set TENKH=@TENKH,MACS=@MACS
	where MAKH = @MAKH
END
GO
--SỬA MÔN HỌC
create PROC [dbo].[SP_SuaMonHoc]
@MAMH nchar(5),
@TENMH NVARCHAR(50),
@TT INT
AS
BEGIN
	Update MONHOC
	Set TENMH=@TENMH,TrangThaiXoa=@TT
	where MAMH = @MAMH
END
GO
--SỬA LỚP
create PROC [dbo].[SP_SuaLop]
@MALOP nchar(8),
@TENLOP NVARCHAR(50),
@MAKH nchar(8)
AS
BEGIN
	Update LOP
	Set TENLOP=@TENLOP,MAKH=@MAKH
	where MALOP = @MALOP
END
GO
--SỬA SINH VIÊN
create PROC [dbo].[SP_SuaSinhVien]
@MASV nchar(8),
@HO NVARCHAR(50),
@TEN NVARCHAR(10),
@NGAYSINH date,
@DIACHI NVARCHAR(100),
@MALOP nchar(15),
@PASSWORD NVARCHAR(30),
@TT INT
AS
BEGIN
	Update SINHVIEN
	Set HO=@HO,TEN=@TEN, NGAYSINH=@NGAYSINH, DIACHI=@DIACHI, MALOP=@MALOP, PASSWORD=@PASSWORD,TrangThaiXoa=@TT
	where MASV = @MASV
END
GO
--XÓA KHOA
CREATE PROC [dbo].[SP_XoaKhoa]
@MAKH NCHAR(8)
AS
	DECLARE @LOG INT
	SET @LOG=0
	IF EXISTS(SELECT MAGV FROM GIAOVIEN WHERE MAKH=@MAKH) SET @LOG=50007
	ELSE IF EXISTS(SELECT MALOP FROM LOP WHERE MAKH=@MAKH) SET @LOG=50008
	ELSE DELETE FROM KHOA WHERE MAKH=@MAKH
	IF (@LOG<>0)
	RAISERROR('THONG TIN KHOA DANG CHUA DU LIEU',16,1,@LOG)
GO
--XÓA LỚP
CREATE PROC [dbo].[SP_XoaLop]
@MALOP NCHAR(8)
AS
	DECLARE @LOG INT
	SET @LOG=0
	IF EXISTS(SELECT MASV FROM SINHVIEN WHERE MALOP=@MALOP) SET @LOG=50009
	ELSE IF EXISTS(SELECT MALOP FROM GV_DANGKY WHERE MALOP=@MALOP) SET @LOG=50010
	ELSE DELETE FROM LOP WHERE MALOP=@MALOP
	IF (@LOG<>0)
	RAISERROR('THONG TIN LOP DANG CHUA DU LIEU',16,1,@LOG)
GO
--LẤY THÔNG TIN TOÀN BỘ TỪ (CƠ SỞ)
CREATE PROC [dbo].[SP_LayThongTinCacKhoa]
AS
	SELECT * FROM KHOA
GO
CREATE PROC [dbo].[SP_LayThongTinCacGiaoVien]
AS
	SELECT * FROM GIAOVIEN
GO
CREATE PROC [dbo].[SP_LayThongTinCacLop]
AS
	SELECT * FROM LOP
GO
CREATE PROC [dbo].[SP_LayThongTinCacMonHoc]
AS
	SELECT * FROM MONHOC
GO
CREATE PROC [dbo].[SP_LayThongTinCacSinhVien]
AS
	SELECT * FROM SINHVIEN
GO
--LẤY CÂU HỎI CỦA GIÁO VIÊN
CREATE PROC [dbo].[SP_LayCauHoi]
@MAGV NCHAR(8)
AS
	SELECT * FROM BODE WHERE MAGV=@MAGV
GO
--LẤY CÂU HỎI TRÌNH ĐỘ
CREATE PROC [dbo].[SP_LayCauHoiTrinhDo]
@TRINHDO nchar(1)
AS
	SELECT * FROM BODE WHERE TRINHDO=@TRINHDO
GO
--LẤY CÂU HỎI CÓ TRÌNH ĐỘ & SỐ CÂU
CREATE PROC [dbo].[SP_LayNCauHoiTrinhDo]
@TRINHDO nchar(1),
@N INT
AS
	SELECT TOP (@N) * FROM BODE WHERE TRINHDO=@TRINHDO
GO
--THÊM CÂU HỎI
CREATE PROC [dbo].[SP_ThemCauHoi]
@MAMH nchar(5),
@TRINHDO nchar(1),
@NOIDUNG ntext,
@A ntext,
@B ntext,
@C ntext,
@D ntext,
@DAPAN nchar(1),
@MAGV nchar(8)
AS
	INSERT INTO BODE(MAMH,TRINHDO,NOIDUNG,A,B,C,D,DAPAN,MAGV)
	VALUES (@MAMH,@TRINHDO,@NOIDUNG,@A,@B,@C,@D,@DAPAN,@MAGV)
GO
--SỬA CÂU HỎI
CREATE PROC [dbo].[SP_SuaCauHoi]
@CAUHOI INT,
@MAMH nchar(5),
@TRINHDO nchar(1),
@NOIDUNG ntext,
@A ntext,
@B ntext,
@C ntext,
@D ntext,
@DAPAN nchar(1)
AS
	UPDATE BODE
	SET MAMH=@MAMH,TRINHDO=@TRINHDO,NOIDUNG=@NOIDUNG,A=@A,B=@B,C=@C,D=@D,DAPAN=@DAPAN
	WHERE CAUHOI=@CAUHOI
GO
--XÓA CÂU HỎI
CREATE PROC [dbo].[SP_XoaCauHoi]
@CAUHOI INT
AS
	DELETE FROM BODE
	WHERE CAUHOI=@CAUHOI
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
--GHI ĐIỂM
CREATE PROC [dbo].[SP_GhiBangDiem]
@MASV NCHAR(8),
@MAMH NCHAR(5),
@LAN SMALLINT,
@DIEM FLOAT
AS
	INSERT INTO BANGDIEM(MASV,MAMH,LAN,NGAYTHI,DIEM)
	VALUES(@MASV,@MAMH,@LAN,GETDATE(),@DIEM)
GO