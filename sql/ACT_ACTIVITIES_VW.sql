CREATE VIEW [dbo].[ACT_ACTIVITIES_VW] AS 
select kna.kna_id as activityID,  
    (select sec.sec_id from Unt_Unit_tb unt2, Dep_Department_tb dep, Sec_Section_tb sec where unt2.unt_id = knd.unt_id_unit and dep.dep_id = unt2.dep_id_department and sec.sec_id = dep.sec_id_section) as secId,
    (select sec.sec_name from Unt_Unit_tb unt2, Dep_Department_tb dep, Sec_Section_tb sec where unt2.unt_id = knd.unt_id_unit and dep.dep_id = unt2.dep_id_department and sec.sec_id = dep.sec_id_section) as secName,
    (select dep.dep_name from Unt_Unit_tb unt2, Dep_Department_tb dep where unt2.unt_id = knd.unt_id_unit and dep.dep_id = unt2.dep_id_department) as depName,
    (select dep.dep_id from Unt_Unit_tb unt2, Dep_Department_tb dep where unt2.unt_id = knd.unt_id_unit and dep.dep_id = unt2.dep_id_department) as depId,
    (select unt.unt_name from Unt_Unit_tb unt where unt.unt_id = knd.unt_id_unit) as unit,
    (select unt.unt_id from Unt_Unit_tb unt where unt.unt_id = knd.unt_id_unit) as unitId,
    knp.yea_year,
    (select tal.tal_description from Tal_Taxonomy_Language_tb tal where tal.tax_id = kpd.tax_id_type and tal.lng_id = 1) as componentType,
    kpd.kpd_name as deliverableName,
    kna.kna_name as activityName,
    kna.kna_deliverables as activityOutputs,
    kna.kna_estimated_participant as activityParticipants,
    ops.ops_activity_code as activityBK,
    isNull(kna.kna_unit_amount,0) as unitAmount,
    isNull(kna.kna_knl_amount,0) as knlAmount,
    isNull(kna.kna_other_amount,0) as otherAmount,
    isNull(kna.kna_unit_amount,0) + isNull(kna.kna_knl_amount,0) + isNull(kna.kna_other_amount,0) as activityAmount,
    kna.kna_other_entity as otherEntity,
    dbo.getKNLOfficersByKnlActivity(kna.kna_id) as knlOfficer,
    (select count(*) from Out_Outcome_tb out, Aao_Available_Activity_Outcome_tb aao where aao.out_id_outcome = out.out_id and aao.kna_id_activity = kna.kna_id /*and out.out_deleted_flag = 0*/) as outputCount,
    isnull((select sum(sof.sof_amount)
    from Aao_Available_Activity_Outcome_tb aao,
        Out_Outcome_tb o,
        Sof_Source_Of_Funding_tb sof,
        Sac_Source_Of_Funding_Account_tb sac
    where aao.kna_id_activity = kna.kna_id
        and aao.out_id_outcome = o.out_id
        and o.out_id = sof.out_id_outcome
        and sof.sof_type = 'SOF_BY_ACCOUNT'
        --and sof.sof_deleted_flag = 0
        /*and o.out_deleted_flag = 0*/
        and sac.sof_id = sof.sof_id
        and sac.bou_id_budget_org_unit not in (select bou.bou_id from Bou_Budget_Org_Unit_tb bou where bou.bou_active_flag = 1 and bou.bou_name like 'KNL002%')),0) as unit_programmed_amount,
    cast((SELECT isNull(SUM(total_amount),0) AS total_amount   FROM   (  SELECT      isnull(SUM( CASE WHEN out.out_budget_officer_closed_flag = 1 THEN sof.sof_executed_amount ELSE sof.sof_amount END),0) AS total_amount       FROM      Sof_Source_Of_Funding_tb sof,      Sat_Source_Of_Funding_Activity_tb sat,      Out_Outcome_tb OUT      WHERE      sof.sof_id = sat.sof_id AND      sof.sof_deleted_flag = 0 AND      sof.out_id_outcome = OUT.out_id /*AND      OUT.out_deleted_flag = 0*/ AND      sat.kna_id_knl_administrative_plan = KNA.KNA_ID     UNION       ALL SELECT         SUM(a.debit_amount) - SUM(a.credit_amount) AS total_amount         FROM         ( SELECT           SUM (bio.bio_item_cost) AS debit_amount,           0                       AS credit_amount           FROM           Bio_Budget_Item_Obligated bio,           Bip_Budget_Item_Plan_Activity_tb bip           WHERE           bip.bio_id = bio.bio_id AND           bio.bio_deleted_date IS NULL AND           bio.bio_accounting_type = 'BIO_DEBIT' AND           bip.kna_id = KNA.KNA_ID          UNION           ALL SELECT             0                       AS debit_amount,             SUM (bio.bio_item_cost) AS credit_amount             FROM             Bio_Budget_Item_Obligated bio,             Bip_Budget_Item_Plan_Activity_tb bip             WHERE             bip.bio_id = bio.bio_id AND             bio.bio_deleted_date IS NULL AND             bio.bio_accounting_type = 'BIO_CREDIT' AND             bip.kna_id = KNA.KNA_ID         )         AS a    )   AS b) as decimal(15,2)) as latestTotalCostAmount,
    CAST((SELECT
			isnull(SUM( 
                    CASE 
                        WHEN OUT.out_budget_officer_closed_flag = 1 
                        THEN sof.sof_executed_amount 
                        ELSE sof.sof_amount 
                    END),0) AS total_amount 
		FROM
			Sof_Source_Of_Funding_tb sof,
			Sat_Source_Of_Funding_Activity_tb sat,
			Out_Outcome_tb OUT,
            Aao_Available_Activity_Outcome_tb aao
		WHERE
			sof.sof_id = sat.sof_id AND
            aao.out_id_outcome = OUT.out_id AND
            aao.kna_id_activity = sat.kna_id_knl_administrative_plan AND
			--sof.sof_deleted_flag = 0 AND
			sof.out_id_outcome = OUT.out_id AND
			/*OUT.out_deleted_flag = 0 AND*/
			sat.kna_id_knl_administrative_plan = KNA.KNA_ID) AS DECIMAL(15,5)) AS PROGRAMMED_ASSOCIATED,
    CAST((SELECT
			isnull(SUM( 
                    CASE 
                        WHEN OUT.out_budget_officer_closed_flag = 1 
                        THEN sof.sof_executed_amount 
                        ELSE sof.sof_amount 
                    END),0) AS total_amount 
		FROM
			Sof_Source_Of_Funding_tb sof,
			Sat_Source_Of_Funding_Activity_tb sat,
			Out_Outcome_tb OUT,
            Aao_Available_Activity_Outcome_tb aao
		WHERE
			sof.sof_id = sat.sof_id AND
            aao.out_id_outcome = OUT.out_id AND
            aao.kna_id_activity <> sat.kna_id_knl_administrative_plan AND
			--sof.sof_deleted_flag = 0 AND
			sof.out_id_outcome = OUT.out_id AND
			/*OUT.out_deleted_flag = 0 AND*/
			aao.kna_id_activity = KNA.KNA_ID) AS DECIMAL(15,5)) AS PROGRAMMED_FINANCED,
    CAST((SELECT
			SUM(a.debit_amount) - SUM(a.credit_amount) AS total_amount 
		FROM
		(	SELECT
				SUM (bio.bio_item_cost) AS debit_amount,
				0                       AS credit_amount 
			FROM
				Bio_Budget_Item_Obligated bio,
				Bip_Budget_Item_Plan_Activity_tb bip 
			WHERE
				bip.bio_id = bio.bio_id AND
				--bio.bio_deleted_date IS NULL AND
				bio.bio_accounting_type = 'BIO_DEBIT' AND
				bip.kna_id = KNA.KNA_ID 
			UNION ALL 
            SELECT
				0                       AS debit_amount,
				SUM (bio.bio_item_cost) AS credit_amount 
			FROM
				Bio_Budget_Item_Obligated bio,
                Bip_Budget_Item_Plan_Activity_tb bip 
			WHERE
				bip.bio_id = bio.bio_id AND
				--bio.bio_deleted_date IS NULL AND
				bio.bio_accounting_type = 'BIO_CREDIT' AND
				bip.kna_id = KNA.KNA_ID 
			)AS a) AS DECIMAL(15,2)) AS PROGRAMMED_CHARGES,
    cast((SELECT
			ISNULL(SUM(B.TOTAL_AMOUNT),0) AS TOTAL_AMOUNT 
		FROM
			(	SELECT SUM(SOF.sof_executed_amount) TOTAL_AMOUNT
				FROM Sof_Source_Of_Funding_tb SOF,
				    Sat_Source_Of_Funding_Activity_tb SAT,
                    Out_Outcome_tb o
				WHERE /*SOF.sof_deleted_flag = 0
				    AND */SAT.sof_id = SOF.sof_id
                    AND O.OUT_ID = SOF.OUT_ID_OUTCOME
                    /*AND O.OUT_DELETED_FLAG = 0*/
				    AND SAT.kna_id_knl_administrative_plan = kna.kna_id 
					
		UNION ALL
		SELECT
			SUM(A.DEBIT_AMOUNT) - SUM(A.CREDIT_AMOUNT) AS TOTAL_AMOUNT 
		FROM
			(	SELECT
					SUM (BIO.BIO_ITEM_COST) AS DEBIT_AMOUNT,
					0                       AS CREDIT_AMOUNT 
				FROM
					BIO_BUDGET_ITEM_OBLIGATED BIO,
					BIP_BUDGET_ITEM_PLAN_ACTIVITY_TB BIP 
				WHERE
					BIP.BIO_ID = BIO.BIO_ID AND
					--BIO.BIO_DELETED_DATE IS NULL AND
					BIO.BIO_ACCOUNTING_TYPE = 'BIO_DEBIT' AND
					BIP.KNA_ID = kna.kna_id
				UNION ALL
		        SELECT
		            0                       AS DEBIT_AMOUNT,
		            SUM (BIO.BIO_ITEM_COST) AS CREDIT_AMOUNT 
		        FROM
		            BIO_BUDGET_ITEM_OBLIGATED BIO,
		            BIP_BUDGET_ITEM_PLAN_ACTIVITY_TB BIP 
		        WHERE
		            BIP.BIO_ID = BIO.BIO_ID AND
		            --BIO.BIO_DELETED_DATE IS NULL AND
		            BIO.BIO_ACCOUNTING_TYPE = 'BIO_CREDIT' AND
		            BIP.KNA_ID = kna.kna_id
		        ) AS A 
			) AS B) as decimal(15,2)) as disbursedAmount,
        cast((SELECT
			ISNULL(SUM(B.TOTAL_AMOUNT),0) AS TOTAL_AMOUNT 
		FROM
			(	SELECT
			SUM(A.DEBIT_AMOUNT) - SUM(A.CREDIT_AMOUNT) AS TOTAL_AMOUNT 
		FROM
			(	
                select 0 AS DEBIT_AMOUNT, SUM(BIO.bio_item_cost) AS CREDIT_AMOUNT
                from Aao_Available_Activity_Outcome_tb aao,
                    Out_Outcome_tb O,
                    Obg_Outcome_Budget_tb obg,
                    Obc_Outcome_Budget_Category_tb obc,
                    Boo_Budget_Item_Operational boo,
                    Bio_Budget_Item_Obligated bio
                where aao.out_id_outcome = obg.out_id_outcome
                    AND AAO.out_id_outcome = o.out_id
                    and obg.obg_id = obc.obg_id_outcome_budget
                    and obc.obc_id = boo.obc_id_outcome_budget_category
                    and bio.bio_id = boo.bio_id
                    and obg.obg_entry_type = 'OBG_EXECUTED'
                    and BIO.bio_accounting_type = 'BIO_CREDIT'
                    /*and o.out_deleted_flag = 0*/
                    --and bio.bio_deleted_date is null
                    and aao.kna_id_activity = kna.kna_id
                UNION all
                select SUM(BIO.bio_item_cost) AS DEBIT_AMOUNT, 0 AS CREDIT_AMOUNT
                from Aao_Available_Activity_Outcome_tb aao,
                    Out_Outcome_tb O,
                    Obg_Outcome_Budget_tb obg,
                    Obc_Outcome_Budget_Category_tb obc,
                    Boo_Budget_Item_Operational boo,
                    Bio_Budget_Item_Obligated bio
                where aao.out_id_outcome = obg.out_id_outcome
                    AND AAO.out_id_outcome = o.out_id
                    and obg.obg_id = obc.obg_id_outcome_budget
                    and obc.obc_id = boo.obc_id_outcome_budget_category
                    and bio.bio_id = boo.bio_id
                    and obg.obg_entry_type = 'OBG_EXECUTED'
                    and BIO.bio_accounting_type = 'BIO_DEBIT'
                    /*and o.out_deleted_flag = 0*/
                    --and bio.bio_deleted_date is null
                    and aao.kna_id_activity = kna.kna_id
               union all
               SELECT
					SUM (BIO.BIO_ITEM_COST) AS DEBIT_AMOUNT,
					0                       AS CREDIT_AMOUNT 
				FROM
					BIO_BUDGET_ITEM_OBLIGATED BIO,
					BIP_BUDGET_ITEM_PLAN_ACTIVITY_TB BIP 
				WHERE
					BIP.BIO_ID = BIO.BIO_ID AND
					--BIO.BIO_DELETED_DATE IS NULL AND
					BIO.BIO_ACCOUNTING_TYPE = 'BIO_DEBIT' AND
					BIP.KNA_ID = kna.kna_id
				UNION ALL
		        SELECT
		            0                       AS DEBIT_AMOUNT,
		            SUM (BIO.BIO_ITEM_COST) AS CREDIT_AMOUNT 
		        FROM
		            BIO_BUDGET_ITEM_OBLIGATED BIO,
		            BIP_BUDGET_ITEM_PLAN_ACTIVITY_TB BIP 
		        WHERE
		            BIP.BIO_ID = BIO.BIO_ID AND
		            --BIO.BIO_DELETED_DATE IS NULL AND
		            BIO.BIO_ACCOUNTING_TYPE = 'BIO_CREDIT' AND
		            BIP.KNA_ID = kna.kna_id
            ) AS A 
			) AS B) as decimal(15,2)) as budgetItemsObligatedAmount,
        cast((SELECT
			ISNULL(SUM(B.TOTAL_AMOUNT),0) AS TOTAL_AMOUNT 
		FROM
			(	SELECT
			SUM(A.DEBIT_AMOUNT) - SUM(A.CREDIT_AMOUNT) AS TOTAL_AMOUNT 
		FROM
			(	
                select 0 AS DEBIT_AMOUNT, SUM(BIE.bie_item_cost) AS CREDIT_AMOUNT
                from Aao_Available_Activity_Outcome_tb aao,
                    Out_Outcome_tb O,
                    Obg_Outcome_Budget_tb obg,
                    Obc_Outcome_Budget_Category_tb obc,
                    Boo_Budget_Item_Operational boo,
                    Bio_Budget_Item_Obligated bio,
                    Bie_Budget_Item_Executed bie
                where aao.out_id_outcome = obg.out_id_outcome
                    AND AAO.out_id_outcome = o.out_id
                    and obg.obg_id = obc.obg_id_outcome_budget
                    and obc.obc_id = boo.obc_id_outcome_budget_category
                    and bio.bio_id = boo.bio_id
          			and bio.bio_id = bie.bio_id_budget_item_obligated
                    and obg.obg_entry_type = 'OBG_EXECUTED'
                    and BIE.bie_accounting_type = 'BIE_CREDIT'
                    /*and o.out_deleted_flag = 0*/
                    /*and bio.bio_deleted_date is null
                    and bie.bie_deleted_date is null*/
                    and aao.kna_id_activity = kna.kna_id
                UNION all
                select SUM(BIE.bie_item_cost) AS DEBIT_AMOUNT, 0 AS CREDIT_AMOUNT
                from Aao_Available_Activity_Outcome_tb aao,
                    Out_Outcome_tb O,
                    Obg_Outcome_Budget_tb obg,
                    Obc_Outcome_Budget_Category_tb obc,
                    Boo_Budget_Item_Operational boo,
                    Bio_Budget_Item_Obligated bio,
                    Bie_Budget_Item_Executed bie
                where aao.out_id_outcome = obg.out_id_outcome
                    AND AAO.out_id_outcome = o.out_id
                    and obg.obg_id = obc.obg_id_outcome_budget
                    and obc.obc_id = boo.obc_id_outcome_budget_category
                    and bio.bio_id = boo.bio_id
                    and bio.bio_id = bie.bio_id_budget_item_obligated
                    and obg.obg_entry_type = 'OBG_EXECUTED'
                    and BIE.bie_accounting_type = 'BIE_DEBIT'
                    /*and o.out_deleted_flag = 0*/
                    /*and bio.bio_deleted_date is null
                    and bie.bie_deleted_date is null*/
                    and aao.kna_id_activity = kna.kna_id
               union all
               SELECT
					SUM (BIe.BIe_ITEM_COST) AS DEBIT_AMOUNT,
					0                       AS CREDIT_AMOUNT 
				FROM
					BIO_BUDGET_ITEM_OBLIGATED BIO,
                    Bie_Budget_Item_Executed bie,
					BIP_BUDGET_ITEM_PLAN_ACTIVITY_TB BIP 
				WHERE
					BIP.BIO_ID = BIO.BIO_ID AND
					bio.bio_id = bie.bio_id_budget_item_obligated AND
                    /*BIO.BIO_DELETED_DATE IS NULL AND
                    bie.bie_deleted_date is null AND*/
					BIE.bie_accounting_type = 'BIE_DEBIT' AND
					BIP.KNA_ID = kna.kna_id
				UNION ALL
		        SELECT
		            0                       AS DEBIT_AMOUNT,
		            SUM (BIE.BIE_ITEM_COST) AS CREDIT_AMOUNT 
		        FROM
		            BIO_BUDGET_ITEM_OBLIGATED BIO,
		            Bie_Budget_Item_Executed bie,
					BIP_BUDGET_ITEM_PLAN_ACTIVITY_TB BIP 
		        WHERE
		            BIP.BIO_ID = BIO.BIO_ID AND
		            bio.bio_id = bie.bio_id_budget_item_obligated AND
                    /*BIO.BIO_DELETED_DATE IS NULL AND
		            bie.bie_deleted_date is null AND*/
					BIe.bie_accounting_type = 'BIE_CREDIT' AND
					BIP.KNA_ID = kna.kna_id
            ) AS A 
			) AS B) as decimal(15,2)) as budgetItemsExecutedAmount,
    CASE WHEN (select tal.tal_description from Tal_Taxonomy_Language_tb tal where tal.tax_id = kpd.tax_id_type and tal.lng_id = 1) <> 'Need' and kna.kna_knl_analisys_status = 'KNA_KNL_APPROVED' THEN 'KNL Approved' 
         WHEN (select tal.tal_description from Tal_Taxonomy_Language_tb tal where tal.tax_id = kpd.tax_id_type and tal.lng_id = 1) <> 'Need' and kna.kna_knl_analisys_status <> 'KNA_KNL_APPROVED' THEN 'KNL Pending Approval'
         ELSE '' 
    END as knlStatus,
    isNUll(kna.kna_approved_amount,0) as knlApprovedAmount,
    isNull((select tal.tal_description from Tal_Taxonomy_Language_tb tal where tal.tax_id = kna.tax_id_source_funding and tal.lng_id = 1),'--') as sourceOfFunding,
 (	SELECT
		CASE 
			WHEN tag.tag_code = 'NEE' AND
			kna.kna_selected_flag = 1 
			THEN 'Approved' 
			WHEN tag.tag_code = 'NEE' AND
			kna.kna_selected_flag = 0 
			THEN 'Pending Approval' 
			WHEN (tag.tag_code = 'CON' OR
			tag.tag_code = 'KCP') AND
			kna.kna_approved_flag = 1 
			THEN 'Approved' 
			WHEN (tag.tag_code = 'CON' OR
			tag.tag_code = 'KCP') AND
			kna.kna_approved_flag = 0 
			THEN 'Pending Approval' 
		END AS activity_status 
	FROM		
		Tag_Taxonomy_Group_tb tag
	WHERE  	
		tag.tax_id_group_header = kpd.tax_id_type 
)
AS activity_status,
isNull(
    (select sum(kai_amount) from Kpa_Knl_Plan_Allocation_tb kpa, Kai_Knl_Plan_Allocation_Item_tb kai
        where kai.kpa_id_allocation = kpa.kpa_id and
                kai.kai_active_flag = 1 and 
                kpa.yea_year = knp.yea_year and 
                kpa.dep_id_department = knp.dep_id_department) ,0) as departmentAllocatedFund,
knd.knd_id,
knp.knp_id,
kpd.kpd_id,
(SELECT tag.tag_code FROM Tag_Taxonomy_Group_tb tag WHERE  tag.tax_id_group_header = kpd.tax_id_type ) as kndType
from Kna_Knl_Plan_Activity_tb kna,
    Kpd_Knl_Plan_Deliverable_tb kpd,
    Knd_Knl_Plan_Division_tb knd,
    knp_knl_plan_department_tb knp,
    Ops_Opus_tb ops
where kna.kpd_id_deliverable = kpd.kpd_id
    and kpd.knd_id_division = knd.knd_id
    and knd.knp_id_plan_department = knp.knp_id
    and kna.ops_id_opus = ops.ops_id
    and knp.yea_year >=2010
    /*and kna.kna_deleted_date is null
    and kpd.kpd_deleted_date is null
    and kna.kna_selected_flag = 1*/