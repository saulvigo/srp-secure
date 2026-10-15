#!/bin/bash
# setup-network.sh - Configuración de red del Bastión

echo "Configurando red del Bastión..."

# Configurar interfaz ens18 (red management)
ip addr add 192.168.1.10/24 dev ens18
ip link set ens18 up

# Configurar interfaz ens19 (red de clientes)
ip addr add 172.16.1.254/24 dev ens19
ip link set ens19 up

# Activar forwarding
sysctl -w net.ipv4.ip_forward=1

# Configurar NAT para que los clientes salgan a internet
iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o ens18 -j MASQUERADE

echo "Red configurada correctamente"