"""
BigQuery ETL DAG that loads data from one BigQuery table to another using SQL transformations.
Configuration is loaded from JSON files in the airflow_variables directory.
"""
import os
import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Any

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from google.cloud import bigquery
from google.oauth2 import service_account

# Import utility functions
from dags.utils import load_variables_from_file, get_sql_file_path

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Constants
DAG_DIR = Path(__file__).parent
VARIABLES_DIR = DAG_DIR / 'DMX' / 'airflow_variables'
SQL_DIR = DAG_DIR / 'DMX' / 'sql'

def read_sql_file(file_path: str) -> str:
    """Read SQL file and return its contents."""
    try:
        with open(file_path, 'r') as f:
            return f.read()
    except Exception as e:
        logger.error(f"Error reading SQL file {file_path}: {e}")
        raise

def execute_bq_query(
    sql: str,
    project_id: str,
    credentials_path: str = None,
    **kwargs
) -> None:
    """Execute a BigQuery SQL query."""
    try:
        # Initialize BigQuery client
        if credentials_path and os.path.exists(credentials_path):
            credentials = service_account.Credentials.from_service_account_file(
                credentials_path,
                scopes=["https://www.googleapis.com/auth/cloud-platform"]
            )
            client = bigquery.Client(project=project_id, credentials=credentials)
        else:
            client = bigquery.Client(project=project_id)

        # Execute query
        query_job = client.query(sql)
        query_job.result()  # Wait for the job to complete
        logger.info(f"Query executed successfully: {sql[:100]}...")
        
    except Exception as e:
        logger.error(f"Error executing BigQuery query: {e}")
        raise

def process_etl_job(config: Dict[str, Any], **context) -> None:
    """Process a single ETL job."""
    # Get SQL file path and read SQL
    sql_file_path = get_sql_file_path(config['sql_file'])
    sql_template = read_sql_file(sql_file_path)
    
    # Format SQL with provided parameters
    sql = sql_template.format(
        source_project=config['source_project'],
        source_dataset=config['source_dataset'],
        source_table=config['source_table'],
        target_project=config['target_project'],
        target_dataset=config['target_dataset'],
        target_table=config['target_table']
    )
    
    # Execute the query
    execute_bq_query(
        sql=sql,
        project_id=config['target_project'],
        credentials_path=os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    )

def create_dag(config_file: str) -> DAG:
    """Create a DAG from a configuration file."""
    # Load configuration
    config_path = os.path.join(VARIABLES_DIR, config_file)
    config = load_variables_from_file(config_path)
    
    # Set default arguments
    default_args = {
        'owner': 'airflow',
        'depends_on_past': False,
        'email_on_failure': True,
        'email_on_retry': False,
        'retries': 1,
        'retry_delay': timedelta(minutes=5),
        'start_date': datetime.strptime(config.get('start_date', '2023-01-01'), '%Y-%m-%d'),
    }
    
    # Create DAG
    dag_id = os.path.splitext(config_file)[0]  # Use config filename as DAG ID
    dag = DAG(
        dag_id=dag_id,
        default_args=default_args,
        description=f'BigQuery ETL: {dag_id}',
        schedule_interval=config.get('schedule_interval', '@daily'),
        catchup=False,
        tags=['bigquery', 'etl'],
    )
    
    # Create task
    with dag:
        etl_task = PythonOperator(
            task_id='execute_bq_etl',
            python_callable=process_etl_job,
            op_kwargs={'config': config},
            provide_context=True,
        )
    
    return dag

# Create DAGs for each configuration file in the variables directory
for filename in os.listdir(VARIABLES_DIR):
    if filename.endswith('.json'):
        globals()[f'dag_{filename[:-5]}'] = create_dag(filename)
