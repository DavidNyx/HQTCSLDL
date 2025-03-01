﻿use DATH1

--Thêm sản phẩm
CREATE PROC THEMSP
    @MASP CHAR(12),
    @MALOAI CHAR(12),
    @TENSP NVARCHAR(50),
    @MOTA NVARCHAR(250),
    @GIA FLOAT,
	@MADT CHAR(12),
	@MACN CHAR(12)
AS
BEGIN
    BEGIN TRAN
        IF EXISTS(SELECT * FROM dbo.SANPHAM WHERE MASP = @MASP)
        BEGIN
            ROLLBACK TRAN
            raiserror(N'Sản phẩm đã tồn tại', 16, 1)
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
		INSERT dbo.quanlykho
        (
            MADOITAC,
            MACN,
			MASP,
            SLSP
        )
        VALUES
        (   @MADT,   -- MASP - char(12)
			@MACN,
            @MASP, -- MOTA - nvarchar(250)
            1  -- GIA - float
            )
    COMMIT TRAN
END

EXEC dbo.THEMSP @MASP = 'SP00012345', 
				@MALOAI = 'LSP000000001', -- char(12)
                @TENSP = N'Bánh pía', -- nvarchar(50)
                @MOTA = N'Thơm ngon.',  -- nvarchar(250)
                @GIA = 3100.0,    -- float
				@MADT = 'DT0000000002',
				@MACN = '2'
GO

select * from sanpham

--update số lượng
go
CREATE PROC UPDATE_SOLUONG
    @MACN CHAR(12),
    @MASP CHAR(12),
    @LUONG_TANG INT
AS
BEGIN
	BEGIN TRAN
		IF NOT EXISTS (SELECT * FROM QUANLYKHO WHERE QUANLYKHO.MASP = @MASP AND QUANLYKHO.MACN = @MACN)
		BEGIN
			ROLLBACK
			RAISERROR(N'Sản phẩm không tồn tại trong kho này', 16, 1)
		END
    UPDATE dbo.QUANLYKHO
    SET SLSP = SLSP + @LUONG_TANG
    WHERE MACN = @MACN AND MASP = @MASP
	COMMIT TRAN
END
GO

EXEC dbo.UPDATE_SOLUONG @MACN ='1',
	@MASP = 'SP0000000001',   -- char(12)
	@LUONG_TANG = 2

SELECT * FROM QUANLYKHO

--cập nhật đơn hàng
CREATE PROC UPDATE_DONHANG
	@MADH CHAR(12),
	@QTVC NVARCHAR(100)
AS
BEGIN
	BEGIN TRAN
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

EXEC dbo.UPDATE_DONHANG @MADH = 'HD0000000001', 
	@QTVC = N'Đang vận chuyển'

SELECT * FROM DONHANG

--tài xế xem đơn hàng
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
		declare @DC nvarchar(100)
		DECLARE cursorProduct CURSOR FOR
		SELECT KHACHHANG.DIACHIKH FROM KHACHHANG
		OPEN cursorProduct
		FETCH NEXT FROM cursorProduct     -- Đọc dòng đầu tiên
		INTO @DC
		WHILE @@FETCH_STATUS = 0          --vòng lặp WHILE khi đọc Cursor thành công
		BEGIN
			if CHARINDEX(@KV, @DC) != 0
			BEGIN
				SELECT DONHANG.MADH, DONHANG.MADOITAC, DONHANG.MAKH, DONHANG.PHISP, DONHANG.PHISP, DONHANG.PHIVC, DONHANG.QTVC, DONHANG.SLSP ,DONHANG.CMND, DONHANG.HTTHANHTOAN FROM DONHANG, KHACHHANG WHERE KHACHHANG.DIACHIKH = @DC and DONHANG.MAKH = KHACHHANG.MAKH
			END
			FETCH NEXT FROM cursorProduct -- Đọc dòng tiếp
			INTO @DC
		END
		CLOSE cursorProduct              -- Đóng Cursor
		DEALLOCATE cursorProduct  
	COMMIT TRAN
END
GO
EXEC dbo.VIEW_DONHANG @CMND = '000000000001'

--khách hàng xem danh sách đối tác
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
EXEC dbo.KHVIEW_DOITAC @MADOITAC = 'DT0000000001'

--nhân viên xem hợp đồng của đối tác
CREATE PROC NVVIEW_HOPDONG
	@MADOITAC CHAR(12),
	@DATE date
	@HOAHONG FLOAT
AS
BEGIN
	BEGIN TRAN
		IF NOT EXISTS (SELECT * FROM DOITAC WHERE DOITAC.MADOITAC = @MADOITAC)
		BEGIN
			ROLLBACK
			RAISERROR(N'Đối tác không tồn tại', 16, 1)
		END
		--đến đây khum bik làm hmu hmu
	COMMIT TRAN
END
--khong biet lam khuc cap nhat hmu hmu


--Theo dõi đơn hàng
CREATE PROC FOLLOW_DONHANG
	@ID CHAR(12)
AS 
BEGIN
	BEGIN TRAN
		IF EXISTS (SELECT * FROM DONHANG, TAIXE WHERE DONHANG.CMND = @ID AND TAIXE.CMND = @ID) --nếu là tài xế
		BEGIN
			SELECT distinct DOITAC.DIACHIKD FROM DOITAC, DONHANG WHERE DONHANG.MADOITAC = DOITAC.MADOITAC AND DONHANG.CMND = @ID
		END
		ELSE IF EXISTS (SELECT * FROM DONHANG, KHACHHANG WHERE DONHANG.MAKH = @ID AND KHACHHANG.MAKH = @ID) --nếu là khách hàng
		BEGIN
			SELECT * FROM DONHANG, GHINHAN WHERE DONHANG.MAKH = @ID AND GHINHAN.MADH = DONHANG.MADH
		END
		ELSE
		BEGIN
			ROLLBACK
			RAISERROR(N'Bạn không phải tài xế hoặc khách hàng, bạn không có quyền coi thông tin này', 16, 1)
		END
	COMMIT TRAN
END
GO

exec dbo.FOLLOW_DONHANG @ID = '000000000001'
exec dbo.FOLLOW_DONHANG @ID = 'KH0000000003'


        

