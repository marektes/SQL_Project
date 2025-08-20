
--Vytvoření nové tabulky z "Czechia_Payroll" bez nerelevantních řádků (value_type_code = 316).--
--Navíc byly vyfiltrovány pouze řádky s Calculation_code = 100. Lepší varianta pro pozdější srovnávání s cenami potravin,--
--protože bere v potaz částečné úvazky a nepřepočítává je na plné úvazky.--

create table czechia_payroll_filtered as
select *
from czechia_payroll
where czechia_payroll.value_type_code = '5958'
and calculation_code = 100;

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
