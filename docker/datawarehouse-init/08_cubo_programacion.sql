/* =========================================================
   CUBO PROGRAMACION DE FUNCIONES
   Proceso de negocio: programacion de copias de peliculas
   por sucursal y distribuidora
   Fuente: Excel Programacion/Distribuidoras -> stg.excel_programacion,
   stg.excel_distribuidoras
   ========================================================= */

/* =========================================================
   DIMENSION DISTRIBUIDORA
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_distribuidora (
    distribuidora_key BIGSERIAL PRIMARY KEY,
    codigo_distribuidora VARCHAR(30) NOT NULL,
    nombre_distribuidora VARCHAR(200) NOT NULL,
    contacto_ventas VARCHAR(150),
    telefono_contacto VARCHAR(50),
    correo_contacto VARCHAR(200),
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_distribuidora_codigo UNIQUE (codigo_distribuidora)
);


/* =========================================================
   DIMENSION ESTADO DE ENTREGA DE COPIA
   Dimension de referencia (enumeracion fija), igual criterio
   que dw.dim_canal y dw.dim_estado_reserva: se siembra por SQL.
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_estado_entrega (
    estado_entrega_key SMALLSERIAL PRIMARY KEY,
    estado_entrega_copia VARCHAR(20) NOT NULL,
    es_completado BOOLEAN NOT NULL,

    CONSTRAINT uq_dim_estado_entrega UNIQUE (estado_entrega_copia)
);

INSERT INTO dw.dim_estado_entrega (estado_entrega_copia, es_completado) VALUES
    ('RECIBIDO', TRUE),
    ('PENDIENTE', FALSE)
ON CONFLICT (estado_entrega_copia) DO NOTHING;


/* =========================================================
   TABLA DE HECHOS PROGRAMACION
   (grano: una fila por pelicula y copia incluida en una
   programacion)
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.fact_programacion (
    programacion_key BIGSERIAL PRIMARY KEY,

    numero_programacion VARCHAR(50) NOT NULL,
    numero_copia VARCHAR(50) NOT NULL,

    fecha_programacion_key INTEGER NOT NULL,
    fecha_estreno_key INTEGER NOT NULL,
    fecha_fin_exhibicion_key INTEGER NOT NULL,
    sucursal_key BIGINT NOT NULL,
    pelicula_key BIGINT NOT NULL,
    distribuidora_key BIGINT NOT NULL,
    estado_entrega_key SMALLINT NOT NULL,

    funciones_programadas INTEGER NOT NULL,
    costo_proyeccion_unitario NUMERIC(14,4) NOT NULL,
    subtotal_bruto NUMERIC(14,2) NOT NULL,
    porcentaje_descuento NUMERIC(8,4) NOT NULL DEFAULT 0,
    valor_descuento NUMERIC(14,2) NOT NULL DEFAULT 0,
    valor_neto NUMERIC(14,2) NOT NULL,
    dias_hasta_estreno INTEGER,
    dias_hasta_fin_exhibicion INTEGER,

    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_fact_programacion_copia UNIQUE (numero_programacion, numero_copia),

    CONSTRAINT fk_fact_programacion_fecha_prog
        FOREIGN KEY (fecha_programacion_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_programacion_fecha_estreno
        FOREIGN KEY (fecha_estreno_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_programacion_fecha_fin
        FOREIGN KEY (fecha_fin_exhibicion_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_programacion_sucursal
        FOREIGN KEY (sucursal_key) REFERENCES dw.dim_sucursal(sucursal_key),
    CONSTRAINT fk_fact_programacion_pelicula
        FOREIGN KEY (pelicula_key) REFERENCES dw.dim_pelicula(pelicula_key),
    CONSTRAINT fk_fact_programacion_distribuidora
        FOREIGN KEY (distribuidora_key) REFERENCES dw.dim_distribuidora(distribuidora_key),
    CONSTRAINT fk_fact_programacion_estado
        FOREIGN KEY (estado_entrega_key) REFERENCES dw.dim_estado_entrega(estado_entrega_key),

    CONSTRAINT ck_fact_programacion_funciones CHECK (funciones_programadas > 0),
    CONSTRAINT ck_fact_programacion_descuento CHECK (porcentaje_descuento BETWEEN 0 AND 100)
);

CREATE INDEX IF NOT EXISTS idx_fact_programacion_fecha_prog ON dw.fact_programacion(fecha_programacion_key);
CREATE INDEX IF NOT EXISTS idx_fact_programacion_sucursal ON dw.fact_programacion(sucursal_key);
CREATE INDEX IF NOT EXISTS idx_fact_programacion_pelicula ON dw.fact_programacion(pelicula_key);
CREATE INDEX IF NOT EXISTS idx_fact_programacion_distribuidora ON dw.fact_programacion(distribuidora_key);
CREATE INDEX IF NOT EXISTS idx_fact_programacion_estado ON dw.fact_programacion(estado_entrega_key);
