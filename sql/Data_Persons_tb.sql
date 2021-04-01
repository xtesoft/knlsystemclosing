-- Drop table

-- DROP TABLE KNLSYSTEM_DB.dbo.Data_Persons_tb GO

CREATE TABLE KNLSYSTEM_DB.dbo.Data_Persons_tb (
	per_id int NULL,
	usr_id varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_employee_id varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_pcmail varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_unt_name varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_unt_id int NULL,
	user_dep_name varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_dep_id int NULL,
	user_type varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_entry_date datetime NULL,
	user_work_location varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_title varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_career_track varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_career_path varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	user_work_role varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	per_first_name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	per_middle_name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	per_last_name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	per_complete_name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	guest_title varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	guest_created_date datetime NULL,
	guest_email varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	guest_country_name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	guest_country_id int NULL,
	guest_institution_id int NULL,
	guest_institution_name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	guest_institution_type_id int NULL,
	guest_institution_type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	data_month int NULL,
	data_year int NULL,
	data_created_date datetime NULL
) GO
