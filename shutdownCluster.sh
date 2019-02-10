#!/bin/bash


# Variável com a lista de máquinas
hosts=(${hosts[@]} `cat ~/hosts`)

for host in ${hosts[@]:1}
do
    echo "Desligando o $host"
    ssh -t $USER@$host 'sudo shutdown now'
    echo '\n'
done


