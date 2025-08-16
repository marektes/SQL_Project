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

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
- Ne. Ačkoliv dlouhodobý trend mezd je rostoucí, analýza meziročních změn podle odvětví ukazuje 30 případů poklesu mzdy v mnoha různých odvětvích.
Nejvíce poklesů bylo zaznamenáno v roce 2013, kdy klesla mzda v 11 odvětvích. Následuje rok 2021 s poklesem v 5 odvětvích.
Největší absolutní pokles nastal v roce 2013 v peněžnictví a pojišťovnictví - pokles o 4 479 Kč. Druhý největší pokles nastal v roce 2020 v odvětví „Činnosti v oblasti nemovitostí“ - pokles o 2 141 Kč.

Objevují se poklesy soustředěné do „slabších“ let (zejména 2013 a částečně 2020–2021). Ve sledovaném období 2000-2021 byl zaznamenán pokles (roční) za jednotlivá odvětví v 30 případech - jedná se o 7,5 %. V 92,5 % případů tedy mzdy rostly. Celkový trend je však z dlouhodobého pohledu rostoucí. Poklesy mají charakter dočasných výkyvů. 


### 2. Kolik litrů mléka a kg chleba bylo možné koupit v prvním a posledním sledovaném roce?
- Prvním sledovaným rokem je rok 2006 a posledním 2018. V roce 2006 činila průměrná mzda v ČR 20 677 Kč a v roce 2018 32 485 Kč.
Cena chleba v roce 2006 činila 16,12 Kč za kilo a v roce 2018 24,24 Kč za kilo. Cena mléka v roce 2006 byla 14,44 Kč za litr a v roce 2018 19,82 Kč za litr. Z uvedených hodnot vyplývá, že v roce 2006 bylo možné za průměrnou mzdu pořídit 1 282 kg kmínového konzumního chleba nebo 1 432 litrů polotučného pasterovaného mléka. V roce 2018 bylo možné pořídit 1 340 kg chleba nebo 1 639 litrů mléka. V roce 2018 bylo možné pořídit si za průměrnou mzdu o 4,5 % více chleba než v roce 2006. V případě mléka jde o nárůst o 14,5 %.

### 3. Která potravina zdražuje nejpomaleji?
- U dvou druhů potravin lze sledovat pokles cen. Průměrný meziroční pokles za sledované období (2006-2018) činil u cukru 1,92 %. Druhou potravinou, u které lze pozorovat pokles, jsou rajská jablka červená kulatá. Průměrný meziroční pokles činil 0,74 %.
Všechny ostatní sledované potraviny zdražovaly. Nejméně zdražovaly banány žluté - průměrný meziroční nárůst byl 0,8 %. Pokud bychom tedy nevzali v potaz potraviny, u kterých cena klesala, tak nejpomaleji zdražovaly právě žluté banány.

### 4. Existuje rok, kdy byly ceny výrazně rychlejší než mzdy (více než o 10 %) ?
- Takový rok neexistuje. Největší zjištěný rozdíl je 6,6 % v roce 2013. Průměrná cena všech potravin v tomto roce vzrostla meziročně (ve srovnání s rokem 2012) o 5,1 %, kdežto průměrná mzda za všechny odvětví klesla meziročně o 1,5 %.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
- Souvislost mezi změnou HDP na jedné straně a změnou mezd a cen na straně druhé je nejednoznačná.
Např. v roce 2009 nastal výrazný pokles HDP, který byl ve stejném a následujícím roce doprovázen velmi nízkých růstem mezd a cen(ve stejném roce ceny dokonce výrazně poklesly).
Oproti tomu v roce 2012 byl pozorován mírný pokles úrovně HDP, který však byl doprovázen výrazným růstem cenové hladiny.
Je zřejmé, že do situace vstupují další zákonitosti, a cenová hladina a úroveň mezd není závislá pouze na hodnotě HDP.

U samotných cen potravin nelze pozorovat prakticky žádnou korelaci se změnou HDP. Změna HDP může částečně predikovat, jakým směrem se budou vyvíjet mzdy v následujícím roce až dvou. Sledované období v délce 12 let (2007-2018) však nepovažuji za dostatečné - nelze vyvodit jednoznačné závěry.