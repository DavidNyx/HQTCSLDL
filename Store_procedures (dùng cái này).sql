﻿use DATH1
GO

--Thêm sản phẩm
CREATE PROC THEMSP
    @MASP CHAR(12),
    @MALOAI CHAR(12),
    @TENSP NVARCHAR(50),
    @MOTA NVARCHAR(250),
    @GIA FLOAT,
	@MADT CHAR(12),
    @MACN INT,
	@SL INT
AS
BEGIN
    BEGIN TRAN
        IF EXISTS (SELECT * FROM QUANLYKHO WHERE QUANLYKHO.MASP = @MASP AND QUANLYKHO.MACN = @MACN AND dbo.QUANLYKHO.MADOITAC = @MADT)
		BEGIN
			ROLLBACK
			RAISERROR(N'Sản phẩm đã tồn tại trong kho này', 16, 1)
		END
        IF NOT EXISTS(SELECT * FROM dbo.LOAISP WHERE MALOAI = @MALOAI)
        BEGIN
            ROLLBACK TRAN
            raiserror(N'Loại sản phẩm không tồn tại', 16, 1)
        END
        INSERT dbo.SANPHAM
        (
            MASP,
            MALOAI,
            TENSP,
            MOTA,
            GIA
        )
        VALUES
        (   @MASP,   -- MASP - char(12)
            @MALOAI,   -- MALOAI - char(12)
            @TENSP, -- TENSP - nvarchar(50)
            @MOTA, -- MOTA - nvarchar(250)
            @GIA  -- GIA - float
        )
		INSERT dbo.QUANLYKHO
        (
			MADOITAC,
			MACN,
            MASP,
			SLSP
        )
        VALUES
        (   @MADT,   -- MASP - char(12)
            @MACN,   -- MALOAI - char(12)
            @MASP, -- TENSP - nvarchar(50)
            1  -- SLSP - float
        )
    COMMIT TRAN
END
go



--cap nhat san pham
CREATE PROC CAPNHATSP
    @MASP CHAR(12),
    @MALOAI CHAR(12),
    @TENSP NVARCHAR(50),
    @MOTA NVARCHAR(250),
    @GIA FLOAT
AS
BEGIN
    BEGIN TRAN
        IF NOT EXISTS(SELECT * FROM dbo.SANPHAM WHERE MASP = @MASP)
        BEGIN
            ROLLBACK TRAN
            raiserror(N'Sản phẩm không tồn tại', 16, 1)
        END
        UPDATE dbo.SANPHAM
		SET MALOAI = @MALOAI, TENSP = @TENSP, MOTA = @MOTA, GIA = @GIA
		WHERE MASP = @MASP
		WAITFOR DELAY '00:00:05'
		IF NOT EXISTS(SELECT * FROM dbo.LOAISP WHERE MALOAI = @MALOAI)
        BEGIN
            ROLLBACK TRAN
            raiserror(N'Loại sản phẩm không tồn tại', 16, 1)
        END
    COMMIT TRAN
END
GO

--xoa san pham
CREATE PROC XOASP
    @MASP CHAR(12),
	@MADT CHAR(12)
AS
BEGIN
    BEGIN TRAN
        IF NOT EXISTS(SELECT * FROM dbo.SANPHAM WHERE MASP = @MASP)
        BEGIN
            ROLLBACK TRAN
            raiserror(N'Sản phẩm không tồn tại', 16, 1)
        END
		DELETE dbo.QUANLYKHO WHERE dbo.QUANLYKHO.MASP = @MASP AND dbo.QUANLYKHO.MADOITAC = @MADT
        DELETE dbo.SANPHAM WHERE MASP = @MASP
    COMMIT TRAN
END
GO


--update số lượng

CREATE PROC UPDATE_SOLUONG
	@MADT CHAR(12),
    @MACN INT,
    @MASP CHAR(12),
    @LUONG_TANG INT
