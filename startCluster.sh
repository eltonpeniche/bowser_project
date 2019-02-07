#!/bin/bash


# Variável com a lista de máquinas
hosts=(LABCOMP2-PC02 LABCOMP2-PC03)

cd ~/Documentos/clusterBeowulfProject/
sudo python3 main.py

echo -e '\n'

for host in ${hosts[@]}
do
    echo "Atualizando listas de IPS - $host"
   	scp /etc/hosts $USER@$host:/etc/hosts
done


