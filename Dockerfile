FROM ubuntu
MAINTAINER Angel Ramos

ENV PIO_VERSION 0.12.0
ENV SPARK_VERSION 2.1.1
ENV ELASTICSEARCH_VERSION 5.5.2
ENV HBASE_VERSION 1.2.6

ENV PIO_HOME /PredictionIO-${PIO_VERSION}-incubating  
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HOME /home/pio

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl libgfortran3 unzip python-pip nano vim wget openjdk-8-jdk sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -G sudo -c 'MAKI Predictionio user' -m -d ${HOME} -s /bin/bash pio \
    && echo "pio ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/pio \
    && chmod 0440 /etc/sudoers.d/pio

# Cambiamos a un usuario que no sea root
USER pio

## Instala MAKI Predictionio

RUN cd ${HOME} \
    && wget https://github.com/bigdatamx/prediction-maki/releases/download/1.0/PredictionIO-0.12.0-incubating.tar.gz \
    && sudo tar -zxf PredictionIO-0.12.0-incubating.tar.gz -C / \
    && sudo  mkdir -p ${PIO_HOME}/vendors \
    && sudo chmod -R 777 ${PIO_HOME}

COPY files/pio-env.sh ${PIO_HOME}/conf/pio-env.sh

# Instala Spark.
RUN cd ${HOME} \
    && wget http://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.6.tgz \
    && tar zxvfC spark-2.1.1-bin-hadoop2.6.tgz ${PIO_HOME}/vendors \
    && rm spark-${SPARK_VERSION}-bin-hadoop2.6.tgz

USER root

RUN sudo echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 \
    && apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends sbt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER pio

# Instala elastic search.
RUN cd ${HOME} \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
    && tar -xvzf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz -C ${PIO_HOME}/vendors \
    && rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
    && echo 'cluster.name: predictionio' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml \
    && echo 'network.host: 127.0.0.1' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml

# Instala Hbase
RUN cd ${HOME} \
    && curl -O http://apache.mirrors.hoobly.com/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar -xvzf hbase-${HBASE_VERSION}-bin.tar.gz -C ${PIO_HOME}/vendors \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz
COPY files/hbase-site.xml ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml

RUN sed -i "s|VAR_PIO_HOME|${PIO_HOME}|" ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml \
    && sed -i "s|VAR_HBASE_VERSION|${HBASE_VERSION}|" ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml

RUN mkdir ${PIO_HOME}/Enignes

ADD engine-recomendacion-maki-master.zip  ${PIO_HOME}/Enignes

RUN cd ${PIO_HOME}/Enignes \
    && unzip engine-recomendacion-maki-master.zip \
    && rm engine-recomendacion-maki-master.zip

