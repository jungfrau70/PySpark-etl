#!/bin/bash
cd /usr/local
rm -rf spark*
yum install -y wget
wget https://archive.apache.org/dist/spark/spark-2.4.8/spark-2.4.8-bin-hadoop2.7.tgz --no-check-certificate
tar -xzf spark-2.4.8-bin-hadoop2.7.tgz
rm -rf spark-2.4.8-bin-hadoop2.7.tgz
ln -s spark-2.4.8-bin-hadoop2.7 spark

#wget https://dlcdn.apache.org/spark/spark-3.1.3/spark-3.1.3-bin-hadoop2.7.tgz --no-check-certificate
#tar -xzf spark-3.1.3-bin-hadoop2.7.tgz
#ln -s spark-3.1.3-bin-hadoop2.7 spark
#rm -rf spark-3.1.3-bin-hadoop2.7.tgz