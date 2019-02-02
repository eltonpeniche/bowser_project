# Importar modulo do sistema operacional
import os

rede = os.popen("hostname -I").readline()[:3]

#os.system("sudo apt install arp-scan -y")
os.system("echo '' > ips.txt")
os.system("sudo arp-scan -l >> ips.txt")

#abre o arquivo que contém o endereço ip e mac dos computadores ativos na rede
# e coloca na lista X
ref_arquivo = open("ips.txt","r")
linha = ref_arquivo.readline()
x = []
while linha:
	if rede in linha:
		valor1, valor2, *_ = linha.split()
		x.append([valor1, valor2])
	linha = ref_arquivo.readline()
ref_arquivo.close()
os.system("sudo rm -Rf ips.txt")

#abre o arquivo que contém o endereço mac e o nome dos computadores ativos na rede
# e os coloca numa lista Y
ref_arquivo = open("mac_host.txt","r")
linha = ref_arquivo.readline()
y = []
while linha:
	valores = linha.split()
	y.append(valores)
	linha = ref_arquivo.readline()
ref_arquivo.close()

#como o comando "arp-scan" não traz o endereço na maquina local
#este comando é usado para pegar o nome e ip do host local
lista3 = [[os.popen("hostname -I").readline().rstrip('\n '), os.popen("hostname").readline().rstrip('\n ')]]

#cria uma lista com o ip e nome do host a partir das litas X e Y
aux = y.copy()  
z = 0
for i in y:
	for j in x:
		if(i[0]==j[1]):
			lista3.append([j[0],i[1]])
			aux.remove(i)
	z+=1

#compara com um devido ao IP do computador local não ser localizado
if len(aux) != 1:	
	#começa do um devido ao IP do computador local não ser localizado
	for i in range(1, len(aux)):
		j = 15
		x = []
		while(x == [] and j >=1):
			x = os.popen("sudo arp-scan -l |grep " + aux[i][0]).readline().split()
			if x != []:
				lista3.append([x[0],aux[i][1]])
			j-=1
else:
	print("Sucesso")
	for i in lista3:
		print(i[0] + " " + i[1])

#grava no arquivo host a lista3 (contém IP + NOME DO COMPUTADOR)
arq = open('hosts', 'w')
arq.writelines('127.0.0.1	localhost' + '\n\n')
for i in lista3:
	arq.writelines(i[0]+ ' ' +i[1] + '\n')
arq.close()

os.system("sudo mv hosts /etc/hosts")
