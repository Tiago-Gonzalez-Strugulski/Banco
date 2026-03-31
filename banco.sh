#!/bin/bash
# VALIDA A ESTAÇO 
echo > /tmp/alerta.txt
#set -x
echo -e "-------------------------------------------- ALERTA --------------------------------------------\n"  >> /tmp/alerta.txt

#--tempo estimado apos o sitema iniciar
sleep 10
HI=$(date "+%Y-%b-%d %H:%M:%S")

#--Parametros das Variaveis usados no Script
maquina=$(hostname) #Identifica o hostname aonde o script esta rodando
filial=$(hostname | cut -c 4-6) #Filial onde foi rodado
ip=$(hostname -i) #10.x.xx.41 ou 42 Ip cadastrador
iplocal=$(hostname -i | cut -d "." -f2,3) #seta a filial ex: 10.x.xx.xx - (x.xx)

#--Paramentros para Envio de E-mail
MENSAGEM="/tmp/alerta.txt"
EMAIL="pv$filial@automacao.com.br"
DESTINATARIO="tgonzalez@dimed.com.br"

sleep 1
#-- Se a maquina for um Servidor --
if [ "$maquina" = phw$filial"001" ];then

	echo -e "Servidor Filial: $filial IP:$ip \n" >> /tmp/alerta.txt
	echo -e "O Servidor $maquina teve uma interrupcao de energia ou foi reiniciado\n" >> /tmp/alerta.txt

	sleep 1

#-- Caso o servidor for novo com o IP 100 nao ira rodar o script para subir o banco
	if [ $ip = 10.$iplocal.100 ];then
	echo -e "A Maquina e um Servidor novo com o endereco de ip 10.$iplocal.100 em $HI " >> /tmp/alerta.txt
#	echo -e "Servidor $maquina Respondendo na Rede da Filial $filial"
	echo -e "O processo Automatizado para subir o banco ira ter efeito no proximo boot com o ip final 40\n"  >> /tmp/alerta.txt

Envia-email(){
                /usr/dimedbin/SendMail "$DESTINATARIO" "$EMAIL" "Alerta:$maquina" $MENSAGEM
        	     }
(Envia-email)|tee -a /tmp/alerta.txt
		
	sleep 1

	elif [ $ip = 10.$iplocal.40 ];then	
#-- Caso for o ip final 40 da continuidade para rodar o script-
	echo -e " - Servidor com endereco $ip" >> /tmp/alerta.txt
	echo -e " - Iniciando o processo para colocar o banco no Ar -\n" >> /tmp/alerta.txt
#	echo -e " - Processo iniciado na Maquina:$maquina "
	sleep 1
#-- inicia o script para subir o banco como selecionado no menu manutencao	 
#	su - oracle /usr/dimedbin/StartupOracle >> /tmp/alerta.txt
	echo -e "- Aviso o Startup esta comentado para testes na maquina: $maquina !!!" >> /tmp/alerta.txt	
	
	sleep 120

Envia-email(){
                /usr/dimedbin/SendMail "$DESTINATARIO" "$EMAIL" "Alerta:$maquina" $MENSAGEM
             }
(Envia-email)|tee -a /tmp/alerta.txt
sleep 1

	fi	
##-- Se for uma maquina back-up 
elif [ "$maquina" = phw$filial"002" ];then

	echo -e "Estacao Back-up Filial: $filial IP:$ip \n"
	echo -e "Estacao $maquina teve uma interrucao de energia ou foi reiniciado\n" >> /tmp/alerta.txt

	sleep 1
#-- Verificacao de IP VIRTUAL - Para Iniciar o processo do Banco
	ipvirtual=$(ifconfig | grep -o 10.$iplocal.40)

	if [ $? -eq 0 ];then
	
	echo -e " - Detectado IP VIRTUAL 10.$iplocal.40 - " >> /tmp/alerta.txt
	echo -e " * Banco da Filial esta Temporariamente na estacao:$maquina\n" >> /tmp/alerta.txt
	echo -e " - Iniciando o processo para colocar o BANCO NO AR -" >> /tmp/alerta.txt
#-- na condicao de encontrar o ip virtual, roda a linha que esta no menu-manutencao opcao 1, subindo o banco.

#	su - oracle /usr/dimedbin/StartupOracle >> /tmp/EMAIL_ENVIO.txt
	echo -e "- Aviso o Startup esta comentado para testes na maquina: $maquina !!!" >> /tmp/alerta.txt
	else 

	sleep 1
	
	echo -e "Estacao $maquina com o banco standbay  " >> /tmp/alerta.txt

	fi
	sleep 1
Envia-email(){
                /usr/dimedbin/SendMail "$DESTINATARIO" "$EMAIL" "Alerta:$maquina" $MENSAGEM
             }
(Envia-email)|tee -a /tmp/alerta.txt
	
	else

#caso o script seja colocado em outra maquina sem ser a 01 ou 02
	echo -e "O Script esta em uma estcao $maquina e nao realizara qualquer procedimento" >> /tmp/alerta.txt

Envia-email(){
                /usr/dimedbin/SendMail "$DESTINATARIO" "$EMAIL" "Alerta:$maquina" $MENSAGEM
             }
(Envia-email)|tee -a /tmp/alerta.txt

fi

rm /tmp/alerta.txt
