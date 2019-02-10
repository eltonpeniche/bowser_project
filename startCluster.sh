#!/bin/bash


# Variável com a lista de máquinas

cd ~/.Cluster.config/
sudo python3 main.py

hosts=(${hosts[@]} `cat ~/hosts`)
echo -e '\n'
for host in ${hosts[@]:1}
do
    echo "Atualizando listas de IPS - $host"
	scp /etc/hosts $USER@$host:/etc/hosts
done


