#Java
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.322.b06-1.el7_9.x86_64/jre
export PATH=${JAVA_HOME}/bin:${PATH}

#Python
export PYTHON_HOME=/usr
#export PYTHON_HOME=/opt/conda
export PATH=${PATH}:${PYTHON_HOME}/bin

#Hadoop
export HADOOP_HOME=/opt/hadoop
export HADOOP_INSTALL=${HADOOP_HOME}
export HADOOP_MAPRED_HOME=${HADOOP_HOME}
export HADOOP_COMMON_HOME=${HADOOP_HOME}
export HADOOP_HDFS_HOME=${HADOOP_HOME}
export YARN_HOME=${HADOOP_HOME}
export HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_HOME}/lib/native
export PATH=${PATH}:${HADOOP_HOME}/sbin:${HADOOP_HOME}/bin
export HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib/native"

export YARN_HOME=/opt/hadoop
export YARN_OPTS="-Xmx1g"
export YARN_CONF_DIR=/opt/hadoop/etc/hadoop
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root

#Hive
export HIVE_HOME=/opt/hive
export PATH=${PATH}:${HIVE_HOME}/bin

#Spark
export SPARK_LOCAL_IP=127.0.0.1
export SPARK_HOME=/usr/local/spark
export SPARK_MASTER=spark://master:7077
export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS=notebook
export SPARK_WORKER_CORES=1
export SPARK_WORKER_MEMORY=1G
export SPARK_DRIVER_MEMORY=1G
export SPARK_EXECUTOR_MEMORY=1G
export SPARK_WORKLOAD=worker
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/hadoop/lib/native
export PATH=${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:
