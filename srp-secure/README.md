# SRP Secure

Plataforma de administración remota segura, monitorización y alta disponibilidad para pymes.

## 🛠 Tecnologías
- Proxmox VE (hipervisor tipo 1)
- Docker / docker-compose
- Zabbix + Grafana (monitorización)
- HAProxy (balanceo de carga)
- PostgreSQL (auditoría)
- Python, Bash, Ansible
- Tailscale (VPN)

## 🏗 Componentes
- Bastión con hardening SSH y túneles ProxyJump
- Clientes simulados en LXC
- Balanceador con 2 servidores web
- Base de datos con 5 tablas (clientes, servidores, auditoría, alertas, incidencias)

## 📜 Scripts incluidos
- `srp-connect.py`: conexión SSH segura con auditoría
- `setup-network.sh`: configuración de red del bastión
- `install-zabbix-agent.sh`: instalación de agente Zabbix
- `backup-srp.sh`: backup automatizado
- Playbooks Ansible

## 👤 Autor
Saúl Rodríguez Parada