select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ����, SALARY ����
from cslee.TB_EMP
where position = '�븮';

select COUNT(*) from CSLEE.tb_emp;
select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ����, SALARY ����
from CSLEE.TB_EMP;

select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ��å, SALARY ����
from CSLEE.TB_EMP
where (ORG_CD = '08' OR ORG_CD = '09' OR ORG_CD = '10')
and position='���'
and SALARY >= 40000000
and SALARY <= 50000000;

select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ��å, SALARY ����
from CSLEE.TB_EMP
where ORG_CD IN ('08','09','10')
and position='���'
and SALARY BETWEEN 40000000 and 50000000;

select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ��å, SALARY ����
from CSLEE.TB_EMP
where SALARY BETWEEN 40000000 and 50000000;


select EMP_NAME, ORG_CD, position
from CSLEE.tb_emp
where ORG_CD in ('06','07')
and position in ('����','����');

select EMP_NAME, ORG_CD, POSITION
from CSLEE.tb_emp
where (ORG_CD,POSITION)
	in (('06','����'),('07','����'));
	
select EMP_NAME ����̸�, ORG_CD ���ڵ�, position ��å, ENT_DATE �Ի�����
from CSLEE.tb_emp
where EMP_NAME like '��%';

select EMP_NAME ����̸�, ORG_CD ���ڵ�, position ��å, ENT_DATE �Ի�����
from CSLEE.tb_emp
where EMP_NAME like '_��%';

select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ��å, GENDER ����
from cslee.TB_EMP
where GENDER = null;

select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ��å, GENDER ����
from cslee.TB_EMP
where GENDER is null;

select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ��å
from CSLEE.tb_emp
where ORG_CD = '10'
and not position = '����';

select EMP_NAME ����̸�, ORG_CD �Ҽ�, position ��å
from CSLEE.tb_emp
where ORG_CD is not null;




select ORG_CD �μ�, EMP_NAME ����̸�, ENT_DATE �Ի���
from CSLEE.TB_EMP
order by ORG_CD, ENT_DATE desc;

select EMP_NAME, ORG_CD
from CSLEE.TB_EMP
order by EMP_NAME ASC, EMP_NO asc, EMP_NO desc;

select EMP_NAME ����̸�, EMP_NO �����ȣ, ORG_CD �μ��ڵ�
from CSLEE.TB_EMP
order by ����̸�, �����ȣ, �μ��ڵ� desc;

select EMP_NAME, EMP_NO, ORG_CD
from CSLEE.TB_EMP
order by 1 ASC, 2 asc, 3 desc;

select EMP_NAME ����̸�, EMP_NO �����ȣ, ORG_CD �μ��ڵ�
from CSLEE.TB_EMP
order by EMP_NAME, 2, �μ��ڵ� desc;
