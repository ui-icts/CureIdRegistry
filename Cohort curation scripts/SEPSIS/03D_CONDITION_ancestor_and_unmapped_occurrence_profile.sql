/*
Filename:
03D_CONDITION_ancestor_and_unmapped_occurrence_profile.sql

Purpose:
Generate a profile of condition occurrence prevalence, including both ancestor concepts and unmapped conditions, in the final cohort.

Description:
Condition occurrence counts are calculated per patient and are aggregated by ancestor concepts
for each condition concept present in the final OMOP Condition Occurrence table. Unmapped conditions
(those without ancestors) are also included. The `condition_source_value` is also included in the output.

Dependencies:
Requires a condition occurrence table, concept table, and concept_ancestor table in the specified schema.
*/

WITH condition_counts AS (
    SELECT
        COALESCE(ca.ancestor_concept_id, co.condition_concept_id) AS concept_id,
        COALESCE(ac.concept_name, sc.concept_name, co.condition_source_value) AS concept_name,
        co.condition_source_value,
        COUNT(DISTINCT co.person_id) AS unique_person_count,
        COUNT(*) / COUNT(DISTINCT co.person_id) AS mean_conditions_per_patient
    FROM
        omop_cdm.condition_occurrence co
	JOIN [Results].[Sepsis_Cohort] AS coh --joining to sepsis cohort
		on co.person_id=coh.person_id
    LEFT JOIN
       omop_cdm.concept_ancestor ca
        ON co.condition_concept_id = ca.descendant_concept_id
    LEFT JOIN
        omop_cdm.concept ac
        ON ca.ancestor_concept_id = ac.concept_id
    LEFT JOIN
        omop_cdm.concept sc
        ON co.condition_concept_id = sc.concept_id
    GROUP BY
        COALESCE(ca.ancestor_concept_id, co.condition_concept_id),
        COALESCE(ac.concept_name, sc.concept_name, co.condition_source_value),
        co.condition_source_value
),
total_person_count AS (
    SELECT
        COUNT(DISTINCT person_id) AS total_persons
    FROM
        [Results].[Sepsis_Cohort] --only looking at the total people from cohort
)
SELECT
    cc.concept_id,
    cc.concept_name,
    cc.condition_source_value,
    cc.unique_person_count,
	CAST(cc.unique_person_count AS DECIMAL(18,2)) / CAST(tpc.total_persons AS DECIMAL(18, 2)) * 100 AS percent_of_persons,
    cc.mean_conditions_per_patient
FROM
    condition_counts cc,
    total_person_count tpc
ORDER BY
    percent_of_persons DESC;

