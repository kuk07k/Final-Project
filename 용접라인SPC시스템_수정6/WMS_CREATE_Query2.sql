USE [intouch_db]
GO

--각 테이블마다 블록지정해서 따로 실행해야함


 -- 로그테이블
CREATE TABLE [dbo].[LINELOGTbl](
	[LINE_NO] [float] NOT NULL,
	[PRODUCT_CODE] [varchar](22) NOT NULL,
	[CURRENTkA] [float] NOT NULL,
	[VOLT] [float] NOT NULL,
	[TIME] [float] NOT NULL,
	[COOLANT_TEMP] [float] NOT NULL,
	[PNEUMATIC] [float] NOT NULL,
	[HEAT] [float] NOT NULL,
	[ENERGI_COUNT] [float] NOT NULL,
	[WELD_SPOT] [float] NOT NULL,
	[DATE] [varchar](30) NOT NULL,
	[UPTIME] [float] NOT NULL,
	[PROD_QUANTITY] [float] NOT NULL,
	[DEFECTIVE_PROD] [float] NULL,
	[DRESSING_COUNT] [float] NULL,
	[REPLACE_COUNT] [float] NULL
) ON [PRIMARY]
GO


 -- 현재공정로그값테이블
CREATE TABLE [dbo].[CURRENT_LINE_VALUETbl](
	[LINE_NO] [int] NOT NULL,
	[PRODUCT_CODE] [varchar](22) NULL,
	[CURRENTkA] [float] NULL,
	[VOLT] [float] NULL,
	[TIME] [float] NULL,
	[COOLANT_TEMP] [float] NULL,
	[PNEUMATIC] [float] NULL,
	[HEAT] [float] NULL,
	[ENERGI_COUNT] [float] NULL,
	[WELD_SPOT] [float] NULL,
	[DATE] [varchar](30) NULL,
	[UPTIME] [float] NULL,
	[PROD_QUANTITY] [float] NULL,
	[DEFECTIVE_PROD] [float] NULL,
	[DRESSING_COUNT] [float] NULL,
	[REPLACE_COUNT] [float] NULL,
UNIQUE NONCLUSTERED 
(
	[LINE_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



-- 완성품 로그 테이블
CREATE TABLE [dbo].[WeldFinishedTbl](
	[LINE_NO] [int] NOT NULL,
	[PRODUCT_CODE] [varchar](22) NOT NULL,
	[CURRENTkA_AVG] [float] NOT NULL,
	[VOLT_AVG] [float] NOT NULL,
	[COOLANT_TEMP_AVG] [float] NOT NULL,
	[PNEUMATIC_AVG] [float] NOT NULL,
	[HEAT_AVG] [float] NOT NULL,
	[CREATE_DATE] [varchar](30) NOT NULL
) ON [PRIMARY]
GO

-- 라인 현재상황 값 업데이트 트리거
CREATE TRIGGER [dbo].[CurrentLineValueTblUpdate]
   ON  [dbo].[LINELOGTbl]
   AFTER INSERT

AS 
DECLARE	@LINE_NO int, @PRODUCT_CODE VARCHAR(22), @CURRENTkA float, @VOLT float, @TIME float, @COOLANT_TEMP float, @PNEUMATIC float, @HEAT float, 
	    @ENERGI_COUNT float, @WELD_SPOT float, @DATE VARCHAR(30), @UPTIME float, @PROD_QUANTITY float, @DEFECTIVE_PROD float, @DRESSING_COUNT float,
		@REPLACE_COUNT float	
DECLARE CLV_CUR CURSOR FOR

 SELECT C.LINE_NO, C.PRODUCT_CODE,CURRENTkA,C.VOLT, C.TIME, C.COOLANT_TEMP,
		C.PNEUMATIC, C.HEAT, C.ENERGI_COUNT, C.WELD_SPOT, C.DATE, C.UPTIME, C.PROD_QUANTITY, C.DEFECTIVE_PROD,
		C.DRESSING_COUNT, C.REPLACE_COUNT
   FROM	(SELECT ROW_NUMBER()OVER(PARTITION BY LINE_NO ORDER BY DATE DESC) AS RNUM,
		LINE_NO, PRODUCT_CODE, CURRENTkA, VOLT, TIME, COOLANT_TEMP,
		PNEUMATIC, HEAT, ENERGI_COUNT, WELD_SPOT, DATE, UPTIME, 
		PROD_QUANTITY, DEFECTIVE_PROD,DRESSING_COUNT, REPLACE_COUNT FROM LINELOGTbl)
		AS C
  WHERE C.RNUM = 1
   
OPEN CLV_CUR
FETCH NEXT FROM CLV_CUR INTO @LINE_NO, @PRODUCT_CODE, @CURRENTkA, @VOLT, @TIME, @COOLANT_TEMP, @PNEUMATIC, @HEAT, 
			   	             @ENERGI_COUNT, @WELD_SPOT, @DATE, @UPTIME, @PROD_QUANTITY, @DEFECTIVE_PROD, @DRESSING_COUNT,@REPLACE_COUNT
WHILE @@FETCH_STATUS = 0
BEGIN      
   IF NOT EXISTS (SELECT LINE_NO FROM CURRENT_LINE_VALUETbl WHERE LINE_NO = @LINE_NO)
   BEGIN
   INSERT INTO CURRENT_LINE_VALUETbl (LINE_NO, PRODUCT_CODE, CURRENTkA, VOLT, TIME, COOLANT_TEMP,
			   PNEUMATIC, HEAT, ENERGI_COUNT, WELD_SPOT, DATE, UPTIME, PROD_QUANTITY, DEFECTIVE_PROD,
			   DRESSING_COUNT, REPLACE_COUNT)
	    VALUES (@LINE_NO, @PRODUCT_CODE, @CURRENTkA, @VOLT, @TIME, @COOLANT_TEMP, 
	 		   @PNEUMATIC, @HEAT, @ENERGI_COUNT, @WELD_SPOT, @DATE, @UPTIME, @PROD_QUANTITY, @DEFECTIVE_PROD,
			   @DRESSING_COUNT, @REPLACE_COUNT)	
   END

   ELSE
   BEGIN
   UPDATE CURRENT_LINE_VALUETbl 
	  SET PRODUCT_CODE = @PRODUCT_CODE,
		  CURRENTkA = @CURRENTkA,
		  VOLT = @VOLT,
		  TIME = @TIME,
		  COOLANT_TEMP = @COOLANT_TEMP,
		  PNEUMATIC = @PNEUMATIC,
		  HEAT = @HEAT, 
		  ENERGI_COUNT = @ENERGI_COUNT, 
		  WELD_SPOT = @WELD_SPOT,
		  DATE = @DATE,
		  UPTIME = @UPTIME, 
		  PROD_QUANTITY = @PROD_QUANTITY, 
		  DEFECTIVE_PROD = @DEFECTIVE_PROD,
		  DRESSING_COUNT = @DRESSING_COUNT,
		  REPLACE_COUNT = @REPLACE_COUNT
	WHERE LINE_NO = @LINE_NO
	END
FETCH NEXT FROM CLV_CUR INTO @LINE_NO, @PRODUCT_CODE, @CURRENTkA, @VOLT, @TIME, @COOLANT_TEMP, @PNEUMATIC, @HEAT, 
			   	             @ENERGI_COUNT, @WELD_SPOT, @DATE, @UPTIME, @PROD_QUANTITY, @DEFECTIVE_PROD, @DRESSING_COUNT,@REPLACE_COUNT
END
CLOSE CLV_CUR
DEALLOCATE CLV_CUR


