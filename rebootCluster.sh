#!/bin/bash

# Usuário remoto
user='bowser'

# Variável com a lista de máquinas
hosts=(LABCOMP2-PC02 LABCOMP2-PC03)

for host in ${hosts[@]}
do
    echo 'Desligando todas as máquinas'
    ssh -t $user@$host 'sudo reboot'
    echo -e '\n\n'
done


