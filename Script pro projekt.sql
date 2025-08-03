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

--Výběr řádků s Calculation_code = 100. Lepší varianta pro pozdější srovnávání s cenami--
--potravin, protože bere v potaz částečné úvazky a nepřepočítává je na plné úvazky.--

select *
from czechia_payroll_filtered cpf
where cpf.calculation_code = 100
order by industry_branch_code, cpf.payroll_year 

---Úprava tabulky czechia_price. Vyfiltrování hodnot za celou ČR (region_code IS NULL) a zagregování cen na jednotlivé roky---

CREATE TABLE czechia_price_filtered AS
SELECT
    EXTRACT(YEAR FROM date_from)::INT AS price_year,
    category_code,
    AVG(value) AS avg_price
FROM czechia_price
WHERE region_code IS NULL
GROUP BY EXTRACT(YEAR FROM date_from), category_code
ORDER BY price_year, category_code;

