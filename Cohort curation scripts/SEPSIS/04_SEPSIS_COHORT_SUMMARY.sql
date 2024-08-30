/*
Filename:
04_SEPSIS_COHORT_SUMMARYv2.sql

Purpose:
Generate a summary report for YOUR SEPSIS COHORT, including demographics, age distribution, race, ethnicity, death information, 
and the median and IQR of the length of stay (LOS) for the first visit per person_id.

Description:
This script calculates summary statistics for key demographic variables (age at first visit date, race, ethnicity), 
details about death occurrences, including the list of cause_source_value and concept_name from the death table, 
and the median and IQR for the length of stay (LOS).  Per OMOP CDM documentation: "The Visit duration, or ‘length of stay’, is defined as VISIT_END_DATE - VISIT_START_DATE." 

Dependencies:
Requires person, visit_occurrence, concept, and death tables in the specified schema.
*/

WITH first_visit AS (
    SELECT
        person_id,
        MIN(visit_start_date) AS first_visit_date
    FROM
        results.Sepsis_Cohort vo 
    GROUP BY
        person_id
),
age_calculations AS (
    SELECT
        p.person_id,
        DATEDIFF(YEAR, p.birth_datetime, fv.first_visit_date) AS age_at_first_visit
    FROM
        results.Sepsis_Cohort p
    JOIN
        first_visit fv
        ON p.person_id = fv.person_id
),
demographics AS (
    SELECT DISTINCT  --Put distinct here to resemble our cohort count
        p.person_id,
        pp.gender_concept_id,
        pp.race_concept_id,
        pp.ethnicity_concept_id,
        p.birth_datetime,
        ac.age_at_first_visit
    FROM
        results.Sepsis_Cohort p
    JOIN
        age_calculations ac
        ON p.person_id = ac.person_id
	JOIN OMOP_Cdm.PERSON pp on pp.person_id=p.person_id
),
death_info AS (
    SELECT
        d.person_id,
        dd.death_date,
        dd.cause_source_value,
        c.concept_name AS cause_of_death
    FROM
        results.Sepsis_Cohort d
	JOIN omop_cdm.DEATH dd on dd.person_id = d.person_id
    LEFT JOIN
        omop_cdm.concept c
	
        ON dd.cause_concept_id = c.concept_id
),
los_calculations AS (
    SELECT
        fv.person_id,
        DATEDIFF(DAY, vo.visit_start_date, vo.visit_end_date) AS length_of_stay 
    FROM
        first_visit fv
    JOIN
        results.Sepsis_Cohort vo
        ON fv.person_id = vo.person_id
        AND fv.first_visit_date = vo.visit_start_date
),
age_summary AS (
  SELECT
    COUNT(*) AS total_patients,
    ROUND(AVG(age_at_first_visit), 2) AS mean_age,
	(select top 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age_at_first_visit) OVER () AS median_age from demographics) as median_age,
    MIN(age_at_first_visit) AS min_age,
    MAX(age_at_first_visit) AS max_age,
    ROUND(STDEV(age_at_first_visit), 2) AS age_sd
FROM
    demographics
),
race_summary AS (
    SELECT
        c.concept_name AS race,
        COUNT(race_concept_id) AS count,
        100.0 * COUNT(race_concept_id) / SUM(COUNT(race_concept_id)) OVER () AS [percent]
    FROM
        demographics d
    JOIN
        omop_cdm.concept c
        ON d.race_concept_id = c.concept_id
    GROUP BY
        c.concept_name
),

ethnicity_summary AS (
    SELECT
        c.concept_name AS ethnicity,
        COUNT(*) AS count,
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS [percent]
    FROM
        demographics d
    JOIN
        omop_cdm.concept c
        ON d.ethnicity_concept_id = c.concept_id
    GROUP BY
        c.concept_name
),
death_summary AS (
    SELECT
        COUNT(DISTINCT person_id) AS total_deaths, --used to be count(*)
        COUNT(DISTINCT cause_of_death) AS causes_of_death,
        COUNT(DISTINCT cause_source_value) AS causes_source_value
    FROM
        death_info
),
los_summary AS (
    SELECT top 1
		
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY length_of_stay) OVER () AS median_los,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY length_of_stay) OVER () AS iqr_los_25,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY length_of_stay) OVER () AS iqr_los_75
    FROM
        los_calculations
)

