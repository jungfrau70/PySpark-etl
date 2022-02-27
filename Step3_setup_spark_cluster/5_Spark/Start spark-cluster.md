Prerequsites:
- Centos7
- Docker engine
- SSH server in deploy-server
- Ansible in deploy-server
- Hadoop cluster with yarn
- Hive with postgres metastore
- Spark cluster as standalone


#########################################################################################
# 1. (deploy-server) Preparation to start services
#########################################################################################

export WORKDIR='/root/PySpark/Step3_setup_spark_cluster/5_Spark/'
cd $WORKDIR

## Instanticate the containers
rm -rf db.sql/ postgres-data/ spark-apps/ spark-data
docker-compose up -d

#########################################################################################
# 2. Setup Hive metastore with PostgrSQL 9.2.24
     Now,Lets Set up Postgress Image in the Docker Container
#########################################################################################

docker exec \
    -it hive-postgres \
    psql -U postgres
	
### Createa database "metastore" for hive in postgress.
CREATE DATABASE metastore;
CREATE USER hive WITH ENCRYPTED PASSWORD 'go2team';
GRANT ALL ON DATABASE metastore TO hive;	

\l to list
\q to exit postgress


#########################################################################################
# 3. Initialize Hive
#########################################################################################
## Initialize Hive Metastore
docker exec -it master /bin/bash

/opt/hive/bin/schematool -dbType postgres -initSchema

### if not found:
export HIVE_HOME=/opt/hive
export PATH=$PATH:${HIVE_HOME}/bin

## Validate Metadata Tables
docker exec \
    -it hive-postgres \
    psql -U postgres \
    -d metastore

\d
\q

#########################################################################################
# 4. (deploy-server) Hadoop namenode format 
#########################################################################################

## (if required) Remove data in hadoop-cluster

./stop-hadoop-cluster.sh && ./stop-spark-cluster.sh
nodes='master worker1 worker2 worker3 worker4'
for node in $nodes
do
    docker exec $node rm -rf /home/hadoop/tmp/
done
docker exec master /opt/hadoop/bin/hdfs namenode -format

./start-hadoop-cluster.sh && ./start-spark-cluster.sh


#########################################################################################
# 6. (master) Start Hive Server2
#########################################################################################

## Start Hive-server2
/opt/hive/bin/hive --service metastore &
/opt/hive/bin/hive --service hiveserver2 &
jobs

#########################################################################################
# 7. (master) Create directories in hdfs 
#########################################################################################

cat >configure-directories.sh<<EOF
### create directories for logs and jars in HDFS. 
hdfs dfs -rm -r /spark-jars
hdfs dfs -rm -r /spark-logs

hdfs dfs -mkdir /spark-jars
hdfs dfs -mkdir /spark-logs
hdfs dfs -mkdir -p /apps/hive/warehouse

hdfs dfs -ls /spark-jars
hdfs dfs -ls /spark-logs
hdfs dfs -ls /apps/hive/warehouse

### Copy Spark jars to HDFS folder as part of spark.yarn.jars.
hdfs dfs -put /usr/local/spark/jars/* /spark-jars
hdfs dfs -put /opt/hive/lib/postgresql-42.2.24.jar /spark-jars

hdfs dfs -ls /spark-jars/postgresql-42.2.24.jar
hdfs dfs -ls /spark-jars/mongo-spark-connector_2.11-2.4.0.jar
EOF

chmod u+x configure-directories.sh
./configure-directories.sh


#########################################################################################
# 8. Test Spark cluster
#########################################################################################

docker exec -it master /bin/bash

## Start pyspark

### All the commands(spark-shell,pyspark,spark-submit) are avaiable in:
/usr/local/spark/bin

### Only if hadoop cluster is running
pyspark --master yarn (default)
pyspark --master local

### Only if spark cluster is running
pyspark --master spark://master:7077
pyspark --master local

### Validate Spark using Python 
/opt/spark/bin/pyspark --master (?)

spark.sql('show databases').show()
spark.sql('create database test').show()
spark.sql('use test').show()
spark.sql('create table spark (col1 int)').show()
spark.sql('show tables').show()
spark.sql('insert into spark values(20)')
spark.sql('select * from spark').show() 
exit()

### Validate the custom table location
docker exec -it master /bin/bash
hdfs dfs -ls /apps/hive/warehouse

### Start pyspark with jupyter
set PYSPARK_DRIVER_PYTHON=jupyter
set PYSPARK_DRIVER_PYTHON_OPTS='notebook'

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'

#########################################################################################
# 9. (deploy-server) Stop Cluster
#########################################################################################

./stop-jupyter-server.sh
./stop-hive-server2.sh
./stop-spark-cluster.sh
./stop-hadoop-cluster.sh 

./check-server.sh

#########################################################################################
# 10. Clean up (in deploy-server)
#########################################################################################

cd 

## Remove all data
docker ps -a
docker-compose down

export WORKDIR='/root/PySpark/Step4_setup_airflow_cluster/1_Spark/'
cd $WORKDIR

rm -rf db.sql postgres-data spark-apps spark-data

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker network rm netgroup
docker system prune -a


#########################################################################################
# 11. (deploy-server) Build custom image
#########################################################################################

## Commit Docker image and push to repository
docker ps -a
docker commit master jungfrau70/centos7:de-cluster.102

docker login                                                 
docker push jungfrau70/centos7:de-cluster.102

## Restart docker-compose with lastest docker image
# cd PySpark/Step3_setup_spark_cluster/5_Spark/
# docker-compose down


#########################################################################################
# 12. Backup and restore in VMware Workstation Player
#########################################################################################

Copy folder and rename it
