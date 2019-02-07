#!/bin/bash


# Variável com a lista de máquinas
hosts=(LABCOMP2-PC02 LABCOMP2-PC03)

for host in ${hosts[@]}
do
    echo "Reiniciando o $host"
    ssh -t $USER@$host 'sudo reboot'
done


