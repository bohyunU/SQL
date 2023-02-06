

/*******************

�ڷ����� ���� Ȯ��(����� �Ŵ���)

by Calvin

	1. 2022�� �ڷ����� Ƽ�� ��� ��������
	2. Ƽ�Ϻ��� �����, �߼��� ��� �ʿ�
	3. ����Ȯ���� ���� workshop �Ϸ��� �ʿ�
	4. ��¥ DIFF�� �� �ܰ躰 ���� ����

*******************/


---- 1. Teleservice


--�ϴ� ���̺� �� �����������..

DROP TABLE BMW_DAT..TELE_2022

DECLARE  @SelectClause  VARCHAR(100)    = 'SELECT �����ȣ, [Ƽ�� �����], '
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

EXEC (@Query)  --����


/*
SELECT MIN([Ƽ�� �����]) -- 2021-12-28
  FROM BMW_DAT..TELE_2022

SELECT TABLE_NAME
  FROM BMW_DAT..TELE_2022
 GROUP
    BY TABLE_NAME
 ORDER
    BY 1
*/

--�߼��� üũ


SELECT *
  INTO #SEND
  FROM OPENDATASOURCE
('MICROSOFT.ACE.OLEDB.12.0','DATA SOURCE="D:\Upload\BMW\UPLOAD\�ڷ����� �Ⱓ_2022.XLSX";
USER ID=;PASSWORD=;EXTENDED PROPERTIES=EXCEL 12.0')...��¥$

SELECT *
  INTO #RANGE
  FROM OPENDATASOURCE
('MICROSOFT.ACE.OLEDB.12.0','DATA SOURCE="D:\Upload\BMW\UPLOAD\�ڷ����� �Ⱓ_2022.XLSX";
USER ID=;PASSWORD=;EXTENDED PROPERTIES=EXCEL 12.0')...���������Ⱓ$



--ALTER TABLE BMW_DAT..TELE_2022 DROP COLUMN SEND_DATE;



ALTER TABLE BMW_DAT..TELE_2022 ADD SEND_DATE DATE;
GO
UPDATE BMW_DAT..TELE_2022
   SET SEND_DATE = #SEND.�߼���
  FROM #SEND
 WHERE BMW_DAT..TELE_2022.TABLE_NAME = #SEND.����Ʈ������



SELECT SEND_DATE, COUNT(DISTINCT �����ȣ)
  FROM BMW_DAT..TELE_2022
 GROUP
    BY SEND_DATE
 ORDER
    BY 1



--WORKSHOP ���̱�

DROP TABLE #WS

SELECT *
  INTO #WS
  FROM
	(
	SELECT �����ȣ, �Ϸ���
	  FROM BMW_DAT..WORKSHOP_AS_SALES_22Y_INCLUDE_DT
	 WHERE ��ǰ���� IN ('BSI','�Ҹ�','����')
	 GROUP
	    BY �����ȣ, �Ϸ���

	UNION ALL

	SELECT �����ȣ, �Ϸ���
	  FROM BMW_DAT..WORKSHOP_AS_SALES_23Y_INCLUDE_DT
	 WHERE ��ǰ���� IN ('BSI','�Ҹ�','����')
	 GROUP
	    BY �����ȣ, �Ϸ���
	) A


----Ƽ�� ������� ���� ���� �׳� Ƽ�� ���� �Ⱓ�� ���缭 ���

UPDATE BMW_DAT..TELE_2022 
   SET [Ƽ�� �����] = DATEADD(DAY,-9,SEND_DATE)
 WHERE [Ƽ�� �����] IS NULL


----WS �������� TEMP�� ��� ���

SELECT A.�����ȣ, A.[Ƽ�� �����], A.TABLE_NAME, A.SEND_DATE, B.�Ϸ���
  INTO #TEMP
  FROM BMW_DAT..TELE_2022 A
LEFT JOIN #WS B
    ON A.�����ȣ = RIGHT(B.�����ȣ,7)


----�Ϸ��� ����ֱ�

ALTER TABLE BMW_DAT..TELE_2022 ADD �Ϸ��� DATE;
GO
UPDATE BMW_DAT..TELE_2022
   SET �Ϸ��� = TEMP.�Ϸ���
  FROM
	(
	SELECT SEND_DATE, �����ȣ, MIN(�Ϸ���) �Ϸ���
	  FROM #TEMP
	 WHERE [Ƽ�� �����] <= �Ϸ���
	 GROUP
		BY SEND_DATE, �����ȣ
	) TEMP
 WHERE BMW_DAT..TELE_2022.SEND_DATE = TEMP.SEND_DATE
   AND BMW_DAT..TELE_2022.�����ȣ = TEMP.�����ȣ


----DIFF ����ֱ�

ALTER TABLE BMW_DAT..TELE_2022 ADD DIFF INT;
GO
UPDATE BMW_DAT..TELE_2022
   SET DIFF = DATEDIFF(DAY, SEND_DATE, �Ϸ���)


---- #RANGE�� ���� ����

ALTER TABLE BMW_DAT..TELE_2022 ADD ���� VARCHAR(20);
GO
UPDATE BMW_DAT..TELE_2022
   SET ���� = CASE WHEN DIFF < 0 THEN '0�ܰ�'
	WHEN DIFF BETWEEN 0 AND #RANGE.[1�ܰ� �������� �Ⱓ] THEN '1�ܰ� ����'
	WHEN DIFF BETWEEN #RANGE.[1�ܰ� �������� �Ⱓ] AND #RANGE.[2�ܰ� �������� �Ⱓ] THEN '2�ܰ� ����'
	WHEN DIFF BETWEEN #RANGE.[2�ܰ� �������� �Ⱓ] AND #RANGE.[2�ܰ� �������� �Ⱓ]+14 THEN '3�ܰ� ����'
	WHEN DIFF BETWEEN #RANGE.[2�ܰ� �������� �Ⱓ]+14  AND (CASE WHEN #RANGE.[3�ܰ� �������� �Ⱓ] IS NULL THEN 56 ELSE #RANGE.[3�ܰ� �������� �Ⱓ] END) THEN '4�ܰ� ����'
	ELSE '�κ��̽��̿Ϸ�'
	END
  FROM #RANGE
  WHERE #RANGE.�߼��� = BMW_DAT..TELE_2022.SEND_DATE



--SELECT SEND_DATE
DELETE
  FROM BMW_DAT..TELESERVICE_FOR_DASHBOARD
 WHERE LEFT(SEND_DATE,6) >= '2022'			-- ������Ʈ�� �Ⱓ �����ؼ� ����� ����
/*
 GROUP
    BY SEND_DATE
*/

INSERT INTO BMW_DAT..TELESERVICE_FOR_DASHBOARD
SELECT �����ȣ,[Ƽ�� �����], TABLE_NAME, �Ϸ���, DIFF, SEND_DATE, ����
  FROM BMW_DAT..TELE_2022
 WHERE CONVERT(VARCHAR(4),SEND_DATE,112) >= '2022'	-- ������Ʈ�� �Ⱓ �����ؼ� ����� ����
 


----- 2. BSI ����

SELECT *
  INTO #WS
  FROM
	(
	SELECT �����ȣ, �Ϸ���
	  FROM BMW_DAT..WORKSHOP_AS_SALES_22Y_INCLUDE_DT
	 WHERE ��ǰ���� IN ('BSI','�Ҹ�','����')
	 GROUP
	    BY �����ȣ, �Ϸ���

	UNION ALL

	SELECT �����ȣ, �Ϸ���
	  FROM BMW_DAT..WORKSHOP_AS_SALES_23Y_INCLUDE_DT
	 WHERE ��ǰ���� IN ('BSI','�Ҹ�','����')
	 GROUP
	    BY �����ȣ, �Ϸ���
	) A

DROP TABLE #TEMP1


SELECT A.�����ȣ, A.[Ƽ�� ������], A.�߼ۿ�������, B.�Ϸ���
  INTO #TEMP1
  FROM BMW_DAT..BSI_EXPIRED_221006 A
LEFT JOIN #WS B
    ON A.�����ȣ = B.�����ȣ


ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 DROP COLUMN �Ϸ��� 

ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 ADD �Ϸ��� DATE;
GO
UPDATE BMW_DAT..BSI_EXPIRED_221006
   SET �Ϸ��� = TEMP.�Ϸ���
  FROM
	(
	SELECT �߼ۿ�������, �����ȣ, MIN(�Ϸ���) �Ϸ���
	  FROM #TEMP1
	 WHERE [Ƽ�� ������] <= �Ϸ���
	 GROUP
		BY �߼ۿ�������, �����ȣ
	) TEMP
 WHERE BMW_DAT..BSI_EXPIRED_221006.�߼ۿ������� = TEMP.�߼ۿ�������
   AND BMW_DAT..BSI_EXPIRED_221006.�����ȣ = TEMP.�����ȣ


ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 DROP COLUMN DIFF
ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 ADD DIFF INT;
GO
UPDATE BMW_DAT..BSI_EXPIRED_221006
   SET DIFF = DATEDIFF(DAY, �߼ۿ�������, �Ϸ���)

--

ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 DROP COLUMN ����
ALTER TABLE BMW_DAT..BSI_EXPIRED_221006 ADD ���� VARCHAR(20);
GO
UPDATE BMW_DAT..BSI_EXPIRED_221006
   SET ���� = CASE WHEN DIFF < 0 THEN '0����'
	WHEN DIFF BETWEEN 0 AND 6 THEN '1����'
	WHEN DIFF BETWEEN 7 AND 13 THEN '2����'
	WHEN DIFF BETWEEN 14 AND 27 THEN '3����'
	WHEN DIFF BETWEEN 28 AND 28+28 THEN '4����+'
	WHEN DIFF BETWEEN 56 AND 160 THEN '8��'
	END


SELECT CONVERT(DATE,�߼ۿ�������), ����, COUNT(DISTINCT CASE WHEN �Ϸ��� IS NOT NULL THEN �����ȣ END) 
  FROM BMW_DAT..BSI_EXPIRED_221006
 WHERE 1=1
   AND ���� = '4����+'
 GROUP
    BY �߼ۿ�������, ����
 ORDER
    BY 1,2



SELECT �߼ۿ�������, COUNT(DISTINCT �����ȣ)
  FROM BMW_DAT..BSI_EXPIRED_221006
 WHERE DIFF <= 56
 GROUP
    BY �߼ۿ�������
 ORDER
    BY 1

SELECT �߼ۿ�������, COUNT(DISTINCT �����ȣ)
  FROM BMW_DAT..BSI_EXPIRED_221006
 WHERE DIFF <= 140
 GROUP
    BY �߼ۿ�������
 ORDER
    BY 1

