-- Preparar staging
SET client_encoding = 'UTF8';

DROP SCHEMA IF EXISTS stg CASCADE;
CREATE SCHEMA stg;
-- Staging Cine (operacional)
CREATE TABLE IF NOT EXISTS stg.mysql_estudio (
    codigo_estudio VARCHAR(20),
    nombre_estudio VARCHAR(150),
    pais VARCHAR(100),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.mysql_genero (
    codigo_genero VARCHAR(20),
    nombre_genero VARCHAR(150),
    descripcion TEXT,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.mysql_pelicula (
    codigo_pelicula VARCHAR(30),
    titulo VARCHAR(200),
    formato VARCHAR(150),
    codigo_genero VARCHAR(20),
    codigo_estudio VARCHAR(20),
    clasificacion VARCHAR(20),
    activo BOOLEAN,
    costo_proyeccion_referencia NUMERIC(14,2),
    tarifa_referencia_sala NUMERIC(14,2),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.mysql_cliente (
    codigo_cliente VARCHAR(30),
    documento VARCHAR(30),
    nombres VARCHAR(150),
    apellido1 VARCHAR(100),
    apellido2 VARCHAR(100),
    sexo VARCHAR(20),
    fecha_nacimiento DATE,
    ciudad VARCHAR(100),
    correo VARCHAR(200),
    fecha_alta DATE,
    activo BOOLEAN,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.mysql_reserva (
    numero_reserva VARCHAR(30),
    fecha_hora TIMESTAMP,
    sucursal_origen VARCHAR(150),
    documento_cliente VARCHAR(30),
    canal_reserva VARCHAR(50),
    descuento NUMERIC(14,2),
    estado VARCHAR(30),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.mysql_detalle_reserva (
    numero_reserva VARCHAR(30),
    linea INTEGER,
    codigo_pelicula VARCHAR(30),
    cantidad_asientos INTEGER,
    tipo_asiento VARCHAR(30),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.mysql_disponibilidad (
    sucursal_origen VARCHAR(150),
    codigo_pelicula VARCHAR(30),
    funciones_disponibles INTEGER,
    funciones_minimas INTEGER,
    fecha_ultima_funcion DATE,
    fecha_ultimo_movimiento DATE,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staging Gestion
CREATE TABLE IF NOT EXISTS stg.pg_zona (
    codigo_zona VARCHAR(20),
    nombre_zona VARCHAR(100),
    responsable VARCHAR(150),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.pg_sucursal (
    codigo_sucursal VARCHAR(20),
    nombre_sucursal VARCHAR(150),
    codigo_zona VARCHAR(20),
    ciudad VARCHAR(100),
    direccion VARCHAR(250),
    latitud NUMERIC(12,8),
    longitud NUMERIC(12,8),
    fecha_apertura DATE,
    activa BOOLEAN,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.pg_segmento_cliente (
    codigo_segmento VARCHAR(20),
    nombre_segmento VARCHAR(100),
    descripcion TEXT,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.pg_cliente (
    documento VARCHAR(30),
    nombres VARCHAR(150),
    ciudad VARCHAR(100),
    sexo VARCHAR(20),
    fecha_nacimiento DATE,
    codigo_segmento VARCHAR(20),
    fecha_registro DATE,
    correo VARCHAR(200),
    activo BOOLEAN,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.pg_meta_mensual (
    codigo_sucursal VARCHAR(20),
    periodo DATE,
    meta_reservas NUMERIC(14,2),
    meta_clientes INTEGER,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.pg_encuesta_satisfaccion (
    id_encuesta_origen BIGINT,
    fecha DATE,
    codigo_sucursal VARCHAR(20),
    documento_cliente VARCHAR(30),
    puntuacion INTEGER,
    tiempo_espera_minutos INTEGER,
    comentario TEXT,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--Staging Programacion de funciones (Excel)

CREATE TABLE IF NOT EXISTS stg.excel_programacion (
    id_programacion VARCHAR(30),
    numero_programacion VARCHAR(50),
    codigo_copia_distribuidora VARCHAR(50),
    fecha_programacion DATE,
    fecha_estreno_sala DATE,
    fecha_fin_exhibicion DATE,
    codigo_sucursal VARCHAR(20),
    codigo_pelicula VARCHAR(30),
    codigo_distribuidora VARCHAR(30),
    numero_copia VARCHAR(50),
    funciones_programadas INTEGER,
    costo_proyeccion_unitario NUMERIC(14,4),
    subtotal_bruto NUMERIC(14,2),
    porcentaje_descuento NUMERIC(8,4),
    valor_descuento NUMERIC(14,2),
    valor_neto NUMERIC(14,2),
    estado_entrega_copia VARCHAR(30),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.excel_distribuidoras (
    codigo_distribuidora VARCHAR(30),
    nombre_distribuidora VARCHAR(200),
    contacto_ventas VARCHAR(150),
    telefono_contacto VARCHAR(50),
    correo_contacto VARCHAR(200),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.excel_peliculas (
    codigo_pelicula VARCHAR(30),
    titulo VARCHAR(200),
    codigo_genero VARCHAR(150),
    codigo_estudio VARCHAR(150),
    formato VARCHAR(150),
    costo_base NUMERIC(14,4),
    tarifa_referencia NUMERIC(14,4),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS stg.excel_salas (
    codigo_sucursal VARCHAR(20),
    nombre_sucursal VARCHAR(150),
    zona VARCHAR(100),
    ciudad VARCHAR(100),
    direccion VARCHAR(250),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);