﻿CREATE PROC UPDATE_HOPDONG
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
		WAITFOR DELAY '00:00:05'
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
SELECT * FROM dbo.HOPDONG
EXEC dbo.UPDATE_HOPDONG @MADOITAC = 'DT0000000001',       -- char(12)
                        @MATHUE = 'MT0000000001',         -- char(12)
                        @DATE = '2021-11-22', -- date
                        @HOAHONG = 6        -- float