AS
BEGIN
	BEGIN TRAN
		IF NOT EXISTS (SELECT * FROM QUANLYKHO WHERE QUANLYKHO.MASP = @MASP AND QUANLYKHO.MACN = @MACN AND dbo.QUANLYKHO.MADOITAC = @MADT)
		BEGIN
			ROLLBACK
			RAISERROR(N'Sản phẩm không tồn tại trong kho này', 16, 1)
		END
    UPDATE dbo.QUANLYKHO
    SET SLSP = SLSP + @LUONG_TANG
    WHERE MACN = @MACN AND MASP = @MASP AND MADOITAC = @MADT
	DECLARE @SLSP INT
	SET @SLSP = (SELECT dbo.QUANLYKHO.SLSP FROM QUANLYKHO WHERE QUANLYKHO.MASP = @MASP AND QUANLYKHO.MACN = @MACN AND dbo.QUANLYKHO.MADOITAC = @MADT)
	WAITFOR DELAY '00:00:05'
	IF @SLSP < 0
	BEGIN
		ROLLBACK
		RAISERROR(N'Nhập sai số lượng tăng',16,1)
		RETURN
	END
	COMMIT TRAN
END
GO

--cập nhật đơn hàng
CREATE PROC UPDATE_DONHANG
	@MADH CHAR(12),
	@QTVC NVARCHAR(100)
AS
BEGIN
	BEGIN TRAN
		IF NOT EXISTS (SELECT TAIXE.CMND FROM TAIXE, DONHANG WHERE DONHANG.CMND = TAIXE.CMND AND DONHANG.MADH = @MADH)
		BEGIN
			ROLLBACK
			raiserror(N'Đơn hàng chưa có người nhận', 16, 1)
		END
		IF NOT EXISTS (SELECT * FROM DONHANG WHERE DONHANG.MADH = @MADH)
		BEGIN 
			ROLLBACK
			raiserror(N'Đơn hàng không tồn tại', 16, 1)
        END
		DECLARE @TINHTRANG NVARCHAR(100)
		SET @TINHTRANG = (SELECT DONHANG.QTVC FROM DONHANG WHERE DONHANG.MADH = @MADH)
		IF @TINHTRANG = N'Hoàn tất'
		BEGIN
			ROLLBACK
			raiserror(N'Đã hoàn thành đơn hàng, không thể cập nhật', 16, 1)
		END
		UPDATE dbo.DONHANG
		SET DONHANG.QTVC = @QTVC
		WHERE DONHANG.MADH = @MADH
	COMMIT TRAN
END
GO

--tài xế xem đơn hàng lân cận
CREATE PROC VIEW_DONHANG
	@CMND CHAR(12)
AS
BEGIN
	BEGIN TRAN
		IF NOT EXISTS (SELECT * FROM TAIXE WHERE TAIXE.CMND = @CMND)
		BEGIN 
			ROLLBACK
			RAISERROR(N'Tài xế không tồn tại', 16, 1)
        END
		declare @KV NVARCHAR(100)
		SET @KV = (SELECT TAIXE.KHUVUCHD FROM TAIXE where taixe.CMND = @CMND)
		SELECT * FROM DONHANG, KHACHHANG WHERE CHARINDEX(@KV, KHACHHANG.DIACHIKH) > 0 and DONHANG.MAKH = KHACHHANG.MAKH and donhang.QTVC NOT LIKE N'Hoàn tất'
	COMMIT TRAN
END
GO

--khách hàng xem danh sách đối tác (NOTEEEEEE)
CREATE PROC KHVIEW_DOITAC
	@MADOITAC CHAR(12)
AS
BEGIN
	BEGIN TRAN
		IF NOT EXISTS (SELECT * FROM DOITAC WHERE DOITAC.MADOITAC = @MADOITAC)
		BEGIN
			ROLLBACK
			RAISERROR(N'Đối tác không tồn tại', 16, 1)
		END
		SELECT * FROM HOPDONG WHERE HOPDONG.MADOITAC = @MADOITAC AND DATEDIFF(day, GETDATE(), HOPDONG.TGHIEULUC) > 0
	COMMIT TRAN
END
GO



--Theo dõi đơn hàng
-- khách hàng
CREATE PROC FOLLOW_DONHANG_KH
	@ID CHAR(12),
	@MADH CHAR(12)
AS 
BEGIN
	BEGIN TRAN
		IF EXISTS (SELECT * FROM DONHANG, KHACHHANG WHERE DONHANG.MAKH = @ID AND KHACHHANG.MAKH = @ID) --nếu là khách hàng
		BEGIN
			SELECT ghinhan.masp, GHINHAN.SL, sanpham.gia from sanpham, donhang, ghinhan where ghinhan.masp = sanpham.masp AND DONHANG.MAKH = @ID AND GHINHAN.MADH = @MADH
		END
		ELSE
		BEGIN
			ROLLBACK
			RAISERROR(N'Bạn không phải khách hàng, bạn không có quyền coi thông tin này', 16, 1)
		END
	COMMIT TRAN
