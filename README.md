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
