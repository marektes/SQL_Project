
--1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?--

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
WHERE salary_diff > 0
ORDER BY industry_name, year;
