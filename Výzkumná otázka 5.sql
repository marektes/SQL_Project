
--5. Má výška HDP vliv na změny ve mzdách a cenách potravin?--
--Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?--
--Níže uvedený dotaz zobrazuje změnu HDP, průměrných mezd a průměrných cen potravin za jednotlivé roky--

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
