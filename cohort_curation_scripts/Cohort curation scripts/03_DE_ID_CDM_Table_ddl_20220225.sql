/*********************************************************************************
# Copyright 2017-11 Observational Health Data Sciences and Informatics
#
#
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
********************************************************************************/

/************************

 ####### #     # ####### ######      #####  ######  #     #           #######      #####
 #     # ##   ## #     # #     #    #     # #     # ##   ##    #    # #           #     #
 #     # # # # # #     # #     #    #       #     # # # # #    #    # #                 #
 #     # #  #  # #     # ######     #       #     # #  #  #    #    # ######       #####
 #     # #     # #     # #          #       #     # #     #    #    #       # ###       #
 #     # #     # #     # #          #     # #     # #     #     #  #  #     # ### #     #
 ####### #     # ####### #           #####  ######  #     #      ##    #####  ###  #####


sql server script to create OMOP common data model version 5.3

last revised: 14-June-2018

Authors:  Patrick Ryan, Christian Reich, Clair Blacketer


*************************/


USE JHM_OMOP_Test;

/******* TABLE CLEANUP *******/
DROP TABLE IF EXISTS [deident].[source_id_person];
DROP TABLE IF EXISTS [deident].[source_id_visit];
DROP TABLE IF EXISTS [deident].[condition_occurrence];
DROP TABLE IF EXISTS [deident].[death];
DROP TABLE IF EXISTS [deident].[drug_exposure];
DROP TABLE IF EXISTS [deident].[device_exposure];
DROP TABLE IF EXISTS [deident].[measurement];
DROP TABLE IF EXISTS [deident].[observation];
DROP TABLE IF EXISTS [deident].[person];
DROP TABLE IF EXISTS [deident].[procedure_occurrence];
DROP TABLE IF EXISTS [deident].[visit_occurrence];


/******* TABLE CREATION *******/

create table [deident].[source_id_person]
(sourceKey int not null,
id int not null,
date_shift int,
over_89_birth_year int)
;

create table [deident].[source_id_visit]
(sourceKey int not null,
new_id int not null)
;

