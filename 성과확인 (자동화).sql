

/*******************

텔레서비스 성과 확인

by Calvin

	1. 2022년 텔레서비스 티켓 모두 가져오기
	2. 티켓별로 등록일, 발송일 모두 필요
	3. 성과확인을 위해 workshop 완료일 필요
	4. 날짜 DIFF로 각 단계별 성과 측정

*******************/


---- 1. Teleservice


--일단 테이블 다 가져오기부터..

DROP TABLE BMW_DAT..TELE_2022

DECLARE  @SelectClause  VARCHAR(100)    = 'SELECT 차대번호, [티켓 등록일], '
        ,@Query         VARCHAR(MAX)    = ''
		,@NewColumn     VARCHAR(100)    = ' AS TABLE_NAME'
		,@First			VARCHAR(100)    = 'SELECT * INTO BMW_DAT..TELE_2022 FROM ('
		,@Last			VARCHAR(100)    = ') A'

USE BMW_DLD

SELECT @Query = @Query + @SelectClause  + CONVERT(VARCHAR(8),RIGHT(TABLE_NAME,8),112) + @NewColumn + ' FROM ' + TABLE_NAME + ' UNION ALL '
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'TELE_U_2ND_LIST_2022%';

SELECT @Query = 'USE BMW_DLD ' + @First + LEFT(@Query, LEN(@Query) - LEN(' UNION ALL ')) + @Last
--SELECT @Query

EXEC (@Query)  --실행


/*
SELECT MIN([티켓 등록일]) -- 2021-12-28
  FROM BMW_DAT..TELE_2022

SELECT TABLE_NAME
  FROM BMW_DAT..TELE_2022
 GROUP
    BY TABLE_NAME
 ORDER
    BY 1
*/

--발송일 체크


SELECT *
  INTO #SEND
  FROM OPENDATASOURCE
