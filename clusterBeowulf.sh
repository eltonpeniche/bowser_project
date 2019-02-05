
#!/bin/bash
master="LABCOMP2-PC01"
rede="192.168.100.0/24"
cam=$(pwd)


sudo apt install net-tools
sudo apt update
sudo apt install build-essential manpages-dev -y
sudo apt install arp-scan -y

clear
ms=3

configurarArquivoHosts(){
	echo "---------------Passo(1/4)-----------------"
	echo "CONFIGURANDO O ARQUIVO /etc/hosts         "
	sleep 2
	if [ $ms -eq 3 ]; then
		read -p "A maquina é slave(1) ou master(0)? " ms
		echo ""
	fi	

	#== ============Configuração do Slave==============================
	if [ $ms -eq 1 ]; then
		python3 main.py
		
	#== ============Configuração do Master=======================

	elif [ $ms -eq 0 ]; then

		echo "$USER ALL=NOPASSWD: /usr/sbin/arp-scan/" | sudo tee -a /etc/sudoers
	    echo "$USER ALL=NOPASSWD: /bin/mv" | sudo tee -a /etc/sudoers
	    echo "$USER ALL=NOPASSWD: /bin/cp" | sudo tee -a /etc/sudoers
	    echo "$USER ALL=NOPASSWD: /bin/rm" | sudo tee -a /etc/sudoers
	    echo "$USER ALL=NOPASSWD: /usr/bin/python3" | sudo tee -a /etc/sudoers
	    echo "$USER ALL=NOPASSWD: /sbin/reboot" | sudo tee -a /etc/sudoers
		
		python3 main.py
		chmod a+x startCluster.sh
		sudo cp startCluster.sh /usr/bin
	
	fi

	sleep 2
}


clear
instalarNFS(){
	echo "---------------Passo(2/4)-----------------"
	echo "----------- Instalando o NFS--------------"
	sleep 2
	read -p "A maquina é slave(1) ou master(0)? " ms
	echo ""

	#+--------------Configuração do(s) slave(s)------------------------+
	if [ $ms -eq 1 ]; then
		
		sudo apt install nfs-common -y
		# criando o ponto de montagem
		#sudo mount $master:/home/$USER /home/$USER
		echo "$master:/home/$USER/Bowser /home/$USER/Bowser nfs" | sudo tee -a /etc/fstab
		echo "$master:/home/$USER/.ssh /home/$USER/.ssh nfs" | sudo tee -a /etc/fstab
		# Agora vamos verificar se as pastas foram montadas corretamente
		sudo mount -a
		#echo ""
		#df –h
		

	#== ============Configuração do Master==============================

	elif [ $ms -eq 0 ]; then
		
		sudo apt-get install nfs-server -y
		#Agora vamos editar o arquivo /etc/exports
		mkdir /home/$USER/Bowser
		mkdir /home/$USER/.ssh
        echo "/home/$USER/Bowser *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
        echo "/home/$USER/.ssh *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
		sudo service nfs-kernel-server restart
		#sudo exports -a
		sudo ufw allow from $rede
		source ~/.bashrc
		
	fi
	sleep 5
}

instalarSSH(){
	echo "-------------Passo(3/4)------------------"
	echo "-----------Instalando o SSH--------------"
	sleep 2
	if [ $ms -eq 3 ]; then
		read -p "A maquina é slave(1) ou master(0)? " ms
		echo ""
	fi	

	#+--------------Configuração do(s) slave(s)------------------------+
	if [ $ms -eq 1 ]; then
		sudo apt install openssh-server -y
		
	#== ============Configuração do Master==============================

	elif [ $ms -eq 0 ]; then
		sudo apt-get install openssh-client openssh-server -y
        #sudo apt install openssh-client -y
		sudo apt install clusterssh -y
		ssh-keygen
		cd ~/.ssh
		ssh-copy-id -i id_rsa.pub localhost

	fi

	sleep 5
}

instacaoOpenMpi(){
	echo ""
	echo "-----------Passo(4/4)--------------------"
	echo "------Instalando o OPEN MPI--------------"
	sleep 2
	cp $cam/openmpi-3.1.2.tar.gz ~/Documentos
	cd ~/Documentos
	tar -vzxf openmpi-3.1.2.tar.gz
	cd openmpi-3.1.2
	./configure --enable-orterun-prefix-by-default   
	make;sudo make install

	echo 'export PATH=/usr/local/bin:$PATH' | sudo tee -a ~/.bashrc
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' | sudo tee -a ~/.bashrc
	
	sudo rm -Rf ~/Documentos/openmpi-3.1.2 ~/Documentos/openmpi-3.1.2.tar.gz
                
	which mpicc
	which mpirun
	sleep 3

}


while true; do
	
	echo ""
	echo " CONFIGURAR O ARQUIVO /etc/hosts------------(1)"
	echo " INSTALAR E CONFIGURAR O NFS----------------(2)"
	echo " INSTALAR E CONFIGURAR o SSH----------------(3)"	
	echo " INSTALAR E CONFIGURAR  O OPEN MPI----------(4)"	
	echo " TODAS AS OPÇÕES----------------------------(5)"	
	echo " SAIR---------------------------------------(0)"
	read -p "escolha uma opção de 0 a 5:  " opcao
	clear


	if [ $opcao -eq 1 ]; then
		configurarArquivoHosts
	elif [ $opcao -eq 2 ]; then
		instalarNFS
	elif [ $opcao -eq 3 ]; then
		instalarSSH	
	elif [ $opcao -eq 4 ]; then
		instacaoOpenMpi	
	elif [ $opcao -eq 5 ]; then
		instacaoOpenMpi
        configurarArquivoHosts
		instalarNFS	
		instalarSSH
	elif [ $opcao -eq 0 ]; then
		break
	else
		echo "ERRO! TENTE NOVAMENTE..!!"
	fi

done
