
#!/bin/bash
master="LABCOMP2-PC01"
user="mpiuser"
rede="192.168.100.0/24"
cam=$(pwd)
grupo="cluster"

sudo apt install net-tools
sudo apt update
sudo apt install build-essential manpages-dev -y
sudo apt install arp-scan -y

clear
ms=3


criarUsuario(){
	echo "---------------Passo(1/5)-----------------"
	echo "------------CRIANDO USUÁRIO---------------"
	sleep 2	
	sudo adduser $user --uid 999
	sudo groupadd $grupo
	sudo gpasswd -a $user $grupo

	sleep 2
}

configurarArquivoHosts(){
	echo "---------------Passo(1/4)-----------------"
	echo "---CONFIGURANDO O ARQUIVO /etc/hosts------"
	sleep 2
	
	echo "$user ALL=NOPASSWD: /usr/sbin/arp-scan/" | sudo tee -a /etc/sudoers
    echo "$user ALL=NOPASSWD: /bin/mv, /bin/cp, /bin/rm" | sudo tee -a /etc/sudoers
    echo "$user ALL=NOPASSWD: /usr/bin/python3" | sudo tee -a /etc/sudoers
    echo "$user ALL=NOPASSWD: /sbin/reboot, /sbin/shutdown" | sudo tee -a /etc/sudoers

	python3 main.py
	
	sudo chown -R root:$grupo /etc/hosts
	sudo chmod -R g+rw /etc/hosts
	
	sleep 2
}


clear
instalarNFS(){
	echo "---------------Passo(2/4)-----------------"
	echo "----------- Instalando o NFS--------------"
	sleep 2

	sudo apt install nfs-common -y
	# criando o ponto de montagem
	echo "$master:/home/$user/Bowser /home/$user/Bowser nfs" | sudo tee -a /etc/fstab
	echo "$master:/home/$user/.ssh /home/$user/.ssh nfs" | sudo tee -a /etc/fstab
	
	#sudo mount -a
	
	sleep 5
}

instalarSSH(){
	echo "-------------Passo(3/4)------------------"
	echo "-----------Instalando o SSH--------------"
	sleep 2

	sudo apt install openssh-server -y
		
	sleep 5
}

instacaoOpenMpi(){
	echo ""
	echo "-----------Passo(4/4)--------------------"
	echo "------Instalando o OPEN MPI--------------"
	sleep 2
	cp $cam/openmpi-4.0.0.tar.gz ~/Documentos
	cd ~/Documentos
	tar -vzxf openmpi-4.0.0.tar.gz
	cd openmpi-4.0.0
	./configure --enable-orterun-prefix-by-default
	sudo make all install

	echo 'export PATH=/usr/local/bin:$PATH' | sudo tee -a /etc/bash.bashrc
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' | sudo tee -a /etc/bash.bashrc
	
	sudo rm -Rf ~/Documentos/openmpi-4.0.0 ~/Documentos/openmpi-4.0.0.tar.gz
                
	sleep 3

}


while true; do
	
	echo ""
	echo " Criar usuário------------------------------(1)"
	echo " CONFIGURAR O ARQUIVO /etc/hosts------------(2)"
	echo " INSTALAR E CONFIGURAR O NFS----------------(3)"
	echo " INSTALAR E CONFIGURAR o SSH----------------(4)"	
	echo " INSTALAR E CONFIGURAR  O OPEN MPI----------(5)"	
	echo " TODAS AS OPÇÕES----------------------------(6)"	
	echo " SAIR---------------------------------------(0)"
	read -p "escolha uma opção de 0 a 6:  " opcao
	clear

	if [ $opcao -eq 1 ]; then
		criarUsuario
	elif [ $opcao -eq 2 ]; then
		configurarArquivoHosts
	elif [ $opcao -eq 3 ]; then
		instalarNFS
	elif [ $opcao -eq 4 ]; then
		instalarSSH	
	elif [ $opcao -eq 5 ]; then
		instacaoOpenMpi	
	elif [ $opcao -eq 6 ]; then
        criarUsuario
        configurarArquivoHosts
		instalarNFS	
		instalarSSH
		instacaoOpenMpi
	elif [ $opcao -eq 0 ]; then
		break
	else
		echo "OPÇÃO INVÁLIDA! TENTE NOVAMENTE..!!"
	fi

done
