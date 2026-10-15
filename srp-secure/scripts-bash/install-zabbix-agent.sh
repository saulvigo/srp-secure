#!/bin/bash
# install-zabbix-agent.sh - Instala agente Zabbix en clientes

HOSTNAME=$1
SERVER_IP="192.168.1.20"

if [ -z "$HOSTNAME" ]; then
    echo " Uso: $0 <nombre_host>"
    exit 1
fi

echo "Instalando agente Zabbix para $HOSTNAME..."

# Descargar repositorio
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian13_all.deb
dpkg -i zabbix-release_latest_7.0+debian13_all.deb
apt update

# Instalar agente
apt install -y zabbix-agent2

# Configurar
sed -i "s/^Server=.*/Server=$SERVER_IP/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^ServerActive=.*/ServerActive=$SERVER_IP/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^Hostname=.*/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agent2.conf

# Reiniciar
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2

echo "Agente Zabbix instalado para $HOSTNAME"