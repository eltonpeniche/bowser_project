#!/bin/bash

sudo adduser mpiuser --uid 999
groupadd cluster
gpasswd -a mpiuser cluster
chown -R root:cluster /etc/hosts
chmod -R g+rw /etc/hosts