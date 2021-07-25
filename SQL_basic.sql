select EMP_NAME 사원이름, ORG_CD 소속, position 직무, SALARY 연봉
from cslee.TB_EMP
where position = '대리';

select COUNT(*) from CSLEE.tb_emp;
select EMP_NAME 사원이름, ORG_CD 소속, position 직무, SALARY 연봉
from CSLEE.TB_EMP;

select EMP_NAME 사원이름, ORG_CD 소속, position 직책, SALARY 연봉
from CSLEE.TB_EMP
where (ORG_CD = '08' OR ORG_CD = '09' OR ORG_CD = '10')
and position='사원'
and SALARY >= 40000000
and SALARY <= 50000000;

select EMP_NAME 사원이름, ORG_CD 소속, position 직책, SALARY 연봉
from CSLEE.TB_EMP
where ORG_CD IN ('08','09','10')
and position='사원'
and SALARY BETWEEN 40000000 and 50000000;

select EMP_NAME 사원이름, ORG_CD 소속, position 직책, SALARY 연봉
from CSLEE.TB_EMP
where SALARY BETWEEN 40000000 and 50000000;


select EMP_NAME, ORG_CD, position
from CSLEE.tb_emp
where ORG_CD in ('06','07')
and position in ('팀장','과장');

select EMP_NAME, ORG_CD, POSITION
from CSLEE.tb_emp
where (ORG_CD,POSITION)
	in (('06','팀장'),('07','과장'));
	
select EMP_NAME 사원이름, ORG_CD 팀코드, position 직책, ENT_DATE 입사일자
from CSLEE.tb_emp
where EMP_NAME like '김%';

select EMP_NAME 사원이름, ORG_CD 팀코드, position 직책, ENT_DATE 입사일자
from CSLEE.tb_emp
where EMP_NAME like '_승%';

select EMP_NAME 사원이름, ORG_CD 소속, position 직책, GENDER 성별
from cslee.TB_EMP
where GENDER = null;

select EMP_NAME 사원이름, ORG_CD 소속, position 직책, GENDER 성별
from cslee.TB_EMP
where GENDER is null;

select EMP_NAME 사원이름, ORG_CD 소속, position 직책
from CSLEE.tb_emp
where ORG_CD = '10'
and not position = '팀장';

select EMP_NAME 사원이름, ORG_CD 소속, position 직책
from CSLEE.tb_emp
where ORG_CD is not null;




select ORG_CD 부서, EMP_NAME 사원이름, ENT_DATE 입사일
from CSLEE.TB_EMP
order by ORG_CD, ENT_DATE desc;

select EMP_NAME, ORG_CD
from CSLEE.TB_EMP
order by EMP_NAME ASC, EMP_NO asc, EMP_NO desc;

select EMP_NAME 사원이름, EMP_NO 사원번호, ORG_CD 부서코드
from CSLEE.TB_EMP
order by 사원이름, 사원번호, 부서코드 desc;

select EMP_NAME, EMP_NO, ORG_CD
from CSLEE.TB_EMP
order by 1 ASC, 2 asc, 3 desc;

select EMP_NAME 사원이름, EMP_NO 사원번호, ORG_CD 부서코드
from CSLEE.TB_EMP
order by EMP_NAME, 2, 부서코드 desc;
