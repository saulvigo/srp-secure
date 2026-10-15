-- Crear base de datos
CREATE DATABASE srp_inventario;
\c srp_inventario;

-- 1. Tabla de clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabla de servidores
CREATE TABLE servidores (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id) ON DELETE CASCADE,
    nombre VARCHAR(50) NOT NULL,
    ip_publica VARCHAR(15),
    ip_privada VARCHAR(15),
    sistema_operativo VARCHAR(50),
    estado VARCHAR(20) DEFAULT 'activo'
);

-- 3. Tabla de auditoría de accesos
CREATE TABLE accesos_audit (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50),
    servidor_id INTEGER REFERENCES servidores(id),
    ip_origen VARCHAR(15),
    accion VARCHAR(50)
);

-- 4. Tabla de alertas
CREATE TABLE alertas (
    id SERIAL PRIMARY KEY,
    servidor_id INTEGER REFERENCES servidores(id),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo VARCHAR(50),
    mensaje TEXT,
    estado VARCHAR(20) DEFAULT 'pendiente'
);

-- 5. Tabla de incidencias
CREATE TABLE incidencias (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    servidor_id INTEGER REFERENCES servidores(id),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prioridad VARCHAR(20) CHECK (prioridad IN ('baja', 'media', 'alta', 'crítica')),
    estado VARCHAR(20) DEFAULT 'abierta',
    descripcion TEXT,
    solucion TEXT,
    fecha_cierre TIMESTAMP
);

-- Índices
CREATE INDEX idx_accesos_servidor ON accesos_audit(servidor_id);
CREATE INDEX idx_accesos_fecha ON accesos_audit(fecha);
CREATE INDEX idx_alertas_servidor ON alertas(servidor_id);
CREATE INDEX idx_alertas_estado ON alertas(estado);
CREATE INDEX idx_incidencias_cliente ON incidencias(cliente_id);
CREATE INDEX idx_incidencias_estado ON incidencias(estado);

-- Datos de ejemplo
INSERT INTO clientes (nombre, contacto, email) VALUES 
('Pizzería La Italiana', 'Giuseppe Romano', 'giuseppe@laitaliana.com'),
('Clínica Dental Sonrisas', 'Dra. Laura Méndez', 'laura@sonrisas.com'),
('Talleres Mecánicos Rápido', 'Antonio Gómez', 'antonio@rapido.es');

INSERT INTO servidores (cliente_id, nombre, ip_privada, sistema_operativo) VALUES 
(1, 'web-pizzeria', '172.16.1.10', 'Ubuntu 22.04'),
(1, 'bd-pizzeria', '172.16.1.11', 'Debian 12'),
(2, 'web-sonrisas', '172.16.1.20', 'Ubuntu 24.04'),
(2, 'bd-sonrisas', '172.16.1.21', 'Debian 12'),
(3, 'gestion-rapido', '172.16.1.30', 'Debian 12'),
(NULL, 'bastion', '192.168.1.10', 'Ubuntu 24.04'),
(NULL, 'admin', '192.168.1.20', 'Ubuntu 24.04'),
(NULL, 'balanceador', '172.16.1.30', 'Debian 12');