from pathlib import Path
from airflow.decorators import dag
from airflow.models import Variable
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
import boto3
import pendulum

LOCAL_DIR = Path("/data")


def fetch_s3_file(bucket: str, key: str):
    aws_access_key_id = Variable.get("AWS_ACCESS_KEY_ID")
    aws_secret_access_key = Variable.get("AWS_SECRET_ACCESS_KEY")

    session = boto3.session.Session()
    s3_client = session.client(
        service_name="s3",
        endpoint_url="https://storage.yandexcloud.net",
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
    )

    local_file = LOCAL_DIR / key
    LOCAL_DIR.mkdir(parents=True, exist_ok=True)

    s3_client.download_file(Bucket=bucket, Key=key, Filename=str(local_file))


bash_command_tmpl = """
{% for file in params.files %}
    echo "=== 10 lines of {{ file }} ==="
    head -n 10 {{ file }}
{% endfor %}
"""

@dag(schedule_interval=None, start_date=pendulum.parse("2022-07-13"), catchup=False)
def sprint6_dag_get_data():
    bucket_files = ["groups.csv", "dialogs.csv", "users.csv", "group_log.csv"]
    download_tasks = []

    for filename in bucket_files:
        task = PythonOperator(
            task_id=f"fetch_{filename}",
            python_callable=fetch_s3_file,
            op_kwargs={"bucket": "sprint6", "key": filename},
        )
        download_tasks.append(task)

    # print_10_lines_of_each = BashOperator(
    #     task_id="print_10_lines_of_each",
    #     bash_command=bash_command_tmpl,
    #     params={"files": [f"{LOCAL_DIR}/{f}" for f in bucket_files]},
    # )
    start = EmptyOperator(
        task_id='start',
    )
    end = EmptyOperator(
        task_id='end',
        )

    start >> download_tasks >> end


dag = sprint6_dag_get_data()
