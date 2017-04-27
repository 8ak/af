#!/bin/bash
echo "AIRFLOW_HOME=/airflow" >> /etc/bash.bashrc
export AIRFLOW_HOME=/airflow

apt-get update -y
apt-get  install -y unzip build-essential python-dev libsasl2-dev python-pandas binutils
apt-get install -y python-pip
pip install --upgrade pip
pip install airflow
pip install airflow[celery]

mkdir ${AIRFLOW_HOME}
mkdir ${AIRFLOW_HOME}/dags
mkdir ${AIRFLOW_HOME}/logs
mkdir ${AIRFLOW_HOME}/plugins

cd ${AIRFLOW_HOME}; airflow initdb

cat <<EOF > ${AIRFLOW_HOME}/stop-webserver-and-scheduler.sh
#!/bin/bash
for pid in $(ps -ef | grep -e "ww" -e airflow | awk '{print $2}'); do kill -9 $pid; done
EOF

cat <<EOF > ${AIRFLOW_HOME}/start-webserver.sh
#!/bin/bash
nohup airflow webserver $* >> ${AIRFLOW_HOME}/webserver.logs &
EOF


cat <<EOF > ${AIRFLOW_HOME}/start-scheduler.sh
#!/bin/bash
nohup airflow scheduler >> ${AIRFLOW_HOME}/scheduler.logs &
EOF

cat <<EOF > ${AIRFLOW_HOME}/dags/demo-03.py
from airflow import DAG
from airflow.operators import BashOperator
from datetime import datetime, timedelta
# Following are defaults which can be overridden later on
default_args = {
    'owner': 'kotikala',
    'depends_on_past': False,
    'start_date': datetime(2017, 4, 23),
    'email': ['onefilmbuff@gmail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}
dag = DAG('demo-dag-03', default_args=default_args)
# t1, t2, t3 and t4 are examples of tasks created using operators
t1 = BashOperator(
    task_id='task_1',
    bash_command='echo "Hello World from Task 1"',
    dag=dag)
t2 = BashOperator(
    task_id='task_2',
    bash_command='echo "Hello World from Task 2"',
    dag=dag)
t3 = BashOperator(
    task_id='task_3',
    bash_command='echo "Hello World from Task 3"',
    dag=dag)
t4 = BashOperator(
    task_id='task_4',
    bash_command='echo "Hello World from Task 4"',
    dag=dag)
t5 = BashOperator(
    task_id='task_5',
    bash_command='echo "Hello World from Task 5"',
    dag=dag)
t6 = BashOperator(
    task_id='task_6',
    bash_command='echo "Hello World from Task 6"',
    dag=dag)
t7 = BashOperator(
    task_id='task_7',
    bash_command='echo "Hello World from Task 7"',
    dag=dag)
t8 = BashOperator(
    task_id='task_8',
    bash_command='echo "Hello World from Task 8"',
    dag=dag)
t9 = BashOperator(
    task_id='task_9',
    bash_command='echo "Hello World from Task 9"',
    dag=dag)
t10 = BashOperator(
    task_id='task_10',
    bash_command='echo "Hello World from Task 10"',
    dag=dag)
t11 = BashOperator(
    task_id='task_11',
    bash_command='echo "Hello World from Task 11"',
    dag=dag)
t2.set_upstream(t1)
t3.set_upstream(t1)
t4.set_upstream(t2)
t5.set_upstream(t3)
t6.set_upstream(t4)
t6.set_upstream(t5)
t7.set_upstream(t6)
t8.set_upstream(t7)
t9.set_upstream(t7)
t10.set_upstream(t7)
t11.set_upstream(t8)
t11.set_upstream(t9)
t11.set_upstream(t10)
EOF

sh ${AIRFLOW_HOME}/start-webserver.sh
sh ${AIRFLOW_HOME}/start-scheduler.sh
