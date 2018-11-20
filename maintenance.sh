#!/bin/bash

# AUTHOR  = FNKOC
# GITHUB  = https://github.com/fnk0c
# LICENCE = GPLv2

check(){
	# Check user ID
	# Checa ID do usuário

	# Command id returns a lot of unwanted information. So we used _cut_.
	# Comando id retorna muitas informações desnecessárias. Por isso, usamos o _cut_.
	get_id=`id | cut -d "=" -f2 | cut -d "(" -f1`
	# User must be root
	# Usuário deve ser _root_
	if [ $get_id -ne 0 ]
	then
		echo "[FAILED] Run with sudo"
		exit
	fi
}

att(){
	# Update system (CentOS)
	# Atualiza sistema (CentOS)

	data=`date +"%d-%m-%y %R"`
	# -y to assume _yes_ to all the questions and _-q_ to keep it silent
	# -y para assumir _sim_ para todas as perguntas e _-q_ para que seja silencioso
	yum update -y -q
	# Generate log output
	# Gera log de saída
	echo "[$data] Atualização realizada " >> /var/log/maintenance.log
}

backup(){
	# Make backup of blog, site and project page
	# Faz backup do blog, site e página de projeto
	
	# Declare variables
	# Declara variáveis
	mysql_passwd="mysql passwd"
	mysql_user="mysql user"
	wp_db="mysql database"
	blog_dir="/home/cienciahacker/blog"
	site_dir="/home/cienciahacker/site"

	date=`date +%d-%m-%y`
	# Wrap everything up and send the output to /dev/null
	# Empacota tudo e manda a saída para /dev/null
	tar -zcf blog_dir.tar.gz $blog_dir &> /dev/null
	tar -zcf site_dir.tar.gz $site_dir &> /dev/null
	# mysqldump to backup mysql database
	# mysqldump para fazer backup do banco de dados mysql
	`mysqldump -u $mysql_user -p$mysql_passwd $wp_db >> wp_db.sql` &> /dev/null
	# Join all packages into a single package
	# Unifica todos os pacotes em um único
	tar -zcf bkp_ch_$date.tar.gz blog_dir.tar.gz site_dir.tar.gz wp_db.sql &> /dev/null
	# Remove unwanted packages
	# Remove pacotes indesejados
	rm *_dir.tar.gz wp_db.sql
	# Move to backup directory
	# Move para diretório de backup
	mv bkp_ch_*.tar.gz /home/cienciahacker/backup

	data=`date +"%d-%m-%y %R"`
	# Generate log output
	# Gera log de saída
	echo "[$data] Backup realizado " >> /var/log/maintenance.log
}

site_status(){
	# Check if site is available
	# Verifica se o site está disponível
	
	# Error message
	# Mensagem de erro
	message="Eita giovana"
	# Pages being watched
	# Paginas sendo assistidas
	pages='https://cienciahacker.ch https://blog.cienciahacker.ch'
	
	while [ 1 = 1 ]
	do
		for i in $pages
		do
			# Retrieve HTML and parse it
			# Coleta HTML e filtra
			html=`curl -s $i | grep -i "$message"`
			data=`date +"%d-%m-%y %R"`

			# If offline, restart services
			# Se offline, reinicia serviços
			if [ "$html" != "" ]
			then
				systemctl restart mariadb
				systemctl restart httpd
				echo "[$data] $i Indisponivel" >> /var/log/maintenance.log
				echo "[$data] Servicos reiniciados" >> /var/log/maintenance.log
			else
				continue
			fi
		done
		# Sleeps for 300 seconds
		# Aguarda 300 segundos
		sleep 300
	done
}

start(){
	check
	site_status & echo $! >> /var/run/maintenance.pid
	while [ 1 = 1 ]
	do
		att & 
		backup & 
		sleep 259200 # 3 days || 3 dias
	done

}

stop(){
	for i in `cat /var/run/maintenance.pid`
	do
		kill $i
	done

	rm -rf /var/run/maintenance.pid
	echo "[+] Service Stopped"
}

status(){
	if [ -e /var/run/maintenance.pid ]
	then
		echo "[+] Service is running"
	else
		echo "[+] Service is not running"
	fi
}

case $1 in
	start)
		start & echo $! > /var/run/maintenance.pid
		sleep 5
		echo "[+] Service started"
		disown
	;;

	stop)
		stop
	;;

	status)
		status
	;;

	restart)
		stop
		start
	;;

	*)
		echo ""
		echo "Usage: maintenance {start|stop|status|restart}"
	;;
esac