('MICROSOFT.ACE.OLEDB.12.0','DATA SOURCE="D:\Upload\BMW\UPLOAD\텔레서비스 기간_2022.XLSX";
USER ID=;PASSWORD=;EXTENDED PROPERTIES=EXCEL 12.0')...날짜$

SELECT *
  INTO #RANGE
  FROM OPENDATASOURCE
('MICROSOFT.ACE.OLEDB.12.0','DATA SOURCE="D:\Upload\BMW\UPLOAD\텔레서비스 기간_2022.XLSX";
USER ID=;PASSWORD=;EXTENDED PROPERTIES=EXCEL 12.0')...성과측정기간$



--ALTER TABLE BMW_DAT..TELE_2022 DROP COLUMN SEND_DATE;



ALTER TABLE BMW_DAT..TELE_2022 ADD SEND_DATE DATE;
GO
UPDATE BMW_DAT..TELE_2022
   SET SEND_DATE = #SEND.발송일
  FROM #SEND
 WHERE BMW_DAT..TELE_2022.TABLE_NAME = #SEND.리스트생성일



SELECT SEND_DATE, COUNT(DISTINCT 차대번호)
  FROM BMW_DAT..TELE_2022
 GROUP
    BY SEND_DATE
 ORDER
    BY 1



--WORKSHOP 붙이기

DROP TABLE #WS

SELECT *
  INTO #WS
  FROM
	(
	SELECT 차대번호, 완료일
	  FROM BMW_DAT..WORKSHOP_AS_SALES_22Y_INCLUDE_DT
	 WHERE 부품종류 IN ('BSI','소매','보증')
	 GROUP
	    BY 차대번호, 완료일

	UNION ALL

	SELECT 차대번호, 완료일
	  FROM BMW_DAT..WORKSHOP_AS_SALES_23Y_INCLUDE_DT
	 WHERE 부품종류 IN ('BSI','소매','보증')
	 GROUP
	    BY 차대번호, 완료일
	) A


----티켓 등록일이 없는 경우는 그냥 티켓 시작 기간에 맞춰서 찍기

UPDATE BMW_DAT..TELE_2022 
   SET [티켓 등록일] = DATEADD(DAY,-9,SEND_DATE)
 WHERE [티켓 등록일] IS NULL


----WS 찍으려고 TEMP에 잠시 담기

SELECT A.차대번호, A.[티켓 등록일], A.TABLE_NAME, A.SEND_DATE, B.완료일
  INTO #TEMP
  FROM BMW_DAT..TELE_2022 A
LEFT JOIN #WS B
    ON A.차대번호 = RIGHT(B.차대번호,7)


----완료일 찍어주기

ALTER TABLE BMW_DAT..TELE_2022 ADD 완료일 DATE;
GO
UPDATE BMW_DAT..TELE_2022
   SET 완료일 = TEMP.완료일
  FROM
	(
	SELECT SEND_DATE, 차대번호, MIN(완료일) 완료일
	  FROM #TEMP
	 WHERE [티켓 등록일] <= 완료일
	 GROUP
		BY SEND_DATE, 차대번호
	) TEMP
 WHERE BMW_DAT..TELE_2022.SEND_DATE = TEMP.SEND_DATE
   AND BMW_DAT..TELE_2022.차대번호 = TEMP.차대번호


----DIFF 찍어주기

ALTER TABLE BMW_DAT..TELE_2022 ADD DIFF INT;
GO
UPDATE BMW_DAT..TELE_2022
   SET DIFF = DATEDIFF(DAY, SEND_DATE, 완료일)


---- #RANGE로 성과 측정

ALTER TABLE BMW_DAT..TELE_2022 ADD 성과 VARCHAR(20);
GO
UPDATE BMW_DAT..TELE_2022
   SET 성과 = CASE WHEN DIFF < 0 THEN '0단계'
	WHEN DIFF BETWEEN 0 AND #RANGE.[1단계 성과측정 기간] THEN '1단계 성과'
	WHEN DIFF BETWEEN #RANGE.[1단계 성과측정 기간] AND #RANGE.[2단계 성과측정 기간] THEN '2단계 성과'
	WHEN DIFF BETWEEN #RANGE.[2단계 성과측정 기간] AND #RANGE.[2단계 성과측정 기간]+14 THEN '3단계 성과'
	WHEN DIFF BETWEEN #RANGE.[2단계 성과측정 기간]+14  AND (CASE WHEN #RANGE.[3단계 성과측정 기간] IS NULL THEN 56 ELSE #RANGE.[3단계 성과측정 기간] END) THEN '4단계 성과'
	ELSE '인보이스미완료'
	END
  FROM #RANGE
  WHERE #RANGE.발송일 = BMW_DAT..TELE_2022.SEND_DATE



--SELECT SEND_DATE
DELETE
  FROM BMW_DAT..TELESERVICE_FOR_DASHBOARD
 WHERE LEFT(SEND_DATE,6) >= '2022'			-- 업데이트할 기간 설정해서 지우고 삽입
/*
 GROUP
    BY SEND_DATE
*/

INSERT INTO BMW_DAT..TELESERVICE_FOR_DASHBOARD
SELECT 차대번호,[티켓 등록일], TABLE_NAME, 완료일, DIFF, SEND_DATE, 성과
  FROM BMW_DAT..TELE_2022
 WHERE CONVERT(VARCHAR(4),SEND_DATE,112) >= '2022'	-- 업데이트할 기간 설정해서 지우고 삽입
 


----- 2. BSI 만료

SELECT *
  INTO #WS
  FROM
	(
	SELECT 차대번호, 완료일
	  FROM BMW_DAT..WORKSHOP_AS_SALES_22Y_INCLUDE_DT
	 WHERE 부품종류 IN ('BSI','소매','보증')
	 GROUP
	    BY 차대번호, 완료일

	UNION ALL

	SELECT 차대번호, 완료일
	  FROM BMW_DAT..WORKSHOP_AS_SALES_23Y_INCLUDE_DT
	 WHERE 부품종류 IN ('BSI','소매','보증')
	 GROUP
	    BY 차대번호, 완료일
	) A

DROP TABLE #TEMP1


SELECT A.차대번호, A.[티켓 생성일], A.발송예정일자, B.완료일
  INTO #TEMP1
  FROM BMW_DAT..BSI_EXPIRED_221006 A
LEFT JOIN #WS B
    ON A.차대번호 = B.차대번호


ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 DROP COLUMN 완료일 

ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 ADD 완료일 DATE;
GO
UPDATE BMW_DAT..BSI_EXPIRED_221006
   SET 완료일 = TEMP.완료일
  FROM
	(
	SELECT 발송예정일자, 차대번호, MIN(완료일) 완료일
	  FROM #TEMP1
	 WHERE [티켓 생성일] <= 완료일
	 GROUP
		BY 발송예정일자, 차대번호
	) TEMP
 WHERE BMW_DAT..BSI_EXPIRED_221006.발송예정일자 = TEMP.발송예정일자
   AND BMW_DAT..BSI_EXPIRED_221006.차대번호 = TEMP.차대번호


ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 DROP COLUMN DIFF
ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 ADD DIFF INT;
GO
UPDATE BMW_DAT..BSI_EXPIRED_221006
   SET DIFF = DATEDIFF(DAY, 발송예정일자, 완료일)

--

ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 DROP COLUMN 성과
ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 ADD 성과 VARCHAR(20);
GO
UPDATE BMW_DAT..BSI_EXPIRED_221006
   SET 성과 = CASE WHEN DIFF < 0 THEN '0주차'
	WHEN DIFF BETWEEN 0 AND 6 THEN '1주차'
	WHEN DIFF BETWEEN 7 AND 13 THEN '2주차'
	WHEN DIFF BETWEEN 14 AND 27 THEN '3주차'
	WHEN DIFF BETWEEN 28 AND 28+28 THEN '4주차+'
	WHEN DIFF BETWEEN 56 AND 160 THEN '8주'
	END


SELECT CONVERT(DATE,발송예정일자), 성과, COUNT(DISTINCT CASE WHEN 완료일 IS NOT NULL THEN 차대번호 END) 
  FROM BMW_DAT..BSI_EXPIRED_221006
 WHERE 1=1
   AND 성과 = '4주차+'
 GROUP
    BY 발송예정일자, 성과
 ORDER
    BY 1,2



SELECT 발송예정일자, COUNT(DISTINCT 차대번호)
  FROM BMW_DAT..BSI_EXPIRED_221006
 WHERE DIFF <= 56
 GROUP
    BY 발송예정일자
 ORDER
    BY 1

SELECT 발송예정일자, COUNT(DISTINCT 차대번호)
  FROM BMW_DAT..BSI_EXPIRED_221006
 WHERE DIFF <= 140
 GROUP
    BY 발송예정일자
 ORDER
    BY 1