SELECT
    'Age Summary' AS section,
    CAST(NULL AS VARCHAR(255)) AS category,
    CAST(age_summary.mean_age AS VARCHAR(255)) AS mean,
    CAST(age_summary.median_age AS VARCHAR(255)) AS median,
    CAST(age_summary.min_age AS VARCHAR(255)) AS min,
    CAST(age_summary.max_age AS VARCHAR(255)) AS max,
    CAST(age_summary.age_sd AS VARCHAR(255)) AS standard_deviation,
    CAST(NULL AS VARCHAR(255)) AS count,
    CAST(NULL AS VARCHAR(255)) AS [percent]
FROM
    age_summary
UNION ALL
SELECT
    'Race Summary' AS section,
    race AS category,
    CAST(NULL AS VARCHAR(255)) AS mean,
    CAST(NULL AS VARCHAR(255)) AS median,
    CAST(NULL AS VARCHAR(255)) AS min,
    CAST(NULL AS VARCHAR(255)) AS max,
    CAST(NULL AS VARCHAR(255)) AS standard_deviation,
    CAST([count] AS VARCHAR(255)) AS count,
    CAST([percent] AS VARCHAR(255)) AS [percent]
FROM
    race_summary
UNION ALL
SELECT
    'Ethnicity Summary' AS section,
    ethnicity AS category,
    CAST(NULL AS VARCHAR(255)) AS mean,
    CAST(NULL AS VARCHAR(255)) AS median,
    CAST(NULL AS VARCHAR(255)) AS min,
    CAST(NULL AS VARCHAR(255)) AS max,
    CAST(NULL AS VARCHAR(255)) AS standard_deviation,
    CAST(count AS VARCHAR(255)) AS count,
    CAST([percent] AS VARCHAR(255)) AS [percent]
FROM
    ethnicity_summary
UNION ALL
SELECT
    'Death Summary' AS section,
    'Total Deaths' AS category,
    CAST(NULL AS VARCHAR(255)) AS mean,
    CAST(NULL AS VARCHAR(255)) AS median,
    CAST(NULL AS VARCHAR(255)) AS min,
    CAST(NULL AS VARCHAR(255)) AS max,
    CAST(NULL AS VARCHAR(255)) AS standard_deviation,
    CAST(total_deaths AS VARCHAR(255)) AS count,
    CAST(NULL AS VARCHAR(255)) AS [percent]
FROM
    death_summary
UNION ALL
SELECT
    'Death Summary' AS section,
    'Causes of Death' AS category,
    CAST(NULL AS VARCHAR(255)) AS mean,
    CAST(NULL AS VARCHAR(255)) AS median,
    CAST(NULL AS VARCHAR(255)) AS min,
    CAST(NULL AS VARCHAR(255)) AS max,
    CAST(NULL AS VARCHAR(255)) AS standard_deviation,
    CAST(causes_of_death AS VARCHAR(255)) AS count,
    CAST(NULL AS VARCHAR(255)) AS [percent]
FROM
    death_summary
UNION ALL
SELECT
    'Death Summary' AS section,
    'Cause Source Values' AS category,
    CAST(NULL AS VARCHAR(255)) AS mean,
    CAST(NULL AS VARCHAR(255)) AS median,
    CAST(NULL AS VARCHAR(255)) AS min,
    CAST(NULL AS VARCHAR(255)) AS max,
    CAST(NULL AS VARCHAR(255)) AS standard_deviation,
    CAST(causes_source_value AS VARCHAR(255)) AS count,
    CAST(NULL AS VARCHAR(255)) AS [percent]
FROM
    death_summary
UNION ALL
SELECT
    'Length of Stay Summary' AS section,
    'Median Length of Stay (days)' AS category,
    CAST(NULL AS VARCHAR(255)) AS mean,
    CAST(los_summary.median_los AS VARCHAR(255)) AS median,
    CAST(los_summary.iqr_los_25 AS VARCHAR(255)) AS min,
    CAST(los_summary.iqr_los_75 AS VARCHAR(255)) AS max,
    CAST(NULL AS VARCHAR(255)) AS standard_deviation,
    CAST(NULL AS VARCHAR(255)) AS count,
    CAST(NULL AS VARCHAR(255)) AS [percent]
FROM
    los_summary;

