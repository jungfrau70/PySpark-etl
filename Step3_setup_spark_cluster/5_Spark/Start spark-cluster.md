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
# 4. (deploy-server) Hadoop namenode
#########################################################################################

## (If required) Format namenode
./stop-hadoop-cluster.sh && ./stop-spark-cluster.sh

nodes='master worker1 worker2 worker3 worker4'
for node in $nodes
do
    docker exec $node rm -rf /home/hadoop/tmp/
done
docker exec master /opt/hadoop/bin/hdfs namenode -format


#########################################################################################
# 5. (deploy-server) Start Cluster
#########################################################################################

## Start cluster
./start-hadoop-cluster.sh && ./start-spark-cluster.sh

## Check cluster
./check-cluster.sh

## Running process in hadoop/spark cluster
master
1586 Jps
1462 Master
537 NameNode
1083 ResourceManager
780 SecondaryNameNode

worker1~4
339 NodeManager
501 Worker
217 DataNode
604 Jps


#########################################################################################
# 6. (master) Start Hive Server2
#########################################################################################

## Start Hive-server2
docker exec master /opt/hive/bin/hive --service metastore &
docker exec master /opt/hive/bin/hive --service hiveserver2 &
docker exec master ps -ef | grep -i hive


#########################################################################################
# 7. (master) Create directories in hdfs 
#########################################################################################

cat >configure-directories.sh<<EOF
source /opt/hadoop/etc/hadoop/hadoop-env.sh
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
#./configure-directories.sh

docker cp configure-directories.sh $node:/root/
docker exec -it $node /bin/bash /root/configure-directories.sh



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
# 8. Start Jupyter server
#########################################################################################
pip install jupyter_contrib_nbextensions

jupyter notebook --generate-config
jupyter notebook password

cat >/root/.jupyter/jupyter_notebook_config.py<<EOF
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.allow_root = True
EOF

#########################################################################################
# 9. (deploy-server) Stop Cluster
#########################################################################################

./stop-spark-cluster.sh && ./stop-hadoop-cluster.sh 


#########################################################################################
# 10. Backup and restore in VMware Workstation Player
#########################################################################################

Copy folder and rename it
