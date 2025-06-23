from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    "owner": "matheus",
    "start_date": datetime(2024, 1, 1),
    "retries": 1,
}

with DAG(
    dag_id="run_pipeline_local",
    default_args=default_args,
    schedule_interval="@daily",
    catchup=False,
    description="Executa a extração e carga de dados com Meltano e Embulk",
    tags=["pipeline", "meltano", "embulk"],
) as dag:

    extract_postgres = BashOperator(
        task_id="extract_postgres",
        bash_command="make -f /opt/airflow/Makefile extract_postgres",
    )

    extract_csv = BashOperator(
        task_id="extract_csv",
        bash_command="make -f /opt/airflow/Makefile extract_csv",
    )

    load_jsonl = BashOperator(
        task_id="load_jsonl",
        bash_command="make -f /opt/airflow/Makefile load_jsonl",
    )

    load_csv_embulk = BashOperator(
        task_id="load_csv_embulk",
        bash_command="make -f /opt/airflow/Makefile load_csv_embulk",
    )

    # Dependências da DAG
    extract_postgres >> load_jsonl
    extract_csv >> load_csv_embulk