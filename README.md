# airflow-docker-compose-example

Example implementation running Airflow as separate services with docker-compose.

This builds a docker container with a version of airflow that is built from
a specific github repository/branch/commit.  Edit this as you see fit.

## Requirements

- docker
- docker-compose

## Components

- airflow webserver
- airflow scheduler
- airflow flower
- airflow worker
- mysql

## Starting and Stopping the stack

First, make sure you are in the root directory of this repo.

Bring up the stack:
```
$ docker-compose up --force-recreate --build
```

The servers are now available here:

- airflow webserver: http://localhost:8080/
- airflow flower: http://localhost:5555/

Bring the stack down:
```
$ docker-compose down --volumes
```

## Building the Docker container

The Docker image will be built automatically with the command to bring up the
stack, but if you really want to build it manually...

```
$ docker build --tag airflow:github .
```

## Debugging

To get shell in the running docker container, first list the running processes.

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                                        NAMES
668a058847cd        airflow:github      "./wait-for-it.sh air"   About a minute ago   Up About a minute   8080/tcp, 0.0.0.0:5555->5555/tcp, 8793/tcp   airflowdockercomposeexample_airflow_flower_1
5ec419855460        airflow:github      "./wait-for-it.sh air"   About a minute ago   Up About a minute   5555/tcp, 8793/tcp, 0.0.0.0:8080->8080/tcp   airflowdockercomposeexample_airflow_webserver_1
4f4a7eeb8b50        airflow:github      "./wait-for-it.sh air"   About a minute ago   Up About a minute   5555/tcp, 8080/tcp, 8793/tcp                 airflowdockercomposeexample_airflow_worker_1
ab346e581b31        airflow:github      "./wait-for-it.sh db:"   About a minute ago   Up About a minute   5555/tcp, 8080/tcp, 8793/tcp                 airflowdockercomposeexample_airflow_scheduler_1
5e600b8d7e29        redis:3.2           "docker-entrypoint.sh"   About a minute ago   Up About a minute   6379/tcp                                     airflowdockercomposeexample_airflow_redis_1
da2262b20a60        mysql:5.7           "docker-entrypoint.sh"   About a minute ago   Up About a minute   0.0.0.0:3306->3306/tcp                       airflowdockercomposeexample_db_1
```

Now attach to any of the Airflow container processes you want to debug:

```
$ docker exec -it airflowdockercomposeexample_airflow_scheduler_1 bash
airflow@ab346e581b31:~$
```

Start an ipython shell and explore:

```
airflow@ab346e581b31:~$ ipython
Python 3.5.2 |Continuum Analytics, Inc.| (default, Jul  2 2016, 17:53:06) 
Type "copyright", "credits" or "license" for more information.

IPython 5.1.0 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.

In [1]: from airflow import d[2016-12-01 01:24:37,398] {__init__.py:57} INFO - Using executor CeleryExecutor
In [1]: 

In [1]: from airflow import configuration

In [2]: from sqlalchemy import create_engine

In [3]: import pandas as pd

In [4]: engine = create_engine(configuration.get('core', 'SQL_ALCHEMY_CONN'))

In [5]: pd.read_sql("select dag_id, is_active from dag", engine)
Out[5]: 
                                     dag_id  is_active
0                     example_bash_operator          0
1            example_branch_dop_operator_v3          0
2                   example_branch_operator          0
3                     example_http_operator          0
4   example_passing_params_via_test_command          0
5                   example_python_operator          0
6            example_short_circuit_operator          0
7                          example_skip_dag          0
8                   example_subdag_operator          0
9         example_subdag_operator.section-1          0
10        example_subdag_operator.section-2          0
11           example_trigger_controller_dag          0
12               example_trigger_target_dag          0
13                             example_xcom          0
14                              latest_only          0
15                 latest_only_with_trigger          0
16                               test_utils          0
17                                 tutorial          0

```
