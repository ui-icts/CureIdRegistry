/*
Filename:
03E_DEVICE_ancestor_and_unmapped_occurrence_profile.sql

Purpose:
Generate a profile of device occurrence prevalence, including both ancestor concepts and unmapped devices, in the final cohort.

Description:
Device occurrence counts are calculated per patient and are aggregated by ancestor concepts
for each device concept present in the final OMOP Device Exposure table. Unmapped devices
(those without ancestors) are also included. The `device_source_value` is also included in the output.

Dependencies:
Requires a device exposure table, concept table, and concept_ancestor table in the specified schema.
*/

WITH device_counts AS (
    SELECT
        COALESCE(ca.ancestor_concept_id, de.device_concept_id) AS concept_id,
        COALESCE(ac.concept_name, sc.concept_name, de.device_source_value) AS concept_name,
        de.device_source_value,
        COUNT(DISTINCT de.person_id) AS unique_person_count,
        COUNT(*) / COUNT(DISTINCT de.person_id) AS mean_devices_per_patient
    FROM
        omop_cdm.device_exposure de 
	JOIN [Results].[Sepsis_Cohort] AS coh --join to sepsis cohort
		on de.person_id=coh.person_id
    LEFT JOIN
        omop_cdm.concept_ancestor ca
        ON de.device_concept_id = ca.descendant_concept_id
    LEFT JOIN
        omop_cdm.concept ac
        ON ca.ancestor_concept_id = ac.concept_id
    LEFT JOIN
        omop_cdm.concept sc
        ON de.device_concept_id = sc.concept_id
    GROUP BY
        COALESCE(ca.ancestor_concept_id, de.device_concept_id),
        COALESCE(ac.concept_name, sc.concept_name, de.device_source_value),
        de.device_source_value
),
total_person_count AS (
    SELECT
        COUNT(DISTINCT person_id) AS total_persons
    FROM
         [Results].[Sepsis_Cohort] --only looking at the total people from cohort
) 
SELECT
    dc.concept_id,
    dc.concept_name,
    dc.device_source_value,
    dc.unique_person_count,
    CAST(dc.unique_person_count AS DECIMAL(18,2)) / CAST(tpc.total_persons AS DECIMAL(18, 2)) * 100 AS percent_of_persons,
    dc.mean_devices_per_patient
FROM
    device_counts dc,
    total_person_count tpc
ORDER BY
    percent_of_persons DESC;
