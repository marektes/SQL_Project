
--4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?--

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
WHERE (price_growth_pct - salary_growth_pct) > 10;
