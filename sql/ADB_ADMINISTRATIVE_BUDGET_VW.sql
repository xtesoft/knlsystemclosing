CREATE VIEW [dbo].[ADB_ADMINISTRATIVE_BUDGET_VW]
AS 
select 
    bio.bio_id as obligation_id,
    bio.yea_id_year as obligation_year,
    obligation_entry_type =
	case
		when bio.bio_entry_type = 'BIO_PLAN_ACTIVITY' then 'Plan Activity'
		when bio.bio_entry_type = 'BIO_ADMINISTRATIVE' then 'Administrative'
		else bio.bio_entry_type
	end,
    obligation_vendor =
    case 
     when (select top 1 per3.per_last_name+', '+ per3.per_first_name from Per_Person_tb per3, Fcl_Facilitator_tb fcl1 where per3.per_id = fcl1.per_id_person and bio.fcl_id_vendor = fcl1.fcl_id) is not null
     then (select top 1 per3.per_last_name+', '+ per3.per_first_name from Per_Person_tb per3, Fcl_Facilitator_tb fcl1 where per3.per_id = fcl1.per_id_person and bio.fcl_id_vendor = fcl1.fcl_id)
    else (select top 1 ins.ins_name from Ins_Institution_tb ins, Fcl_Facilitator_tb fcl2 where ins.ins_id = fcl2.ins_id_institution and bio.fcl_id_vendor = fcl2.fcl_id)
    end,
    consultant_id =
    case 
     when (select top 1 usr.usr_employee_id from Per_Person_tb per, Usr_User_tb usr, Fcl_Facilitator_tb fcl where per.per_id = fcl.per_id_person and bio.fcl_id_vendor = fcl.fcl_id and per.per_id = usr.per_id_person and usr.usr_active_flag = 1 and per.per_active_flag = 1) is not null
     then (select top 1 usr.usr_employee_id from Per_Person_tb per, Usr_User_tb usr, Fcl_Facilitator_tb fcl where per.per_id = fcl.per_id_person and bio.fcl_id_vendor = fcl.fcl_id and per.per_id = usr.per_id_person and usr.usr_active_flag = 1 and per.per_active_flag = 1)
    else 'N/A'
    end,
    adc.adc_code as obligation_account_code,
    adc.adc_name as obligation_account_name,
    bou.bou_code as obligation_org_unit_code,
    bio.bio_description as obligation_description,
    obligation_item_type =
	case
		when bio.bio_item_type = 'BIO_CMO' then 'CMO'
		when bio.bio_item_type = 'BIO_CONSULTANT_PO' then 'Consultant PO'
		when bio.bio_item_type = 'BIO_LETTER_OF_AGREEMENT' then 'Letter of Agreement'
		when bio.bio_item_type = 'BIO_OUTPUT_NUMBER' then 'Output Number'
		when bio.bio_item_type = 'BIO_PCARD' then 'PCard'
		when bio.bio_item_type = 'BIO_PROCUREMENT_PO' then 'Procurement PO'
		when bio.bio_item_type = 'BIO_REFERENCE' then 'Reference'
		when bio.bio_item_type = 'BIO_TA_NUMBER' then 'TA Number'
		else bio.bio_item_type
	end,
    bio.bio_item_type_value as obligation_item_value,
    CASE 
        when bio.bio_accounting_type = 'BIO_CREDIT' then (bio.bio_item_cost * -1)
        else bio.bio_item_cost 
    END as obligation_amount,
    ops.ops_activity_code as obligation_opus_code,
    bio.bio_entry_date as obligation_entry_date,
    (select top 1 per1.per_last_name+', '+ per1.per_first_name from Per_Person_tb per1 where per1.per_id = bio.per_creator_id) as obligation_creator, 
    bio.bio_last_updated_date as obligation_last_updated_date,
    (select top 1 per2.per_last_name+', '+ per2.per_first_name from Per_Person_tb per2 where per2.per_id = bio.per_id_updator) as obligation_last_updator, 
    --- EXECUTION
    bie.bie_id as execution_id,
    CASE 
        when bie.bie_accounting_type = 'BIE_CREDIT' then (bie.bie_item_cost * -1)
        else bie.bie_item_cost 
    END as execution_amount,
    bie.bie_invoice_date as execution_invoce_date,
    bie.bie_epay_flag as execution_epay_flag,
    bie.bie_description as execution_description,
    (select top 1 bip.kna_id from Bip_Budget_Item_Plan_Activity_tb bip where bip.bio_id  = bio.bio_id) as execution_plan_activity,
    (select top 1 dep.dep_name from Bip_Budget_Item_Plan_Activity_tb bip, Kna_Knl_Plan_Activity_tb kna, Kpd_Knl_Plan_Deliverable_tb kpd, Knd_Knl_Plan_Division_tb knd, Knp_Knl_Plan_Department_tb knp, Dep_Department_tb dep where bip.kna_id = kna.kna_id and bip.bio_id  = bio.bio_id and kna.kpd_id_deliverable = kpd.kpd_id and kpd.knd_id_division = knd.knd_id and knd.knp_id_plan_department = knp.knp_id and knp.dep_id_department = dep.dep_id) as execution_plan_activity_department,
    (select top 1 unt.unt_name from Bip_Budget_Item_Plan_Activity_tb bip, Kna_Knl_Plan_Activity_tb kna, Kpd_Knl_Plan_Deliverable_tb kpd, Knd_Knl_Plan_Division_tb knd, Unt_Unit_tb unt where bip.kna_id = kna.kna_id and bip.bio_id  = bio.bio_id and kna.kpd_id_deliverable = kpd.kpd_id and kpd.knd_id_division = knd.knd_id and knd.unt_id_unit = unt.unt_id) as execution_plan_activity_unit,
    (select top 1 case    when tag.tag_code = 'NEE' and kna.kna_selected_flag = 1 then 'Approved' when tag.tag_code = 'NEE' and kna.kna_selected_flag = 0 then 'Pending Approval' when (tag.tag_code = 'CON' or tag.tag_code = 'CON')  and kna.kna_approved_flag = 1 then 'Approved'   when (tag.tag_code = 'CON' or tag.tag_code = 'KCP')  and kna.kna_approved_flag = 0 then 'Pending Approval'   end as activity_status    from Kna_Knl_Plan_Activity_tb kna, Bip_Budget_Item_Plan_Activity_tb bip, Tag_Taxonomy_Group_tb tag, Kpd_Knl_Plan_Deliverable_tb kpd where kna.kna_id = bip.kna_id and kna.kpd_id_deliverable = kpd.kpd_id and kpd.tax_id_type = tag.tax_id_group_header and bip.bio_id = bio.bio_id) as execution_plan_activity_status,
    (select top 1 case    when tag.tag_code = 'NEE' and kna.kna_selected_flag = 1 then (select  top 1 isNull(sum(kpb.kpb_item_cost),0) from Kpb_Knl_Plan_Budget_tb kpb where kpb.kna_id = kna.kna_id) when tag.tag_code = 'NEE' and kna.kna_selected_flag = 0 then 0.00 when (tag.tag_code = 'CON' or tag.tag_code = 'KCP') and kna.kna_approved_flag = 1 then isNull(kna.kna_approved_amount,0) when (tag.tag_code = 'CON' or tag.tag_code = 'KCP') and kna.kna_approved_flag = 0 then 0.00 end as activity_status    from Kna_Knl_Plan_Activity_tb kna, Bip_Budget_Item_Plan_Activity_tb bip, Tag_Taxonomy_Group_tb tag, Kpd_Knl_Plan_Deliverable_tb kpd where kna.kna_id = bip.kna_id and kna.kpd_id_deliverable = kpd.kpd_id and kpd.tax_id_type = tag.tax_id_group_header and bip.bio_id  = bio.bio_id) as execution_plan_activity_approved_amount,
    CASE
        WHEN (select top 1 dep.dep_name from Bip_Budget_Item_Plan_Activity_tb bip, Kna_Knl_Plan_Activity_tb kna, Kpd_Knl_Plan_Deliverable_tb kpd, Knd_Knl_Plan_Division_tb knd, Knp_Knl_Plan_Department_tb knp, Dep_Department_tb dep where bip.kna_id = kna.kna_id and bip.bio_id  = bio.bio_id and kna.kpd_id_deliverable = kpd.kpd_id and kpd.knd_id_division = knd.knd_id and knd.knp_id_plan_department = knp.knp_id and knp.dep_id_department = dep.dep_id) = 'BWP' THEN 'Bank Wide Activity'
        ELSE (select top 1 tal.tal_description from Kna_Knl_Plan_Activity_tb kna, Kpd_Knl_Plan_Deliverable_tb kpd, Tal_Taxonomy_Language_tb tal, Bip_Budget_Item_Plan_Activity_tb bip where kna.kpd_id_deliverable = kpd.kpd_id and kpd.tax_id_type = tal.tax_id and kna.kna_id = bip.kna_id and bip.bio_id = bio.bio_id)
    END as execution_plan_activity_type,
    (select top 1 tal1.tal_description from Tal_Taxonomy_Language_tb tal1 where tal1.tax_id = bie.tax_id_classification) as execution_classification,
    bie.bie_entry_date as execution_entry_date,
    (select top 1 per2.per_last_name+', '+ per2.per_first_name from Per_Person_tb per2 where per2.per_id = bie.per_id_creator) as execution_creator,
    bie.bie_last_updated_date as execution_last_updated_date,
    (select top 1 per3.per_last_name+', '+ per3.per_first_name from Per_Person_tb per3 where per3.per_id = bie.per_id_updator) as execution_last_updator,
     bio.bio_lawson_date as lawson_date
from Bio_Budget_Item_Obligated bio left outer join  Bie_Budget_Item_Executed bie on bio.bio_id = bie.bio_id_budget_item_obligated,
    Adc_Administrative_Account_tb adc,
    Bou_Budget_Org_Unit_tb bou,
    Ops_Opus_tb ops
where bio.ops_id_opus = ops.ops_id
    and bio.adc_id_administrative_account = adc.adc_id
    and bio.bou_id_budget_org_unit = bou.bou_id
    and bio.bio_entry_type not in ('BIO_OPERATIONAL')
    /*and bio.bio_deleted_date is null
    and bie.bie_deleted_date is null*/;