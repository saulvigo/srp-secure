#!/bin/bash
# backup-srp.sh - Backup automatizado de SRP Secure

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="srp_inventario"
DB_USER="zabbix"

echo "Iniciando backup SRP - $DATE"

# Crear directorios
mkdir -p $BACKUP_DIR/{postgres,configs}

# Backup de PostgreSQL
echo "   Backup de base de datos..."
docker exec zabbix-postgres pg_dump -U $DB_USER $DB_NAME > $BACKUP_DIR/postgres/${DB_NAME}_$DATE.sql
gzip $BACKUP_DIR/postgres/${DB_NAME}_$DATE.sql

# Backup de configuraciones
echo "   Backup de configuraciones..."
tar -czf $BACKUP_DIR/configs/configs_$DATE.tar.gz \
    /etc/netplan/ \
    /etc/haproxy/ \
    /home/saul/srp-tools/srp-connect.py

# Limpiar backups antiguos (más de 30 días)
find $BACKUP_DIR/postgres -type f -mtime +30 -delete
find $BACKUP_DIR/configs -type f -mtime +30 -delete

echo "Backup completado: $DATE"