create schema if not exists audit;

CREATE TABLE IF NOT EXISTS audit.etl_rechazo (
    id_rechazo BIGSERIAL PRIMARY KEY,
    fuente VARCHAR(80),
    entidad VARCHAR(80),
    clave_origen VARCHAR(150),
    tipo_error VARCHAR(80),
    descripcion_error TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);