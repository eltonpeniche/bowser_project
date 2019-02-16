#!/bin/bash

# Variável com o mac das máquinas
macs=(${macs[@]} `cat ~/.Cluster.config/mac_host.txt`)
len=${#macs[*]}

for ((i=2;i<len;i+=2))
do
    wakeonlan ${macs[i]}
done
