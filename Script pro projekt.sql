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

--Úprava tabulky czechia_price. Vyfiltrování hodnot za celou ČR (region_code IS NULL) a zagregování cen na jednotlivé roky--

CREATE TABLE czechia_price_filtered AS
SELECT
    EXTRACT(YEAR FROM date_from)::INT AS price_year,
    category_code,
    AVG(value) AS avg_price
FROM czechia_price
WHERE region_code IS NULL
GROUP BY EXTRACT(YEAR FROM date_from), category_code
ORDER BY price_year, category_code;

--Přidání názvů potravin z tabulky czechia_price_kategory--

CREATE TABLE czechia_price_named AS
SELECT
    cpf.price_year AS year,
    cpc.name AS food_name,
    cpf.avg_price
FROM czechia_price_filtered cpf
JOIN czechia_price_category cpc
    ON cpf.category_code = cpc.code
ORDER BY cpf.price_year, cpc.name;

--Spojení mnou vytvořených (upravených) tabulek "Czechia_payroll_filtered" a "Czechia_price_named".
--Nevyužil jsem zde rozdělení na jednotlivé průmyslové odvětví (mzdy). Takto vytvoření tabulka je jednoduchá a velmi přehledná.--
--Velmi zajímavý je poslední sloupec, který uvádí, kolik kilo, litrů apod. každé potraviny si bylo teoreticky možno daný rok zakoupit.--


CREATE TABLE t_marek_tesar_project_SQL_primary_final AS
SELECT
    s.year,
    ROUND(s.avg_salary::numeric, 2) AS avg_salary,
    p.food_name,
    ROUND(p.avg_price::numeric, 2) AS avg_price,
    ROUND((s.avg_salary / NULLIF(p.avg_price, 0))::numeric, 2) AS quantity_affordable
FROM (
    SELECT
        payroll_year AS year,
        AVG(value) AS avg_salary
    FROM czechia_payroll_filtered
    GROUP BY payroll_year
) s
JOIN czechia_price_named p
    ON s.year = p.year
ORDER BY p.food_name, s.year;

select *
from t_marek_tesar_project_sql_primary_final

--V tomto kroku vytvořím sekundární tabulku s HDP, GINI koeficientem a populací dalších evropských států--
--Využiju k tomu data z tabulky economies. Jako poslední sloupec jsem přidal hodnotu HDP na hlavu (GDP per capita)--

CREATE TABLE t_marek_tesar_project_SQL_secondary_final AS
SELECT
    country,
    year,
    ROUND(gdp::numeric) AS gdp,
    ROUND(gini::numeric, 2) AS gini,
    population,
    ROUND((gdp / population)::numeric, 2) AS gdp_per_capita
FROM economies
WHERE country IN (
    'Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus',
    'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France',
    'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy',
    'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands',
    'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia',
    'Spain', 'Sweden'
)
AND year BETWEEN 2006 AND 2018
ORDER BY country, year;

select *
from t_marek_tesar_project_sql_secondary_final tmtpssf 


--1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?--
--Zpravidla rostou. Existuje však 30 výjimek, ve kterých došlo v daném odvětví k poklesu oproti předchozímu roku--

WITH payroll_annual_question1 AS (
    SELECT
        cpf.payroll_year AS year,
        pib.name AS industry_name,
        AVG(cpf.value) AS avg_salary
    FROM czechia_payroll_filtered cpf
    JOIN czechia_payroll_industry_branch pib
        ON cpf.industry_branch_code = pib.code
    GROUP BY cpf.payroll_year, pib.name
)
SELECT *
FROM (
    SELECT
        industry_name,
        year,
        avg_salary,
        LAG(avg_salary) OVER (PARTITION BY industry_name ORDER BY year) AS prev_year_salary,
        (avg_salary - LAG(avg_salary) OVER (PARTITION BY industry_name ORDER BY year)) AS salary_diff
    FROM payroll_annual_question1
) sub
WHERE salary_diff < 0
ORDER BY industry_name, year;

