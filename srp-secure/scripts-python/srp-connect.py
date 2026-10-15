#!/usr/bin/env python3
"""
srp-connect.py - Herramienta de conexión SSH para SRP Secure
Uso: ./srp-connect.py --servidor NOMBRE --usuario USUARIO
"""

import argparse
import subprocess
import sys
import psycopg2
import os

# Configuración de la base de datos (usa variables de entorno en producción)
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'database': os.environ.get('DB_NAME', 'srp_inventario'),
    'user': os.environ.get('DB_USER', 'zabbix'),
    'password': os.environ.get('DB_PASSWORD', '')
}

def listar_servidores():
    """Lista todos los servidores disponibles con su cliente asociado"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("""
            SELECT s.nombre, s.ip_privada, s.sistema_operativo, c.nombre as cliente
            FROM servidores s
            LEFT JOIN clientes c ON s.cliente_id = c.id
            ORDER BY s.id
        """)
        servidores = cur.fetchall()
        
        print("\n[SRP] SERVIDORES DISPONIBLES")
        print("=" * 60)
        for nombre, ip, so, cliente in servidores:
            cliente_str = f"({cliente})" if cliente else "(interno)"
            print(f"   {nombre:20} -> {ip:15} | {so:12} | {cliente_str}")
        print("=" * 60)
        cur.close()
        conn.close()
    except Exception as e:
        print(f"[ERROR] {e}")

def obtener_datos_servidor(nombre_servidor):
    """Obtiene IP del servidor y del bastión desde la BD"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("""
            SELECT s.ip_privada, s.nombre, b.ip_privada as bastion_ip
            FROM servidores s
            CROSS JOIN (SELECT ip_privada FROM servidores WHERE nombre = 'bastion') b
            WHERE s.nombre = %s
        """, (nombre_servidor,))
        resultado = cur.fetchone()
        cur.close()
        conn.close()
        return resultado
    except Exception as e:
        print(f"[ERROR] Error de base de datos: {e}")
        return None

def registrar_acceso(usuario, servidor_nombre, ip_origen):
    """Registra el acceso en la tabla de auditoría"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("SELECT id FROM servidores WHERE nombre = %s", (servidor_nombre,))
        servidor_id = cur.fetchone()[0]
        cur.execute("""
            INSERT INTO accesos_audit (usuario, servidor_id, ip_origen, accion)
            VALUES (%s, %s, %s, 'CONEXION SSH')
        """, (usuario, servidor_id, ip_origen))
        conn.commit()
        print(f"[OK] Acceso registrado: {usuario} -> {servidor_nombre}")
        cur.close()
        conn.close()
        return True
    except Exception as e:
        print(f"[ERROR] Error al registrar acceso: {e}")
        return False

def conectar_ssh(usuario, bastion_ip, destino_ip):
    """Establece conexión SSH con ProxyJump"""
    print(f"\n[INFO] Conectando a {destino_ip} a través de {bastion_ip}...")
    print("=" * 50)
    comando = ['ssh', '-J', f'{usuario}@{bastion_ip}', f'{usuario}@{destino_ip}']
    try:
        subprocess.run(comando)
    except KeyboardInterrupt:
        print("\n[INFO] Conexión cerrada por el usuario")
    except Exception as e:
        print(f"[ERROR] Error en conexión SSH: {e}")

def main():
    parser = argparse.ArgumentParser(description='SRP Connect - Conexión SSH segura')
    parser.add_argument('--servidor', help='Nombre del servidor destino')
    parser.add_argument('--usuario', default='root', help='Usuario SSH')
    parser.add_argument('--list', action='store_true', help='Listar servidores')
    args = parser.parse_args()
    
    if args.list:
        listar_servidores()
        return
    
    if not args.servidor:
        print("[ERROR] Usa --servidor NOMBRE o --list para ver disponibles")
        sys.exit(1)
    
    datos = obtener_datos_servidor(args.servidor)
    if not datos:
        print(f"[ERROR] Servidor '{args.servidor}' no encontrado")
        sys.exit(1)
    
    destino_ip, servidor_nombre, bastion_ip = datos
    
    print(f"\n[INFO] SRP Connect - Conectando a {servidor_nombre}")
    print(f"   Destino: {destino_ip}")
    print(f"   Vía: {bastion_ip}")
    print(f"   Usuario: {args.usuario}")
    
    registrar_acceso(args.usuario, servidor_nombre, "192.168.1.100")
    conectar_ssh(args.usuario, bastion_ip, destino_ip)

if __name__ == '__main__':
    main()