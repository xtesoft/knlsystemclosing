CREATE VIEW [dbo].[BUD_BUDE_INFORMATION_VW]
AS 
select bud.bud_id,
    bud.yea_year,
    bou.bou_code,
    ops.ops_activity_code,
    adc.adc_code,
    bud.bud_lawson_date,
    bud.bud_doc_type,
    bud.bud_accounting_type,
    bud.bud_amount,
    case when bud.bud_accounting_type = 'BUD_DEBIT' then bud.bud_amount else -1*bud.bud_amount end as bud_amount1,
    (SELECT isNull(SUM(case when bie.bie_accounting_type = 'BIE_DEBIT' then BIE.bie_item_cost else BIE.bie_item_cost* -1 end),0)  FROM Bie_Budget_Item_Executed BIE WHERE BIE.bud_e_id = bud.bud_id and bie.bie_deleted_date is null) as bud_executed,
    bud.bud_description,
    bud.bud_status,
    bud.bud_error_type,
    bud.bud_doc_num,
    bud.bud_invoice_description,
    bud.bud_for_fix_me,
    bud.bud_creation_date,
    bud.bud_update_date,
    per.per_first_name + ' ' + isnull(per.per_middle_name,'') + per.per_last_name as updator,
    bud.bud_comment,
    bud.bud_fnd,
    bud.bud_func_area,
    bud.bud_assigned_wbs_element,
    bud.bud_ref_doc_txt,
    bud.bud_vendor,
    bud.bud_vendor_number,
    bud.bud_ref_doc_txt2
from Bud_Bud_E_tb bud,
    Adc_Administrative_Account_tb adc,
    Bou_Budget_Org_Unit_tb bou,
    Ops_Opus_tb ops,
    Per_Person_tb per
where bud.adc_id_account = adc.adc_id
    and bou.bou_id = bud.bou_id_budget_org_unit
    and ops.ops_id = bud.ops_id_opus
    and per.per_id = bud.per_updator_id