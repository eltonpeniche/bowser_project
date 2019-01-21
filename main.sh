
#!/bin/bash
master="LABCOMP2-PC01"
netmask="255.255.255.0" 
gateway="192.168.100.1"
rede="192.168.100.0/24"
adpt="enp0s8"
cam=$(pwd)


sudo apt install net-tools
sudo apt update
sudo apt install build-essential manpages-dev -y
#sudo apt install arp-scan -y

#pesquisar se make faz parte do pacote acima
#sudo apt install make

mudarNome(){
	echo "--------------OPÇÃO(1/8)------------------"
	echo "------ALTERANDO O NOME DO HOST------------"
	sleep 2
	echo "NOME DA MÁQUINA:" 
	read -p "QUAL O NOME DA MAQUINA? " nomeMaquina
	echo "$nomeMaquina" | sudo tee /etc/hostname
}

#mudarIP(){
#	echo "----------------OPÇÃO(2/8)----------------"
#	echo "------CONFIGURANDO O IP DO HOST ----------"
#	sleep 2
#	
#	read -p "QUAL É O ENDEREÇO DE IP? " address
#	sudo sed -i '4,8d' /etc/network/interfaces
#	echo "auto $adpt" | sudo tee -a /etc/network/interfaces
#	echo "iface $adpt inet static" | sudo tee -a /etc/network/interfaces
#	echo "	address $address" | sudo tee -a /etc/network/interfaces
#	echo "	netmask $netmask" | sudo tee -a /etc/network/interfaces
#	echo "	gateway $gateway" | sudo tee -a /etc/network/interfaces
#
#	sudo ip addr flush $adpt
#	sudo systemctl restart networking.service
#}

configurarArquivoHosts(){
	echo "---------------OPÇÃO(3/8)-----------------"
	echo "CONFIGURANDO O ARQUIVO /etc/hosts         "
	sudo python3 main.py
	sleep 2
}

instalarNFS(){
	echo "---------------Passo(4/8)-----------------"
	echo "----------- Instalando o NFS--------------"
	sleep 2
	read -p "A maquina é slave(1) ou master(0)? " ms
	echo ""

	#+--------------Configuração do(s) slave(s)------------------------+
	if [ $ms -eq 1 ]; then
		
		sudo apt install nfs-common -y
		# criando o ponto de montagem
		#sudo mount $master:/home/$USER /home/$USER
		echo "$master:/home/$USER /home/$USER nfs" | sudo tee -a /etc/fstab
		# Agora vamos verificar se as pastas foram montadas corretamente
		sudo mount -a
		#echo ""
		df –h
		

	#== ============Configuração do Master==============================

	elif [ $ms -eq 0 ]; then
		
		sudo apt-get install nfs-server -y
		#Agora vamos editar o arquivo /etc/exports	
		echo "/home/$USER *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
		sudo service nfs-kernel-server restart
		sudo exports -a
		sudo ufw allow from $rede
		source ~/.bashrc
		
	fi
	sleep 5
}

instalarSSH(){
	echo "-------------Passo(5/8)------------------"
	echo "-----------Instalando o SSH--------------"
	sleep 2
	
	#== ============Configuração do slave==============================
	if [ $ms -eq 1 ]; then
		sudo apt install openssh-server -y
		
	#== ============Configuração do Master==============================

	elif [ $ms -eq 0 ]; then
		sudo apt install openssh-client -y
		sudo apt install clusterssh -y
		ssh-keygen
		cd ~/.ssh
		ssh-copy-id -i id_rsa.pub localhost
		
	fi
	sleep 5
}

instacaoOpenMpi(){
	echo ""
	echo "-----------Passo(6/7)--------------------"
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
	source ~/.bashrc
	sudo rm -Rf ~/Documentos/openmpi-3.1.2 openmpi-3.1.2.tar.gz

	which mpicc
	which mpirun
	sleep 3

}

opcao=14
while [ $opcao -ne 8 ]; do
	
	echo ""
	echo " CONFIGURAR O NOME DA MÁQUINA---------------(1)"
	#echo " CONFIGURAR O IP DO COMPUTADOR--------------(2)"
	echo " CONFIGURAR O ARQUIVO /etc/hosts------------(2)"
	echo " INSTALAR E CONFIGURAR O NFS----------------(3)"
	echo " INSTALAR E CONFIGURAR o SSH----------------(4)"	
	echo " INSTALAR E CONFIGURAR  O OPEN MPI----------(5)"	
	echo " TODAS AS OPÇÕES----------------------------(6)"	
	echo " SAIR---------------------------------------(0)"
	read -p "escolha uma opção de 0 a 8:  " opcao


	if [ $opcao -eq 1 ]; then
		mudarNome	
	#elif [ $opcao -eq 2 ]; then
	#	mudarIP	
	elif [ $opcao -eq 2 ]; then
		configurarArquivoHosts
	elif [ $opcao -eq 3 ]; then
		instalarNFS
	elif [ $opcao -eq 4 ]; then
		instalarSSH	
	elif [ $opcao -eq 5 ]; then
		instacaoOpenMpi	
	elif [ $opcao -eq 6 ]; then
		#mudarNome
		configurarArquivoHosts
		instacaoOpenMpi
		instalarNFS	
		instalarSSH
		#mudarIP
	elif [ $opcao -eq 0 ]; then
		echo ""
		echo "Cluster Beowulf concluído com sucesso!"
		echo ""
		break
	else
		echo "ERRO! TENTE NOVAMENTE..!!"
	fi

done
