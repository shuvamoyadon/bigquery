# Airflow BigQuery ETL Framework

A generic Airflow framework for BigQuery ETL processes with configuration-driven workflows.

## Project Structure

```
airflow_bq_etl/
├── dags/                    # Airflow DAGs
│   ├── DMX/                 # DMX specific configurations
│   │   ├── sql/             # SQL transformation files
│   │   │   └── example_transform.sql
│   │   ├── airflow_variables/ # Variable definition files
│   │   │   └── example_etl.json
│   │   └── requirements.txt  # Python dependencies for DMX
│   ├── utils/               # Utility functions
│   │   └── __init__.py
│   └── bq_etl_dag.py        # Main DAG definition
└── README.md               # Project documentation
```

## Setup

1. Install dependencies:
   ```bash
   pip install -r dags/DMX/requirements.txt
   ```

2. Set up Airflow variables:
   - Place variable JSON files in the `dags/DMX/airflow_variables` directory
   - The DAG will automatically load variables from these files

3. Add your SQL transformations to the `dags/DMX/sql` directory

## Configuration

Each ETL job is defined by a JSON file in the `airflow_variables` directory. Example:

```json
{
    "schedule_interval": "@daily",
    "start_date": "2023-01-01",
    "source_project": "your-source-project", 
    "source_dataset": "source_dataset",
    "source_table": "source_table",
    "target_project": "your-target-project",
    "target_dataset": "target_dataset",
    "target_table": "target_table",
    "sql_file": "example_transform.sql"
}
```

## Usage

1. Create a new variable file in `airflow_variables/`
2. Create corresponding SQL transformation in `sql/`
3. The DAG will automatically pick up the new configuration
4. The DAG ID will be the filename without the .json extension
