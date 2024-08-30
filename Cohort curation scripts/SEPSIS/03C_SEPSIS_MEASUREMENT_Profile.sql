/*
Filename:
03C_SEPSIS_measurement_profile.sql

Purpose:
Generate a profile of measurement prevalence in the final Sepsis cohort

Description:
Measurement counts are calculated per patient and are aggregated by parent concepts
for each measurement concept present in the final Sepsis OMOP Measurement table.

Dependencies:

*/

WITH measurement_counts AS (
    SELECT
        measurement_concept_id,
        measurement_source_value,
        COUNT(DISTINCT coh.person_id) AS unique_person_count,
        COUNT(*) / COUNT(DISTINCT coh.person_id) AS mean_measurements_per_patient
    FROM
        omop_cdm.measurement m
	JOIN [Results].[Sepsis_Cohort] AS coh --Looking only at the sepsis cohort
        ON
            m.person_id = coh.person_id
    GROUP BY
        measurement_concept_id,
        measurement_source_value
),
total_person_count AS (
    SELECT
        COUNT(DISTINCT person_id) AS total_persons
    FROM
        [Results].[Sepsis_Cohort] -- getting total # from cohort
)

SELECT
    mc.measurement_concept_id,
    mc.measurement_source_value,
    mc.unique_person_count,
    CAST(mc.unique_person_count AS DECIMAL(18,2)) / CAST(tpc.total_persons AS DECIMAL(18, 2)) * 100 AS percent_of_persons,
    mc.mean_measurements_per_patient
FROM
    measurement_counts mc,
    total_person_count tpc
ORDER BY
    percent_of_persons DESC;

