# Zabbix – Automatizovaná instalace pomocí Vagrantu (Ubuntu 24.04 + MariaDB + Zabbix Agent 2)

Tento projekt obsahuje automatizovaný deployment Zabbix Serveru 7.0 na Ubuntu 24.04 pomocí Vagrantu a provisioning skriptu.  
Součástí instalace je také MariaDB, Zabbix Agent 2 a kompletní konfigurace webového frontend rozhraní.

---

## 📦 Automatizovaná instalace

Instalace probíhá pomocí shell skriptu, který zajišťuje kompletní nasazení Zabbixu. Níže je popsán přesný postup, který se během provisioning procesu provádí.

### 1. Instalace MariaDB

```bash
apt-get update -y
apt-get install -y mariadb-server
```

### 2. Přidání repozitáře Zabbix 7.0

```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt-get update -y
```

### 3. Instalace Zabbix komponent

Instalují se balíčky:

- zabbix-server-mysql  
- zabbix-frontend-php  
- zabbix-apache-conf  
- zabbix-sql-scripts  
- zabbix-agent2  
- pluginy agent2 (mongodb, mssql, postgresql)

```bash
apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf \
zabbix-sql-scripts zabbix-agent2 zabbix-agent2-plugin-mongodb \
zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql
```

### 4. Vytvoření databáze a uživatele

```bash
mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by 'zabbix_7.0';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;"
```

### 5. Import SQL dat Zabbixu

```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
mysql --default-character-set=utf8mb4 -u zabbix -pzabbix_7.0 zabbix
```

Po importu se log_bin_trust opět vypne:

```bash
mysql -e "set global log_bin_trust_function_creators = 0;"
```

### 6. Úprava konfigurace Zabbix serveru

```bash
sed -i -r 's/# DBPassword=/DBPassword=zabbix_7.0/' /etc/zabbix/zabbix_server.conf
```

### 7. Konfigurace webového rozhraní

```bash
mv /home/vagrant/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php
chown www-data:www-data /etc/zabbix/web/zabbix.conf.php
chmod 400 /etc/zabbix/web/zabbix.conf.php
```

### 8. Spuštění a povolení služeb

```bash
systemctl restart zabbix-server zabbix-agent2 apache2
systemctl enable zabbix-server zabbix-agent2 apache2
```

---

## ▶️ Spuštění prostředí pomocí Vagrantu

Veškerá instalace proběhne automaticky při spuštění příkazu:

```bash
vagrant up
```

### Další užitečné příkazy

```bash
vagrant ssh
vagrant reload
vagrant provision
vagrant destroy -f
```

---

## ✔️ Ověření funkčnosti Zabbixu

### 1. Kontrola běžících procesů

```bash
ps aux | grep zabbix
```

Očekává se běh:

- zabbix_server  
- zabbix_agent2  

### 2. Stav služeb

```bash
systemctl status zabbix-server
systemctl status zabbix-agent2
systemctl status apache2
systemctl status mariadb
```

### 3. Logy

#### Zabbix Server
```bash
tail -f /var/log/zabbix/zabbix_server.log
```

#### Zabbix Agent 2
```bash
tail -f /var/log/zabbix/zabbix_agent2.log
```

#### Apache
```bash
tail -f /var/log/apache2/error.log
```

#### MariaDB
```bash
journalctl -u mariadb -f
```

### 4. Webové rozhraní

Zabbix frontend je dostupný na:

```
http://localhost/zabbix
```

Výchozí přístupové údaje:

- **Uživatel:** Admin  
- **Heslo:** zabbix  

---

## 🟢 Dokončení

Po dokončení instalace provisioning vypíše:

```
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHotovoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```

---


##Konec

Také jsem se pokoušel automaticky naimportovat hosta pomocí [skriptu](Vagrant/hostImport.sh)
Bohužel jsem narazil na problém s autorizací a nepodařilo se mi ho vyřešit :(