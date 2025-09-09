"""Utility functions for Airflow DAGs."""
import os
import json
import logging
from pathlib import Path
from typing import Dict, Any

def load_variables_from_file(file_path: str) -> Dict[str, Any]:
    """Load variables from a JSON file.
    
    Args:
        file_path: Path to the JSON file containing variables
        
    Returns:
        Dictionary containing the loaded variables
    """
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except Exception as e:
        logging.error(f"Error loading variables from {file_path}: {e}")
        raise

def get_sql_file_path(sql_file_name: str) -> str:
    """Get the full path to a SQL file in the sql directory.
    
    Args:
        sql_file_name: Name of the SQL file
        
    Returns:
        Full path to the SQL file
    """
    # Get the directory of the current file (utils/__init__.py)
    current_dir = Path(__file__).parent
    # Go up one level to the dags directory, then into the sql directory
    sql_dir = current_dir.parent.parent / 'sql'
    return str(sql_dir / sql_file_name)
