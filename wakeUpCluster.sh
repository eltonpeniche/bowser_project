#!/bin/bash

# Variável com o mac das máquinas
macs=(${macs[@]} `cat ~/macs`)
for mac in ${macs[@]:1}
do
    wakeonlan $mac
done


