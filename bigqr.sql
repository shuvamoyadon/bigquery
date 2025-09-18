INSERT INTO `edp-dev-storage.edp_ent_cma_plss_onboarding_cnf.CFM_PRODUCT_CONFIGURATION` (
  sgk_product_configuration_id,
  source_system_cd,
  business_unit_cd,
  line_of_business_cd,
  insert_dts,
  record_status_cd,
  source_record_sequence_nbr,
  record_hash_key_id,
  last_process_dts,
  source_last_process_dts,
  business_effective_dt,
  business_expiration_dt,
  record_start_dts,
  record_end_dts,
  active_record_ind,
  sgk_job_run_id,
  business_key_txt,
  sf_product_implementation_grouper_id,
  sf_product_association_id,
  product_level,
  client_type,
  product_implementation,
  program_rules,
  assigned_owner_contact_info,
  client_contract,
  billing_detail,
  reporting_detail,
  ROI_performance_guarantees
)
VALUES (
  'CFG1234567890',
  'SRC01',
  'BU001',
  'LOB_HEALTH',
  CURRENT_TIMESTAMP(),
  'ACTIVE',
  '1',
  'HASHKEY123',
  CURRENT_TIMESTAMP(),
  CURRENT_TIMESTAMP(),
  DATE '2025-01-01',
  DATE '2026-01-01',
  CURRENT_TIMESTAMP(),
  NULL,
  'Y',
  'JOBRUN123',
  'BUSINESS_KEY_SAMPLE_TEXT',
  'IMPL_GROUP_001',
  'ASSOC_001',

  -- product_level (JSON) ---------------------------------------
  PARSE_JSON(r'''{
    "Accordant_Care": "ACS20",
    "Sub_Product": "Accordant Care Specialty - Buy Up to Rare - formerly known as CTA (20 conditions)",
    "Covered_Condition_Multiple_Sclerosis": true,
    "Covered_Condition_Hereditary_Angioedema": true,
    "Covered_Condition_Hemophilia": true,
    "Covered_Condition_Gaucher_Disease": true,
    "Covered_Condition_Cystic_Fibrosis": true,
    "Covered_Condition_Chronhs_Disease": true,
    "Covered_Condition_Sickle_Cell_Disease": true
  '''),

  -- client_type (JSON) -----------------------------------------
  PARSE_JSON(r'''{
    "Client_Type": "None - Payer Agnostic",
    "Client_Type_Text": "None - Payer Agnostic",
    "Contracted_LOB_Sub": [
      {"Commercial_Fully_Insured": true},
      {"Commercial_Self_Insured": true},
      {"Medicare_Part_D": true},
      {"Med_EGWP": true},
      {"Medicare_Advantage": true},
      {"Medicare_Group": true},
      {"Medicare_Individual": true},
      {"Medicaid": true},
      {"Other": true}
    ],
    "Contracted_LOB_Sub_Other": "Sample Other Text for TDC",
    "Medical_Carrier": [
      {"Aetna": true},
      {"Cigna": true},
      {"Anthem": true},
      {"UHC": true},
      {"UMR": true},
      {"Other": true}
    ],
    "Medical_Carrier_Other": "Medical Carrier Other Notes",
    "PBM_Carrier": [
      {"Caremark": false},
      {"Aetna_IBU": true},
      {"External_Costco": true},
      {"External_EST": true},
      {"External_Magellan": true},
      {"External_Optum": true},
      {"External_Rx_Benefits": true},
      {"External_Other": true}
    ],
    "PBM_Carrier_Other": "PBM Carrier Other Notes V1",
    "CVS_Specialty_Rx": "No",
    "Specialty_Rx_Name": "Proprium Rx (Sentara)",
    "Specialty_Rx_Name_Other": "Specialty Rx Other Names XXXX",
    "Specialty_Renewal_Date_Not_Applicable": false,
    "Specialty_Renewal_Date": "2026-01-01",
    "Caremark": "Full Implementation (Carrier ID level)",
    "Caremark_Text": "Full Implementation (PSUID level)",
    "Aetna_Text": "Full Implementation (PSUID level)",
    "Payer_Agnostic": "Full",
    "CVS_SOURCE_PROD_EFFECTIVE": "2022-11-17",
    "CVS_SOURCE_PROD_EXPDATE": "2024-05-09",
    "Planned_PCD_date": "2023-01-01",
    "Actual_PCD_date": "2024-05-31",
    "PCD_Other": "client was new to PBM",
    "Client_Implementation_Currently_Active": "Yes",
    "Client_Termination_Other": "Currently Active",
    "Client_Terminations_Term_Date": "2024-12-05",
    "Estimated_Total_Number_of_Client_Lives": "10000",
    "Estimate_Covered_Number_of_Lives": "10000",
    "Salesforce_CI_Case": "151",
    "Salesforce_CI_Submission_Date": "2022-09-01",
    "Salesforce_CI_Approval_Date": "2022-10-01",
    "FAF_Pic": "FAF",
    "FAF": "5026",
    "FAF_Other": "Additional information is needed"
  '''),

  -- product_implementation (JSON) -------------------------------
  PARSE_JSON(r'''{
    "Engagement_Model": "Engaged (interactive only)",
    "Engagement_Rule": "2 months",
    "Engagement_Rule_Other": "ER Other",
    "Activity_Rule": "N/A - no rule",
    "Activity_Rule_Other": "AC Rule Other",
    "Branding_for_Welcome_Letter": "Co-Branding",
    "co_branding_level": "Client's entire Carrier level",
    "co_branding_level_Specific_Explain": "co branding explanation for Caremark Client",
    "Client_Approval": "Client Approval Not Required",
    "State_Medicaid_Approval": "Not Applicable",
    "Client_naming_convention": "ACC Custom Client #1"
  '''),

  -- program_rules (JSON) ---------------------------------------
  PARSE_JSON(r'''{
    "Implementation_Manager": "ACC Imp Mgr",
    "Clinical_Advisor": "ACC Care Advisor 1",
    "Primary_Contact_Name": "John",
    "Primary_Contact_Title": "AVP",
    "Primary_Contact_Email": "hacontact1.avp@test.com",
    "Primary_Contact_Notes": "This is primary contact and on the role for 5 yrs.",
    "Secondary_Contact_Name": "FName",
    "Secondary_Contact_Title": "Manager",
    "Secondary_Contact_Email": "hacontact1.mgr@test.com",
    "Secondary_Contact_Notes": "Sec contact notes… newly joined",
    "Other_Contact_Name": "Betty",
    "Other_Contact_Title": "Sr Mgr",
    "Other_Contact_Email": "bettyothercontact@c.com",
    "Other_Contact_Notes": "Notes for Betty"
  '''),

  -- assigned_owner_contact_info (JSON) --------------------------
  PARSE_JSON(r'''{
    "Contract_Original_Effective_Date": "2025-01-02",
    "Contract_End_Renewal_Date": "2028-01-01",
    "Auto_Renewal": "No",
    "Billing_Model": "PPPM (per member per month)",
    "Billed_via_PBM": "Yes, billed via PBM"
  '''),

  -- client_contract (JSON) -------------------------------------
  PARSE_JSON(r'''{
    "Paid_for_By": [
      {"Client_pays": true},
      {"Claims Based Billing": true},
      {"PBM Credits": true},
      {"CVS invoices AHS services": true},
      {"Other": true}
    ],
    "Paid_for_By_Other": "Paid By Other Test",
    "Billable_Rate_Pic": "N/A - Accordant Care Specialty",
    "Billable_Rate_Other": 99,
    "Fee_Type_Interactive": 190,
    "Fee_Type_Self_Directed": 500,
    "Fee_Type_Blended": 234,
    "Fee_Type_Other": "Fee Type Category Explanation",
    "Billing_Start_Date": "2024-11-14",
    "Billing_Start_Date_Notes": "Notes on Billing"
  '''),

  -- billing_detail (JSON) --------------------------------------
  PARSE_JSON(r'''{
    "Contracted_Reporting_Expectations": "Custom",
    "Contracted_Reporting_Expectations_Custom": "reports should be generated monthly",
    "Exceptions_on_Data_Restriction": {
      "Book_of_Business_reporting_Benchmarking": true,
      "Research_External_publications": true,
      "External_marketing_purposes": true,
      "Internal_program_improvements": false,
      "Internal_product_development": false,
      "Control_group_for_other_product_evaluation": false,
      "Other_use_cases": true
    },
    "Exceptions_on_Data_Restriction_Other": "ACCCare Restrictions details",
    "Client_Name_used_for_Reporting": "Use the following for client reports",
    "Next_Annual_Report_Due_Date": "2026-01-01",
    "Breakouts_subgroups_for_reports": "None - client needs only aggregate level reports",
    "Breakouts_subgroups_for_reports_Custom": "Breakout Report Custom Example 1"
  '''),

  -- reporting_detail (JSON) ------------------------------------
  PARSE_JSON(r'''{
    "Performance_Guarantee_types": "Standard",
    "Performance_Guarantee_types_Other": "3:1",
    "Total_fees_at_risk": "15%",
    "ROI_fees_at_risk": "0%",
    "Total_ROI_fees_at_risk_financial_Other": "Custom total fee text 111",
    "PG_fees_at_risk": "10%",
    "Total_PG_fees_at_risk_financial_Other": "Custom PG fee text 111"
  '''),

  -- ROI_performance_guarantees (JSON) --------------------------
  PARSE_JSON(r'''{
    "Overall_Risk_Status": "Yellow",
    "Overall_Risk_Status_Reason_Category": "Reporting",
    "Overall_Risk_Status_Reason_Category_Other": "Risk Test 11",
    "Overall_Risk_Status_Comments": "Comments 1",
    "Potential_Upsells": "Weight Management, Accordant Care Rare",
    "ROI_Results": "fees paid back to client",
    "Client_Annual_Revenue": "1000000"
  ''')
);
