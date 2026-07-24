/* =========================================================
   CUBO SATISFACCION DEL CLIENTE
   Proceso de negocio: encuestas de satisfaccion post-atencion
   (distinto del proceso de reservas del cubo tCubo_Reserva)
   Fuente: gestion.encuesta_satisfaccion -> stg.pg_encuesta_valida
   ========================================================= */

/* =========================================================
   DIMENSION CATEGORIA DE SATISFACCION
   Dimension de referencia (enumeracion fija por regla de
   negocio sobre la puntuacion), igual criterio que
   dw.dim_canal y dw.dim_estado_reserva: se siembra por SQL
   en vez de por transformacion de Pentaho.
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_categoria_satisfaccion (
    categoria_satisfaccion_key SMALLSERIAL PRIMARY KEY,
    categoria_satisfaccion VARCHAR(20) NOT NULL,
    rango_puntuacion VARCHAR(10) NOT NULL,
    es_positiva BOOLEAN NOT NULL,

    CONSTRAINT uq_dim_categoria_satisfaccion UNIQUE (categoria_satisfaccion)
);

INSERT INTO dw.dim_categoria_satisfaccion (categoria_satisfaccion, rango_puntuacion, es_positiva) VALUES
    ('Insatisfecho', '1-2', FALSE),
    ('Neutral', '3', FALSE),
    ('Satisfecho', '4-5', TRUE),
    ('SIN_CLASIFICAR', 'N/A', FALSE)
ON CONFLICT (categoria_satisfaccion) DO NOTHING;


/* =========================================================
   TABLA DE HECHOS SATISFACCION
   (grano: una fila por encuesta de satisfaccion)
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.fact_satisfaccion (
    encuesta_key BIGSERIAL PRIMARY KEY,

    id_encuesta_origen BIGINT NOT NULL,

    fecha_encuesta_key INTEGER NOT NULL,
    sucursal_key BIGINT NOT NULL,
    cliente_key BIGINT,
    categoria_satisfaccion_key SMALLINT NOT NULL,

    puntuacion SMALLINT NOT NULL,
    tiempo_espera_minutos INTEGER NOT NULL,
    comentario VARCHAR(300),

    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_fact_satisfaccion_origen UNIQUE (id_encuesta_origen),

    CONSTRAINT fk_fact_satisfaccion_fecha
        FOREIGN KEY (fecha_encuesta_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_satisfaccion_sucursal
        FOREIGN KEY (sucursal_key) REFERENCES dw.dim_sucursal(sucursal_key),
    CONSTRAINT fk_fact_satisfaccion_cliente
        FOREIGN KEY (cliente_key) REFERENCES dw.dim_cliente(cliente_key),
    CONSTRAINT fk_fact_satisfaccion_categoria
        FOREIGN KEY (categoria_satisfaccion_key) REFERENCES dw.dim_categoria_satisfaccion(categoria_satisfaccion_key),

    CONSTRAINT ck_fact_satisfaccion_puntuacion CHECK (puntuacion BETWEEN 1 AND 5),
    CONSTRAINT ck_fact_satisfaccion_espera CHECK (tiempo_espera_minutos >= 0)
);

CREATE INDEX IF NOT EXISTS idx_fact_satisfaccion_fecha ON dw.fact_satisfaccion(fecha_encuesta_key);
CREATE INDEX IF NOT EXISTS idx_fact_satisfaccion_sucursal ON dw.fact_satisfaccion(sucursal_key);
CREATE INDEX IF NOT EXISTS idx_fact_satisfaccion_cliente ON dw.fact_satisfaccion(cliente_key);
CREATE INDEX IF NOT EXISTS idx_fact_satisfaccion_categoria ON dw.fact_satisfaccion(categoria_satisfaccion_key);
