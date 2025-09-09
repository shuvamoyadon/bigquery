-- Example SQL transformation
-- This is a template that will be formatted with actual parameters
-- Parameters: {source_project}, {source_dataset}, {source_table}, {target_project}, {target_dataset}, {target_table}

SELECT 
  *,
  CURRENT_TIMESTAMP() AS etl_timestamp
FROM 
  `{source_project}.{source_dataset}.{source_table}`
WHERE
  -- Add your filter conditions here
  date_column >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
