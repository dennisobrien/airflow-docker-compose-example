# Based on https://github.com/puckel/docker-airflow and https://github.com/Drunkar/dockerfiles/tree/master/airflow
FROM ubuntu:16.04

# Define en_US.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get -y install \
        build-essential \
        git \
        wget \
        curl \
        bzip2 \
        netcat \
        locales \
        ca-certificates \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
        libmysqlclient-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        libkrb5-dev \
        libffi-dev \
        libxml2-dev \
        libxslt-dev

ENV AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_DAGS_WORKSPACE=${AIRFLOW_HOME}/workspace \
    AIRFLOW_DAGS_DIR=${AIRFLOW_HOME}/dags \
    AIRFLOW_FERNET_KEY=some_very_secret_key \
    AIRFLOW_WEBSERVER_SECRET_KEY=some_very_very_secret_key
    
RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    curl https://repo.continuum.io/miniconda/Miniconda3-4.2.11-Linux-x86_64.sh -o ${AIRFLOW_HOME}/conda.sh && \
    /bin/bash ${AIRFLOW_HOME}/conda.sh -b -p /opt/conda && \
    rm ${AIRFLOW_HOME}/conda.sh

ENV PATH /opt/conda/bin:$PATH
COPY config/ ${AIRFLOW_HOME}
COPY bin/ ${AIRFLOW_HOME}
RUN conda install --yes --file ${AIRFLOW_HOME}/requirements-conda.txt \
    && pip install -r ${AIRFLOW_HOME}/requirements-pip.txt \
    && conda clean -i -l -t -y

#
# Install Airflow from the list of available options:
#
# 1. Uncomment to pip install from an official release
#RUN pip install airflow[celery,crypto,hive,jdbc,ldap,password,postgres,s3,vertica]==1.8.0
#
# 2. Uncomment to pip install from a github repo/branch/commit.  YMMV.
#
RUN pip install -e git://github.com/apache/incubator-airflow.git@310fb589ae867ff2ec8b7ce3cc5b1659db4dad49#egg=airflow[celery,crypto,hive,jdbc,ldap,password,postgres,s3,vertica]
#
# 3. Uncomment to git clone the repo, git checkout a branch, git reset to a commit, then build from source.
#
#RUN git clone https://github.com/dennisobrien/incubator-airflow.git airflow_src && \
#      cd airflow_src && \
#      git checkout dennisobrien/gunicorn-forwarded-allow-ips && \
#      git reset --hard 6aef967960207b9d0e472cb84b1112d1dc959139 && \
#      pip install -e .[celery,crypto,hive,jdbc,ldap,password,postgres,s3,vertica]

ENV MATPLOTLIBRC ${AIRFLOW_HOME}/.config/matplotlib/
ADD config/matplotlibrc ${AIRFLOW_HOME}/.config/matplotlib/matplotlibrc
RUN chmod 0644 ${AIRFLOW_HOME}/.config/matplotlib/matplotlibrc

# Uncomment if you want to install your own dags.
#COPY dags/ /usr/local/airflow/dags

RUN chown -R airflow: ${AIRFLOW_HOME} \
    && chmod +x ${AIRFLOW_HOME}/docker-entrypoint.sh \
    && chmod +x ${AIRFLOW_HOME}/wait-for-it.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["./docker-entrypoint.sh"]
