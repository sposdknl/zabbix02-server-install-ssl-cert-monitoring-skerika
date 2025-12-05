#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y mariadb-server

wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
sudo apt-get update -y

sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent2 zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql

#sudo mysql
#create database zabbix character set utf8mb4 collate utf8mb4_bin;
#create user zabbix@localhost identified by 'zabbix_7.0';
#grant all privileges on zabbix.* to zabbix@localhost;
#set global log_bin_trust_function_creators = 1;
#quit;

sudo mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin; create user zabbix@localhost identified by 'zabbix_7.0'; grant all privileges on zabbix.* to zabbix@localhost; set global log_bin_trust_function_creators = 1;"

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -pzabbix_7.0 zabbix

#sudo mysql
#set global log_bin_trust_function_creators = 0;
#quit;

sudo mysql -e "set global log_bin_trust_function_creators = 0;"

#DBPassword=zabbix_7.0  ### /etc/zabbix/zabbix_server.conf

sed -i -r 's/# DBPassword=/DBPassword=zabbix_7.0/' /etc/zabbix/zabbix_server.conf


###/etc/zabbix/web/zabbix.conf.php #soubor který se vytvori po wizardu



sudo mv /home/vagrant/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php

sudo chown www-data:www-data /etc/zabbix/web/zabbix.conf.php
sudo chmod 400 /etc/zabbix/web/zabbix.conf.php


sudo systemctl restart zabbix-server zabbix-agent2 apache2
sudo systemctl enable zabbix-server zabbix-agent2 apache2 

echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHotovoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
