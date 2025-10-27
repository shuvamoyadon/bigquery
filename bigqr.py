from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from google.cloud import bigquery  # comes with the provider in Composer

PROJECT_ID = "edp-dev-storage"
SOURCE_DATASET = "edp_ent_entl_cnsv"
TARGET_DATASET = "edp_ent_cma_plss_onboarding_cnf"
TARGET_TABLE = "WH_CFM_CUSTOMER"
LOCATION = "US"            # must match your datasets
GCP_CONN_ID = "bigquery_spyy"  # or your connection id

SQL = f"""
SELECT * FROM `{PROJECT_ID}.{SOURCE_DATASET}.CUSTOMER_DEMOGRAPHICS_VIEW`
LIMIT 10
"""

def run_bq_query(**_):
    hook = BigQueryHook(gcp_conn_id=GCP_CONN_ID, location=LOCATION)
    client = hook.get_client(project_id=PROJECT_ID)
    job_config = bigquery.QueryJobConfig(
        destination=f"{PROJECT_ID}.{TARGET_DATASET}.{TARGET_TABLE}",
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )
    job = client.query(SQL, location=LOCATION, job_config=job_config)
    job.result()  # wait for completion

with DAG(
    dag_id="plss_test_python_op",
    start_date=datetime(2025, 10, 23),
    schedule=None,
    catchup=False,
    tags=["bigquery","etl","example"],
) as dag:
    copy_task = PythonOperator(
        task_id="copy_bq_with_python",
        python_callable=run_bq_query,
    )
