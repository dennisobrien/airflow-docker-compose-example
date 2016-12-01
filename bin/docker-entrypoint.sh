#!/usr/bin/env bash

set -e

# update templates based on environment variables
envtpl -o ${AIRFLOW_HOME}/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg.tpl

if [ "$AIRFLOW_RUNAS_SCHEDULER" = "1" ]; then
    echo "initializing airflow database"
    airflow initdb
    echo "running airflow scheduler"
    while true
    do
        airflow scheduler
        echo "restarting airflow scheduler"
        sleep 1
    done
elif [ "$AIRFLOW_RUNAS_WEBSERVER" = "1" ]; then
    echo "running airflow webserver"
    exec airflow webserver -p 8080
elif [ "$AIRFLOW_RUNAS_WORKER" = "1" ]; then
    echo "running airflow worker"
    exec airflow worker
elif [ "$AIRFLOW_RUNAS_FLOWER" = "1" ]; then
    echo "running airflow flower"
    exec airflow flower
else
    echo "ERROR: no AIRFLOW_RUNAS_* variable set"
    exit 1
fi
