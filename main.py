# Importar modulo do sistema operacional
import os

NT = 15
rede = os.popen("hostname -I").readline()[:3]

def setX():
    os.system("sudo arp-scan -l > ips.txt")

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
    #os.system("sudo rm -Rf ips.txt")

    return x;

def setY():
        
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
    
    return y;


def join_XY(x, y):
    #cria uma lista com o ip e nome do host a partir das litas X e Y
    aux = list(y)
    lista = []
    for i in y:
        for j in x:
            if len(aux) == 1:
                return [lista, aux]
            if(i[0]==j[1]):
                if i in aux:
                    lista.append([j[0],i[1]])
                    aux.remove(i)
              
                    
    return [lista, aux]

#como o comando "arp-scan" não traz o endereço na maquina local
#este comando é usado para pegar o nome e ip do host local
lista3 = [[os.popen("hostname -I").readline().rstrip('\n '), os.popen("hostname").readline().rstrip('\n ')]]

y = setY()
x = setX()
l, aux = join_XY(x,y)
lista3.extend(l)

#compara com "1", devido ao IP do computador local não ser localizado
if len(aux) > 1:
    while(len(aux) > 1 and NT >=1):
<<<<<<< HEAD
        #print("tentando", aux[1:])
        x = setX()
        l, aux2 = join_XY(x, aux)
=======
        x = setX()
        l, aux2 = join_XY(x, aux)
        if l not in lista3: lista3.extend(l)
>>>>>>> 2d8466493d3f9aa85e62595a513c121ce58da086
        aux = list(aux2)
        if l not in lista3: lista3.extend(l)
        NT-=1
            

#grava no arquivo host a lista3 (contém IP + NOME DO COMPUTADOR)
arq = open('hosts', 'w')
arq.writelines('127.0.0.1	localhost' + '\n\n')
for i in lista3:
	arq.writelines(i[0]+ ' ' +i[1] + '\n')
arq.close()

<<<<<<< HEAD
print("sucesso")
=======
#os.system("sudo mv hosts /etc/hosts")
print(len(lista3))
>>>>>>> 2d8466493d3f9aa85e62595a513c121ce58da086
for i in lista3:
    print(i)
#os.system("sudo mv hosts /etc/hosts")

"""
#lista de hosts disponiveis 
arq = open('hosts', 'w')
for i in lista3:
	arq.writelines(i[1] + '\n')
arq.close()
os.system("sudo mv hosts ~/hosts")
"""
