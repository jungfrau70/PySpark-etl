#!/bin/bash
cd /opt
rm -rf conda*
yum install -y wget bzip2

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p /opt/conda
rm -rf ~/miniconda.sh

/opt/conda/bin/conda install python=3.6

#wget https://repo.continuum.io/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh -O /opt/Anaconda3-5.0.0.1-Linux-x86_64.sh
#bash /opt/Anaconda3-5.0.0.1-Linux-x86_64.sh -b -u -p /opt/conda
#rm -rf /opt/Anaconda3-5.0.0.1-Linux-x86_64.sh