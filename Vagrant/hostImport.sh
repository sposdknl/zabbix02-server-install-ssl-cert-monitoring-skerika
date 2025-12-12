#!/bin/bash

#pokus s nastavenim apache aby prijmul Authorization header - neuspech
#echo 'SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1' | sudo tee -a /etc/apache2/apache2.conf

#pokus s AI - nestihl jsem
echo 'RewriteEngine on' | sudo tee -a /etc/apache2/conf-available/zabbix-authorization.conf
echo 'RewriteCond %{HTTP:Authorization} ^(.*)' | sudo tee -a /etc/apache2/conf-available/zabbix-authorization.conf
echo 'RewriteRule .* - [E=HTTP_AUTHORIZATION:%1]' | sudo tee -a /etc/apache2/conf-available/zabbix-authorization.conf
a2enconf zabbix-authorization
systemctl reload apache2

#pouziti deprecated auth property - nefunguje :(

TOKEN=$(curl --silent --request POST --url 'http://localhost/zabbix/api_jsonrpc.php' -H 'Content-Type: application/json-rpc' --data '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' | jq -r '.result')

curl --request POST --url 'http://localhost/zabbix/api_jsonrpc.php' -H 'Authorization: Bearer $TOKEN' -H 'Content-Type: application/json-rpc' --data '{"jsonrpc": "2.0","method": "configuration.import","params": {"format": "xml","rules": {"hosts": {"createMissing": true,"updateExisting": true}},"source": "<?xml version=\"1.0\" encoding=\"UTF-8\"?><zabbix_export><version>7.0</version><host_groups><host_group><uuid>85b0c8978045457f96dd327a952f1a91</uuid><name>Web Certificate</name></host_group></host_groups><hosts><host><host>sposdk.cz</host><name>sposdk.cz</name><templates><template><name>Website certificate by Zabbix agent 2</name></template></templates><groups><group><name>Web Certificate</name></group></groups><interfaces><interface><interface_ref>if1</interface_ref></interface></interfaces><macros><macro><macro>{$CERT.WEBSITE.HOSTNAME}</macro><value>sposdk.cz</value><description>The website DNS name for the connection.</description></macro></macros><inventory_mode>AUTOMATIC</inventory_mode></host></hosts></zabbix_export>\n"},"id": 1}'

#pokus s odhlasenim - neuspech
#curl --silent --request POST --url 'http://localhost/zabbix/api_jsonrpc.php' -H 'Content-Type: application/json-rpc' --data '{"jsonrpc":"2.0","method":"user.logout","params":[],"id":1}'