--Primární tabulky--

select *
from czechia_payroll cp 

select *
from czechia_payroll_calculation cpc 

select *
from czechia_payroll_industry_branch cpib 

select *
from czechia_payroll_unit cpu 

select *
from czechia_payroll_value_type cpvt 

select *
from czechia_price cp 

select *
from czechia_price_category cpc 

--Číselníky sdílených informací o ČR--

select *
from czechia_region cr 

select *
from czechia_district cd 

--Dodatečné tabulky--

select *
from countries c 

select *
from economies e

--Vytvoření nové tabulky z "Czechia_Payroll" bez nerelevantních řádků (value_type_code = 316)

create table czechia_payroll_filtered as
select *
from czechia_payroll
where czechia_payroll.value_type_code = '5958'

select *
from czechia_payroll_filtered cpf 
