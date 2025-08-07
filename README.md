# SQL Projekt v rámci kurzu ve společnosti ENGETO

**Autor:** Marek Tesař  
**Cíl projektu:**  
Základní analýza vztahu mezd a cen potravin v ČR.

---

## Použité datové zdroje

- `czechia_payroll` – informace o mzdách v různých odvětvích
- `czechia_price` – týdenní ceny vybraných potravin
- `czechia_price_category` – názvy jednotlivých potravin
- `economies` – HDP, GINI index a populace evropských států
- Další pomocné číselníky: `czechia_region`, `czechia_district`, `czechia_payroll_industry_branch` atd.

---

## Postup a tvorba tabulek

### 1. Úprava dat o mzdách
- Vyfiltrovány pouze záznamy s typem hodnoty 5958 (průměrná hrubá mzda)
- Použit pouze `calculation_code = 100` (pro přesnější výpočty – zohledňuje i částečné úvazky)
- Vznikla tabulka `czechia_payroll_filtered`

### 2. Úprava dat o cenách
- Vyfiltrovány pouze záznamy s průměrnou cenou za celou ČR (`region_code IS NULL`)
- Data agregována podle roku
- Vznikla tabulka `czechia_price_filtered`
- Připojeny názvy potravin → `czechia_price_named`

### 3. Vytvoření primární tabulky
- Sloučení mezd a cen potravin podle roku
- Vypočten sloupec `quantity_affordable` (kolik jednotek dané potraviny bylo možné koupit za průměrnou mzdu)
- Vznikla tabulka:  
  `t_marek_tesar_project_sql_primary_final`

### 4. Vytvoření sekundární tabulky
- HDP, GINI a populace vybraných evropských zemí
- Vypočten HDP na obyvatele (`gdp_per_capita`)
- Vznikla tabulka:  
  `t_marek_tesar_project_sql_secondary_final`

---

## Výzkumné otázky

### 1. Rostou mzdy ve všech odvětvích?
- Odpověď: Většinou ano, ale vyskytlo se 30 případů poklesu.

### 2. Kolik litrů mléka a kg chleba bylo možné koupit v prvním a posledním sledovaném roce?
- Odpověď nalezena v tabulce `t_marek_tesar_project_sql_primary_final`.

### 3. Která potravina zdražuje nejpomaleji?
- Cukr – průměrný meziroční pokles ceny 1,92 %.

### 4. Existuje rok, kdy byly ceny výrazně rychlejší než mzdy (více než o 10 %) ?
- Ne, maximální zjištěný rozdíl byl cca 6,5 %.

### 5. Má HDP vliv na růst mezd a cen?
- Vliv je nepřímý a nejednoznačný. V některých letech růst či pokles HDP korespondoval s vývojem cen a mezd, v jiných nikoliv.