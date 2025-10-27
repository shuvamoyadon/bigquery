from datetime import datetime
import logging

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from google.cloud import bigquery

PROJECT_ID = "edp-dev-storage"
LOCATION = "US"                 # must match your BQ datasets' location/region
GCP_CONN_ID = "bigquery_spyy"   # or your custom connection id

# --- Your two queries (edit as needed) ---
SQL1 = f"""
SELECT * 
FROM `{PROJECT_ID}.edp_ent_entl_cnsv.CUSTOMER_DEMOGRAPHICS_VIEW`
LIMIT 10
"""

SQL2 = f"""
SELECT * 
FROM `{PROJECT_ID}.edp_ent_entl_cnsv.CUSTOMER_PROFILE_VIEW`
LIMIT 10
"""

def run_two_bq_queries(**_):
    """Runs two queries, prints sample rows, and returns row counts."""
    hook = BigQueryHook(gcp_conn_id=GCP_CONN_ID, location=LOCATION)
    client: bigquery.Client = hook.get_client(project_id=PROJECT_ID)

    # --- Query 1 ---
    logging.info("Running SQL1...")
    job1 = client.query(SQL1, location=LOCATION)
    res1 = job1.result()
    df1 = res1.to_dataframe()   # requires pandas/pyarrow (present in Composer)
    logging.info("SQL1 row count: %s", len(df1))
    logging.info("SQL1 sample rows:\n%s", df1.head(5).to_string(index=False))

    # --- Query 2 ---
    logging.info("Running SQL2...")
    job2 = client.query(SQL2, location=LOCATION)
    res2 = job2.result()
    df2 = res2.to_dataframe()
    logging.info("SQL2 row count: %s", len(df2))
    logging.info("SQL2 sample rows:\n%s", df2.head(5).to_string(index=False))

    # Return something useful to XCom (optional)
    return {
        "sql1_rows": len(df1),
        "sql2_rows": len(df2),
    }

with DAG(
    dag_id="plss_test_python_op_two_queries",
    start_date=datetime(2025, 10, 23),
    schedule=None,
    catchup=False,
    tags=["bigquery", "etl", "example"],
) as dag:
    run_two_queries = PythonOperator(
        task_id="run_two_bq_selects",
        python_callable=run_two_bq_queries,
    )
