﻿use DATH1
GO

CREATE PROC UPDATE_DONHANG1
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


EXEC dbo.UPDATE_DONHANG1 @MADH = 'HD0000000001', 
	@QTVC = N'Đang vận chuyển'