END
GO

--tài xế
--coi thông tin những đơn hàng mình tiếp nhận (coi địa chỉ KD để biết nơi chạy đến lấy hàng)
CREATE PROC FOLLOW_DONHANG_TX
	@ID CHAR(12)
AS 
BEGIN
	BEGIN TRAN
		IF EXISTS (SELECT * FROM DONHANG, TAIXE WHERE DONHANG.CMND = @ID AND TAIXE.CMND = @ID) --nếu là tài xế
		BEGIN
			SELECT donhang.MADH, donhang.QTVC ,DOITAC.DIACHIKD FROM DOITAC, DONHANG WHERE DONHANG.MADOITAC = DOITAC.MADOITAC AND DONHANG.CMND = @ID
		END
		ELSE
		BEGIN
			ROLLBACK
			RAISERROR(N'Bạn không phải tài xế, bạn không có quyền coi thông tin này', 16, 1)
		END
	COMMIT TRAN
END
GO



--mua sản phẩm
CREATE PROC INSERT_DONHANG
	@MADH CHAR(12),
	@MADT CHAR(12),
	@MAKH CHAR(12),
	@HTTHANHTOAN NVARCHAR(20)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS(SELECT*FROM dbo.DONHANG WHERE MADH = @MADH)
	BEGIN
		ROLLBACK TRAN
		RAISERROR(N'Đơn hàng đã tồn tại.', 16, 1)
	END
	IF NOT EXISTS(SELECT*FROM dbo.DOITAC WHERE MADOITAC = @MADT)
	BEGIN
		ROLLBACK TRAN
		RAISERROR(N'Đối tác không tồn tại.', 16, 1)
	END
	IF NOT EXISTS(SELECT*FROM dbo.KHACHHANG WHERE MAKH = @MAKH)
	BEGIN
		ROLLBACK TRAN
		RAISERROR(N'Khách hàng không tồn tại.', 16, 1)
	END
	INSERT dbo.DONHANG
	(
	    MADH,
	    MADOITAC,
	    MAKH,
		SLSP,
		PHISP,
	    HTTHANHTOAN
	)
	VALUES
	(   @MADH,   -- MADH - char(12)
	    @MADT,   -- MADOITAC - char(12)
	    @MAKH,   -- MAKH - char(12)
		0,
		0,
	    @HTTHANHTOAN  -- HTTHANHTOAN - nvarchar(20)
	    )
	COMMIT TRAN
END
GO

CREATE PROC INSERT_GHINHAN
	@MADH CHAR(12),
	@MASP CHAR(12),
	@SOLUONG INT
AS
BEGIN
	BEGIN TRAN
	IF NOT EXISTS(SELECT*FROM dbo.DONHANG WHERE MADH = @MADH)
	BEGIN
		ROLLBACK TRAN
		RAISERROR(N'Đơn hàng không tồn tại.', 16, 1)
	END
	IF NOT EXISTS(SELECT*FROM dbo.SANPHAM WHERE MASP = @MASP)
	BEGIN
		ROLLBACK TRAN
		RAISERROR(N'Sản phẩm không tồn tại.', 16, 1)
	END

	INSERT dbo.GHINHAN
	(
	    MASP,
	    MADH,
	    SL
	)
	VALUES
	(   @MASP,  -- MASP - char(12)
	    @MADH,  -- MADH - char(12)
	    @SOLUONG -- SL - int
	    )

	DECLARE @GIA FLOAT
	SET @GIA = (SELECT GIA FROM dbo.SANPHAM WHERE MASP = @MASP)

	UPDATE dbo.DONHANG
	SET SLSP = SLSP + @SOLUONG, PHISP = PHISP + @SOLUONG * @GIA
	WHERE MADH = @MADH

	DECLARE @TONKHO INT
	SET @TONKHO = (SELECT SLSP FROM dbo.QUANLYKHO WHERE MACN = (SELECT MIN(MACN) FROM dbo.QUANLYKHO WHERE  dbo.QUANLYKHO.MASP = @MASP AND dbo.QUANLYKHO.MADOITAC = @MADH AND dbo.QUANLYKHO.SLSP > @SOLUONG)
	AND dbo.QUANLYKHO.MADOITAC = @MADH AND dbo.QUANLYKHO.MASP = @MASP)

	UPDATE dbo.QUANLYKHO
	SET SLSP = dbo.QUANLYKHO.SLSP - @SOLUONG
	FROM dbo.DONHANG
	WHERE MACN = (SELECT MIN(MACN) FROM dbo.QUANLYKHO WHERE  dbo.QUANLYKHO.MASP = @MASP AND dbo.QUANLYKHO.MADOITAC = dbo.DONHANG.MADOITAC AND dbo.QUANLYKHO.SLSP > @SOLUONG)
	AND dbo.DONHANG.MADH = @MADH AND dbo.QUANLYKHO.MADOITAC = dbo.DONHANG.MADOITAC AND dbo.QUANLYKHO.MASP = @MASP

	IF NOT EXISTS(SELECT dbo.QUANLYKHO.*FROM dbo.QUANLYKHO, dbo.DONHANG WHERE dbo.DONHANG.MADH = @MADH AND dbo.QUANLYKHO.MADOITAC = dbo.DONHANG.MADOITAC
	AND dbo.QUANLYKHO.MASP = @MASP AND dbo.QUANLYKHO.SLSP > @SOLUONG)
	BEGIN
		ROLLBACK TRAN
		RAISERROR(N'Số lượng hàng trong kho không đủ.', 16, 1)
		RETURN
	END
	COMMIT TRAN
