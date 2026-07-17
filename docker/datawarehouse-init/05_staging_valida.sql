-- Tablas de staging para las transformaciones con limpieza/validacion/homologacion
-- (prueba: ETL desde MySQL y PostgreSQL con Lookup + Mapper + rechazos en audit.etl_rechazo)

CREATE TABLE IF NOT EXISTS stg.mysql_reserva_valida (
    numero_reserva VARCHAR(30),
    fecha_hora TIMESTAMP,
    codigo_sucursal VARCHAR(30),
    documento_cliente VARCHAR(30),
    nombre_cliente VARCHAR(150),
    canal_homologado VARCHAR(30),
    descuento NUMERIC(14,2),
    estado VARCHAR(30),
    sistema_origen VARCHAR(30),
    usuario_carga VARCHAR(30),
    fecha_carga TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stg.pg_encuesta_valida (
    id_encuesta_origen BIGINT,
    fecha DATE,
    codigo_sucursal VARCHAR(30),
    nombre_sucursal VARCHAR(150),
    documento_cliente VARCHAR(30),
    puntuacion INTEGER,
    categoria_satisfaccion VARCHAR(30),
    tiempo_espera_minutos INTEGER,
    comentario VARCHAR(300),
    sistema_origen VARCHAR(30),
    usuario_carga VARCHAR(30),
    fecha_carga TIMESTAMP
);
