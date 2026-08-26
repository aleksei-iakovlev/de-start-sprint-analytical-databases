from pathlib import Path
from airflow.decorators import dag, task
import pendulum
from airflow.providers.vertica.hooks.vertica import VerticaHook


LOCAL_DIR = Path("/data")


@dag(
        schedule_interval=None,
        start_date=pendulum.parse("2022-07-13"),
        catchup=False,
        tags=["staging"],
)
def sprint6_dag_load_to_stg():

    @task(task_id='load_users')
    def users_load_to_stg():
        filename = LOCAL_DIR / 'users.csv'
        hook = VerticaHook(vertica_conn_id="conn_usr")
        hook.run(f"""
            COPY VT260818936815__STAGING.users (id,chat_name,registration_dt,country,age)
            FROM LOCAL '{filename}'
            DELIMITER ','
            REJECTED DATA '/data/users_rejected.log';
        """)

    @task(task_id='load_groups')
    def groups_load_to_stg():
        filename = LOCAL_DIR / 'groups.csv'
        hook = VerticaHook(vertica_conn_id="conn_usr")
        hook.run(f"""
            COPY VT260818936815__STAGING.groups (id,admin_id,group_name,registration_dt,is_private)
            FROM LOCAL '{filename}'
            DELIMITER ','
            REJECTED DATA '/data/groups_rejected.log';
        """)

    @task(task_id='load_dialogs')
    def dialogs_load_to_stg():
        filename = LOCAL_DIR / 'dialogs.csv'
        hook = VerticaHook(vertica_conn_id="conn_usr")
        hook.run(f"""
            COPY VT260818936815__STAGING.dialogs (message_id,message_ts,message_from,message_to,message,message_group)
            FROM LOCAL '{filename}'
            DELIMITER ','
            ENCLOSED BY '"'
            NO ESCAPE
            REJECTED DATA '/data/dialogs_rejected.log';
        """)

    @task(task_id='load_group_log')
    def group_log_load_to_stg():
        filename = LOCAL_DIR / 'group_log.csv'
        hook = VerticaHook(vertica_conn_id="conn_usr")
        hook.run(f"""
            COPY VT260818936815__STAGING.group_log (group_id,user_id,user_id_from,event,datetime)
            FROM LOCAL '{filename}'
            DELIMITER ','
            ENCLOSED BY '"'
            NO ESCAPE
            REJECTED DATA '/data/group_log_rejected.log';
        """)

    users_load_to_stg()
    groups_load_to_stg()
    dialogs_load_to_stg()
    group_log_load_to_stg()


dag = sprint6_dag_load_to_stg()
