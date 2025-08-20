

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
