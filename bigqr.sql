INSERT INTO `edp-dev-storage.edp_ent_cma_plss_onboarding_cnf.CFM_PRODUCT_CONFIGURATION` (
  sgk_product_configuration_id,
  source_system_cd,
  business_unit_cd,
  line_of_business_cd,
  insert_dts,
  record_status_cd,
  source_record_cd,
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
  'CFG1234567890',              -- sgk_product_configuration_id
  'SRC01',                      -- source_system_cd
  'BU801',                      -- business_unit_cd
  'LOB_HEALTH',                 -- line_of_business_cd
  CURRENT_TIMESTAMP(),          -- insert_dts
  'ACTIVE',                     -- record_status_cd
  'SRCREC01',                   -- source_record_cd
  1,                            -- source_record_sequence_nbr
  'HASHKEY123',                 -- record_hash_key_id
  CURRENT_TIMESTAMP(),          -- last_process_dts
  CURRENT_TIMESTAMP(),          -- source_last_process_dts
  DATE '2025-01-01',            -- business_effective_dt
  DATE '2026-01-01',            -- business_expiration_dt
  CURRENT_TIMESTAMP(),          -- record_start_dts
  NULL,                         -- record_end_dts
  'Y',                          -- active_record_ind
  'JOBRUN123',                  -- sgk_job_run_id
  'BUSINESS_KEY_SAMPLE_TEXT',   -- business_key_txt
  'IMPL_GROUP_001',             -- sf_product_implementation_grouper_id
  'ASSOC_001',                  -- sf_product_association_id
  'LEVEL_1',                    -- product_level
  'Payer Agnostic',             -- client_type

  -- product_implementation (PUT YOUR FULL JSON OBJECT HERE)
  PARSE_JSON("""
  {
    "Accordant Care": "ACS20",
    "Sub_Product": "Accordant Care Specialty - Buy Up to Rare - formerly known as CTA (20 conditions)",
    "Covered_Condition_Multiple_Sclerosis": true,
    "Covered_Condition_Hereditary_Angioedema": true,
    "Covered_Condition_Hemophilia": true,
    "Covered_Condition_Gaucher_Disease": true,
    "Covered_Condition_Cystic_Fibrosis": true,
    "Covered_Condition_Crohns_Disease": true,
    "Covered_Condition_Sickle_Cell_Disease": true
  }
  """),

  -- program_rules
  PARSE_JSON("""
  {
    "Client_Type": "None - Payer Agnostic",
    "Client_Type_Text": "None - Payer Agnostic",
    "Contracted_LOB_Sub": [
      {"Commercial_Fully_Insured": true},
      {"Commercial_Self_Insured": true},
      {"Medicare_Part_D": true},
      {"Med_D/EGWP": true},
      {"Medicare_Advantage": true},
      {"Medicare_Group": true},
      {"Medicare_Individual": true},
      {"Medicare_Medicaid": true},
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
    "Caremark_Full_Implementation": "Full (Carrier ID level)",
    "Caremark_Text": "Full Implementation (Carrier ID level)",
    "Aetna_Text": "Full Implementation (PSUID level)",
    "Payor_Agnostic": "Full"
  }
  """),

  -- assigned_owner_contact_info
  PARSE_JSON("""
  {
    "Implementation_Manager": "ACC Imp Mgr",
    "Clinical_Advisor": "ACC Care Advisor 1",
    "Primary_Contact_Name": "John",
    "Primary_Contact_Title": "AVP",
    "Primary_Contact_Email": "hacontact1.avp@test.com",
    "Primary_Contact_Notes": "This is primary contact and on the role for 5 yrs.",
    "Secondary_Contact_Name": "FName",
    "Secondary_Contact_Title": "Manager",
    "Secondary_Contact_Email": "hacontact1.mgr@test.com",
    "Secondary_Contact_Notes": "Sec contact notes. newly joined.",
    "Other_Contact_Name": "Betty",
    "Other_Contact_Title": "Sr Mgr",
    "Other_Contact_Email": "bettyothercontact@c.com",
    "Other_Contact_Notes": "Notes for Betty"
  }
  """),

  -- client_contract
  PARSE_JSON("""
  {
    "Contract_Original_Effective_Date": "2025-01-02",
    "Contract_End_Renewal_Date": "2028-01-01",
    "Auto_Renewal": "No",
    "Termination_without_Cause": "Yes, without cause",
    "Termination_Options_Term_Date": "2024-12-05",
    "Estimate_Covered_Number_of_Client_Lives": "10000",
    "Estimate_Covered_Number_of_Lives": "10000",
    "Fee_Type_Interactive": 190,
    "Fee_Type_Self_Directed": 500,
    "Fee_Type_Blended": 234,
    "Fee_Type_Other": "Fee Type Category Explanation",
    "Billing_Start_Date": "2024-11-14",
    "Billing_Start_Date_Notes": "Notes on Billing"
  }
  """),

  -- billing_detail
  PARSE_JSON("""
  {
    "Billing_Model": "PMPM (per member per month)",
    "Billed_via_PBM": "Yes, billed via PBM",
    "Paid_for_By": [
      {"Client_pays": true},
      {"Claims Based Billing": true},
      {"PBM Credits": true},
      {"CVS invoices AHS services": true},
      {"Other": true}
    ],
    "Paid_for_By_Other": "Paid By Other Test",
    "Billable_Rate_Pric": "N/A - Accordant Care Specialty",
    "Billable_Rate_Other": 99
  }
  """),

  -- reporting_detail
  PARSE_JSON("""
  {
    "Contracted_Reporting_Expectations": "Custom",
    "Contracted_Reporting_Expectations_Custom": "reports should be generated monthly",
    "Exceptions_on_Data_Restriction": {
      "Book_of_Business_(BOB)_reporting_/__Benchmarking": true,
      "Research_-_External_publications": true,
      "External_marketing_purposes": true,
      "Internal_program_improvements": false,
      "Internal_product_development": false,
      "Control_group_for_other_product_evaluation": false,
      "Other_use_cases": true
    },
    "Exceptions_on_Data_Restriction_Other": "ACCCare Restrictions details",
    "Client_Name_used_for_Reporting_Custom": "Use the following for client reports",
    "Client_Names_for_Reporting_for_Sub_Level": "ACC Care Sub Level 1",
    "Reporting_Contractual_Program_INSIGHTS": "customization_request",
    "Reporting_Contractual_Program_IMPACT": "customization_request",
    "Reporting_Contractual_Program_REVIEW": "annual",
    "Reporting_NonContractual_Program_MEMBER_Roster": "customization_request_extra",
    "MEMBER_Roster_custom": "First Member roster CS Req for ACC Care",
    "Full_Data_Set": "No",
    "No_Full_Data_Set_Explain": "Accordant Care lab data not available",
    "Program_Year_start_date_for_Reporting": "2023-01-01",
    "Next_Annual_Report_Due_Date": "2026-01-01"
  }
  """),

  -- ROI_performance_guarantees
  PARSE_JSON("""
  {
    "Performance_Guarantee_types": "Standard",
    "Performance_Guarantee_types_Other": "3:1",
    "Total_fees_at_risk": "15%",
    "ROI_fees_at_risk": "0%",
    "Total_ROI_fees_at_risk_financial_Other": "Custom total fee text 111",
    "ROI_Results": "fees paid back to client",
    "Client_Annual_Revenue": "1000000",
    "Overall_Risk_Status": "Yellow",
    "Overall_Risk_Status_Reason_Category": "Reporting",
    "Overall_Risk_Status_Reason_Category_Other": "Risk Test 11",
    "Overall_Risk_Status_Comments": "Comments 1",
    "Potential_Upsells": "Weight Management, Accordant Care Rare"
  }
  """)
);
