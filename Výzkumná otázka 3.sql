
--3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?--

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