--2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?--
--Na otázku odpovídá vytvořená tabulka t_marek_tesar_project_sql_primary_final.--

--3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?--
--Nejpomalejší meziroční nárůst lze pozorovat u cukru. Reálně šlo dokonce o pokles. Průměrný meziroční pokles činil u cukru 1,92 %--

SELECT food_name, AVG(price_growth) AS avg_growth
FROM (
    SELECT
        food_name,
        (avg_price - LAG(avg_price) OVER (PARTITION BY food_name ORDER BY year))
        / NULLIF(LAG(avg_price) OVER (PARTITION BY food_name ORDER BY year), 0) AS price_growth
    FROM t_marek_tesar_project_SQL_primary_final
) sub
WHERE price_growth IS NOT NULL
GROUP BY food_name
ORDER BY avg_growth;

--4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?--
--Takový rok neexistuje. Dotaz níže nenajde žádný takový případ. Největší takto zjištěný rozdíl je 6,5 % v roce 2013--

SELECT *
FROM (
    SELECT
        year,
        100.0 * (AVG(avg_price) - LAG(AVG(avg_price)) OVER (ORDER BY year)) 
            / LAG(AVG(avg_price)) OVER (ORDER BY year) AS price_growth_pct,
        100.0 * (AVG(avg_salary) - LAG(AVG(avg_salary)) OVER (ORDER BY year)) 
            / LAG(AVG(avg_salary)) OVER (ORDER BY year) AS salary_growth_pct
    FROM t_marek_tesar_project_SQL_primary_final
    GROUP BY year
) sub
WHERE (price_growth_pct - salary_growth_pct) > 6;

--5. Má výška HDP vliv na změny ve mzdách a cenách potravin?--
--Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?--
--Níže uvedený dotaz zobrazuje změnu HDP, průměrných mezd a průměrných cen potravin za jednotlivé roky--
--Souvislost mezi změnou HDP na jedné straně a změnou mezd a cen na straně druhé je nejednoznačná--
--Např. v roce 2009 nastal výrazný pokles HDP, který byl ve stejném a následujícím roce doprovázen velmi nízkých růstem mezd a cen(ve stejném roce ceny dokonce výrazně poklesly)--
--Oproti tomu v roce 2012 byl pozorován mírný pokles úrovně HDP, který však byl doprovázen výrazným růstem cenové hladiny--
--Je zřejmé, že do situace vstupují další zákonitosti, a cenová hladina a úroveň mezd není závislá pouze na hodnotě HDP.

WITH base_data AS (
    SELECT
        g.year,
        ROUND(g.gdp::numeric) AS gdp,
        ROUND(AVG(t.avg_salary)::numeric, 2) AS avg_salary,
        ROUND(AVG(t.avg_price)::numeric, 2) AS avg_price,
        LAG(g.gdp) OVER (ORDER BY g.year) AS prev_gdp,
        LAG(AVG(t.avg_salary)) OVER (ORDER BY g.year) AS prev_salary,
        LAG(AVG(t.avg_price)) OVER (ORDER BY g.year) AS prev_price
    FROM economies g
    JOIN t_marek_tesar_project_sql_primary_final t ON g.year = t.year
    WHERE g.country = 'Czech Republic'
    GROUP BY g.year, g.gdp
)
SELECT
    year,
    gdp,
    avg_salary,
    avg_price,
    ROUND(((gdp - prev_gdp) / prev_gdp)::numeric * 100, 2) AS gdp_change_pct,
    ROUND(((avg_salary - prev_salary) / prev_salary)::numeric * 100, 2) AS salary_change_pct,
    ROUND(((avg_price - prev_price) / prev_price)::numeric * 100, 2) AS price_change_pct
FROM base_data
WHERE prev_gdp IS NOT NULL
ORDER BY year;