--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.person
(
  person_id						        INTEGER	  	NOT NULL ,
  gender_concept_id				    INTEGER	  	NOT NULL ,
  year_of_birth					      INTEGER	  	NOT NULL ,
  month_of_birth				      INTEGER	  	NULL,
  day_of_birth					      INTEGER	  	NULL,
  birth_datetime				      DATETIME2	  NULL,
  race_concept_id				      INTEGER		  NOT NULL,
  ethnicity_concept_id			  INTEGER	  	NOT NULL,
  location_id					        INTEGER		  NULL,
  provider_id					        INTEGER		  NULL,
  care_site_id					      INTEGER		  NULL,
  person_source_value			    VARCHAR(50) NULL,
  gender_source_value			    VARCHAR(50) NULL,
  gender_source_concept_id	  INTEGER		  NULL,
  race_source_value				    VARCHAR(50) NULL,
  race_source_concept_id		  INTEGER		  NULL,
  ethnicity_source_value		  VARCHAR(50) NULL,
  ethnicity_source_concept_id	INTEGER		  NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.death
(
  person_id							  INTEGER			NOT NULL ,
  death_date							DATE			  NOT NULL ,
  death_datetime					DATETIME2		NULL ,
  death_type_concept_id   INTEGER			NOT NULL ,
  cause_concept_id			  INTEGER			NULL ,
  cause_source_value			VARCHAR(50)	NULL,
  cause_source_concept_id INTEGER			NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.visit_occurrence
(
  visit_occurrence_id			      INTEGER			NOT NULL ,
  person_id						          INTEGER			NOT NULL ,
  visit_concept_id				      INTEGER			NOT NULL ,
  visit_start_date				      DATE			  NOT NULL ,
  visit_start_datetime				  DATETIME2		NULL ,
  visit_end_date					      DATE			  NOT NULL ,
  visit_end_datetime					  DATETIME2		NULL ,
  visit_type_concept_id			    INTEGER			NOT NULL ,
  provider_id					          INTEGER			NULL,
  care_site_id					        INTEGER			NULL,
  visit_source_value				    VARCHAR(50)	NULL,
  visit_source_concept_id		    INTEGER			NULL ,
  admitting_source_concept_id	  INTEGER			NULL ,
  admitting_source_value		    VARCHAR(50)	NULL ,
  discharge_to_concept_id		    INTEGER   	NULL ,
  discharge_to_source_value		  VARCHAR(50)	NULL ,
  preceding_visit_occurrence_id	INTEGER			NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.procedure_occurrence
(
  procedure_occurrence_id		  INTEGER			NOT NULL ,
  person_id						        INTEGER			NOT NULL ,
  procedure_concept_id			  INTEGER			NOT NULL ,
  procedure_date				      DATE			  NOT NULL ,
  procedure_datetime			    DATETIME2		NULL ,
  procedure_type_concept_id		INTEGER			NOT NULL ,
  modifier_concept_id			    INTEGER			NULL ,
  quantity						        INTEGER			NULL ,
  provider_id					        INTEGER			NULL ,
  visit_occurrence_id			    INTEGER			NULL ,
  visit_detail_id             INTEGER     NULL ,
  procedure_source_value		  VARCHAR(50)	NULL ,
  procedure_source_concept_id	INTEGER			NULL ,
  modifier_source_value		   VARCHAR(50)	NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.drug_exposure
(
  drug_exposure_id				      INTEGER			  NOT NULL ,
  person_id						          INTEGER			  NOT NULL ,
  drug_concept_id				        INTEGER			  NOT NULL ,
  drug_exposure_start_date		  DATE			    NOT NULL ,
  drug_exposure_start_datetime  DATETIME2		  NULL ,
  drug_exposure_end_date		    DATE			    NOT NULL ,
  drug_exposure_end_datetime	  DATETIME2		  NULL ,
  verbatim_end_date				      DATE			    NULL ,
  drug_type_concept_id			    INTEGER			  NOT NULL ,
  stop_reason					          VARCHAR(20)		NULL ,
  refills						            INTEGER		  	NULL ,
  quantity						          FLOAT			    NULL ,
  days_supply					          INTEGER		  	NULL ,
  sig							              VARCHAR(MAX)	NULL ,
  route_concept_id				      INTEGER			  NULL ,
  lot_number					          VARCHAR(50)	  NULL ,
  provider_id					          INTEGER			  NULL ,
  visit_occurrence_id			      INTEGER			  NULL ,
  visit_detail_id               INTEGER       NULL ,
  drug_source_value				      VARCHAR(50)	  NULL ,
  drug_source_concept_id		    INTEGER			  NULL ,
  route_source_value			      VARCHAR(50)	  NULL ,
  dose_unit_source_value		    VARCHAR(50)	  NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.device_exposure
(
  device_exposure_id			        INTEGER		  	NOT NULL ,
  person_id						            INTEGER			  NOT NULL ,
  device_concept_id			        	INTEGER			  NOT NULL ,
  device_exposure_start_date	    DATE			    NOT NULL ,
  device_exposure_start_datetime  DATETIME2		  NULL ,
  device_exposure_end_date		    DATE			    NULL ,
  device_exposure_end_datetime    DATETIME2		  NULL ,
  device_type_concept_id		      INTEGER			  NOT NULL ,
  unique_device_id			        	VARCHAR(50)		NULL ,
  quantity						            INTEGER			  NULL ,
  provider_id					            INTEGER			  NULL ,
  visit_occurrence_id			        INTEGER			  NULL ,
  visit_detail_id                 INTEGER       NULL ,
  device_source_value			        VARCHAR(100)	NULL ,
  device_source_concept_id		    INTEGER			  NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.condition_occurrence
(
  condition_occurrence_id		    INTEGER			NOT NULL ,
  person_id						          INTEGER			NOT NULL ,
  condition_concept_id			    INTEGER			NOT NULL ,
  condition_start_date			    DATE			  NOT NULL ,
  condition_start_datetime		  DATETIME2		NULL ,
  condition_end_date			      DATE			  NULL ,
  condition_end_datetime		    DATETIME2		NULL ,
  condition_type_concept_id		  INTEGER			NOT NULL ,
  stop_reason					          VARCHAR(20)	NULL ,
  provider_id					          INTEGER			NULL ,
  visit_occurrence_id			      INTEGER			NULL ,
  visit_detail_id               INTEGER     NULL ,
  condition_source_value		    VARCHAR(50)	NULL ,
  condition_source_concept_id	  INTEGER			NULL ,
  condition_status_source_value	VARCHAR(50)	NULL ,
  condition_status_concept_id	  INTEGER			NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.measurement
(
  measurement_id				        INTEGER			NOT NULL ,
  person_id						          INTEGER			NOT NULL ,
  measurement_concept_id		    INTEGER			NOT NULL ,
  measurement_date				      DATE			  NOT NULL ,
  measurement_datetime			    DATETIME2		NULL ,
  measurement_time              VARCHAR(10) NULL,
  measurement_type_concept_id	  INTEGER			NOT NULL ,
  operator_concept_id			      INTEGER			NULL ,
  value_as_number				        FLOAT			  NULL ,
  value_as_concept_id			      INTEGER			NULL ,
  unit_concept_id				        INTEGER			NULL ,
  range_low					          	FLOAT			  NULL ,
  range_high					          FLOAT			  NULL ,
  provider_id					          INTEGER			NULL ,
  visit_occurrence_id			      INTEGER			NULL ,
  visit_detail_id               INTEGER     NULL ,
  measurement_source_value		  VARCHAR(50)	NULL ,
  measurement_source_concept_id	INTEGER			NULL ,
  unit_source_value				      VARCHAR(50)	NULL ,
  value_source_value			      VARCHAR(50)	NULL
)
;


--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE deident.observation
(
  observation_id					      INTEGER			NOT NULL ,
  person_id						          INTEGER			NOT NULL ,
  observation_concept_id			  INTEGER			NOT NULL ,
  observation_date				      DATE			  NOT NULL ,
  observation_datetime				  DATETIME2		NULL ,
  observation_type_concept_id	  INTEGER			NOT NULL ,
  value_as_number				        FLOAT			  NULL ,
  value_as_string				        VARCHAR(60)	NULL ,
  value_as_concept_id			      INTEGER			NULL ,
  qualifier_concept_id			    INTEGER			NULL ,
  unit_concept_id				        INTEGER			NULL ,
  provider_id					          INTEGER			NULL ,
  visit_occurrence_id			      INTEGER			NULL ,
  visit_detail_id               INTEGER     NULL ,
  observation_source_value		  VARCHAR(50)	NULL ,
  observation_source_concept_id	INTEGER			NULL ,
  unit_source_value				      VARCHAR(50)	NULL ,
  qualifier_source_value			  VARCHAR(50)	NULL
)
;


















