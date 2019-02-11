# Importar modulo do sistema operacional
import os

NT = 15
rede = os.popen("hostname -I").readline()[:3]

def quicksort(l):
    if l:
        left = [x for x in l if x[1] < l[0][1]]
        right = [x for x in l if x[1] > l[0][1]]
        if len(left) > 1:
                left = quicksort(left)
        if len(right) > 1:
                right = quicksort(right)
        return left + [l[0]] * l.count(l[0]) + right
    return []

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
    os.system("sudo rm -Rf ips.txt")
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
        #print("tentando", aux[1:])
        x = setX()
        l, aux2 = join_XY(x, aux)
        aux = list(aux2)
        if l not in lista3: lista3.extend(l)
        NT-=1
            

lista3 = quicksort(lista3)
#grava no arquivo host a lista3 (contém IP + NOME DO COMPUTADOR) + 
#lista de hosts disponiveis +

arq = open('hosts', 'w')
arq2 = open('hosts2', 'w')
arq.writelines('127.0.0.1	localhost' + '\n\n')
for i in lista3:
    arq.writelines(i[0]+ ' ' +i[1] + '\n')
    arq2.writelines(i[1] + '\n')

arq.close()
arq2.close()

os.system("sudo mv hosts /etc/hosts")
os.system("mv hosts2 ~/hosts")

#lista de macs disponiveis 
arq = open('macs', 'w')
for i in y:
    arq.writelines(i[0] + '\n')
arq.close()
os.system("mv macs ~/.Cluster.config/macs")