END
GO

CREATE PROC XEMHD -- nhân viên xem hợp đồng còn hiệu lực của đối tác
	@MADT CHAR(12)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	BEGIN TRAN
		IF NOT EXISTS (SELECT * FROM DOITAC WHERE DOITAC.MADOITAC = @MADT)
		BEGIN
			ROLLBACK
			RAISERROR(N'Đối tác không tồn tại', 16, 1)
		END
		SELECT *
		FROM dbo.HOPDONG
		WHERE MADOITAC = @MADT AND TGHIEULUC > GETDATE()
	COMMIT TRAN
END
GO

CREATE PROC DANGKY
	@USER varCHAR(16),
	@PASS varCHAR(20),
	@ROLE nvarchar(16)
AS
BEGIN
	BEGIN TRAN
		IF EXISTS (SELECT USERNAME FROM TAIKHOAN WHERE USERNAME = @USER)
		BEGIN
			ROLLBACK
			RAISERROR(N'Tên tài khoản đã tồn tại', 16, 1)
		END
		INSERT TAIKHOAN (USERNAME, PASS, USER_ROLE)
			VALUES(@USER,@PASS,@ROLE)

	COMMIT TRAN
END
GO

CREATE PROC LAP_HOP_DONG
	@MADT CHAR(12),
	@MATHUE CHAR(12),
	@SOCNDK INT,
	@TGHIEULUC DATE
AS
BEGIN
	BEGIN TRAN
		IF EXISTS (SELECT MATHUE FROM HOPDONG WHERE MATHUE = @MATHUE)
		BEGIN
			ROLLBACK
			RAISERROR(N'Hợp đồng đã tồn tại',16,1)
		END
		INSERT HOPDONG (MADOITAC, MATHUE, SOCNDK, TGHIEULUC, PHANTRAMHOAHONG, PHIHOAHONG)
			VALUES (@MADT, @MATHUE, @SOCNDK, @TGHIEULUC, 0.1, 0)
	COMMIT TRAN
END
GO

CREATE PROC UPDATE_HOPDONG -- cap nhat hop dong
	@MADOITAC CHAR(12),
	@MATHUE CHAR(12),
	@DATE DATE,
	@HOAHONG FLOAT
AS
BEGIN
	BEGIN TRAN
		IF NOT EXISTS (SELECT * FROM DOITAC WHERE DOITAC.MADOITAC = @MADOITAC)
		BEGIN
			ROLLBACK
			RAISERROR(N'Đối tác không tồn tại', 16, 1)
		END
		DECLARE @HIEULUC DATE
		SET @HIEULUC = (SELECT TGHIEULUC FROM dbo.HOPDONG WHERE MADOITAC = @MADOITAC AND MATHUE = @MATHUE)
		UPDATE dbo.HOPDONG
		SET TGHIEULUC = @DATE, PHANTRAMHOAHONG = @HOAHONG
		WHERE MADOITAC = @MADOITAC AND MATHUE = @MATHUE

		IF @DATE < @HIEULUC
		BEGIN
			ROLLBACK
			RAISERROR(N'Ngày gia hạn trước thời gian hiệu lực',16,1)
			RETURN
		END
	COMMIT TRAN
END
GO




