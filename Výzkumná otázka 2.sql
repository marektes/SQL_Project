
--2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?--

SELECT *
FROM t_marek_tesar_project_SQL_primary_final
WHERE food_name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
  AND year IN (
    (SELECT MIN(year) FROM t_marek_tesar_project_SQL_primary_final),
    (SELECT MAX(year) FROM t_marek_tesar_project_SQL_primary_final)
)
ORDER BY food_name, year;
