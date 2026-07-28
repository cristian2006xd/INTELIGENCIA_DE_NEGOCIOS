CREATE SCHEMA IF NOT EXISTS dw;

/* =========================================================
   DIMENSION TIEMPO
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_tiempo (
    fecha_key INTEGER PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    anio INTEGER NOT NULL,
    semestre SMALLINT NOT NULL,
    trimestre SMALLINT NOT NULL,
    numero_mes SMALLINT NOT NULL,
    nombre_mes VARCHAR(15) NOT NULL,
    anio_mes VARCHAR(7) NOT NULL,
    numero_semana SMALLINT NOT NULL,
    dia_mes SMALLINT NOT NULL,
    numero_dia_semana SMALLINT NOT NULL,
    nombre_dia VARCHAR(15) NOT NULL,
    es_fin_semana BOOLEAN NOT NULL,

    CONSTRAINT ck_dim_tiempo_semestre CHECK (semestre BETWEEN 1 AND 2),
    CONSTRAINT ck_dim_tiempo_trimestre CHECK (trimestre BETWEEN 1 AND 4),
    CONSTRAINT ck_dim_tiempo_mes CHECK (numero_mes BETWEEN 1 AND 12),
    CONSTRAINT ck_dim_tiempo_dia_semana CHECK (numero_dia_semana BETWEEN 1 AND 7)
);

/* Vista auxiliar para generar el calendario (2025-2029).
   El rango llega hasta 2029 porque fact_programacion.fecha_fin_exhibicion
   (ver 08_cubo_programacion.sql) trae fechas de fin de exhibicion de hasta
   2028-12-02 en programacion_funciones.xlsx; un calendario solo 2025-2026
   dejaria esa llave nula para la mayoria de las filas. */
CREATE OR REPLACE VIEW dw.view_aux_tiempo AS
SELECT
    (TO_CHAR(d, 'YYYYMMDD'))::INTEGER AS fecha_key,
    d::date AS fecha,
    EXTRACT(YEAR FROM d)::INTEGER AS anio,
    (CASE WHEN EXTRACT(MONTH FROM d) <= 6 THEN 1 ELSE 2 END)::SMALLINT AS semestre,
    EXTRACT(QUARTER FROM d)::SMALLINT AS trimestre,
    EXTRACT(MONTH FROM d)::SMALLINT AS numero_mes,
    (CASE EXTRACT(MONTH FROM d)
        WHEN 1 THEN 'Enero' WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril' WHEN 5 THEN 'Mayo' WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'
    END)::VARCHAR(15) AS nombre_mes,
    TO_CHAR(d, 'YYYY-MM') AS anio_mes,
    EXTRACT(WEEK FROM d)::SMALLINT AS numero_semana,
    EXTRACT(DAY FROM d)::SMALLINT AS dia_mes,
    EXTRACT(ISODOW FROM d)::SMALLINT AS numero_dia_semana,
    (CASE EXTRACT(ISODOW FROM d)
        WHEN 1 THEN 'Lunes' WHEN 2 THEN 'Martes' WHEN 3 THEN 'Miercoles'
        WHEN 4 THEN 'Jueves' WHEN 5 THEN 'Viernes' WHEN 6 THEN 'Sabado'
        WHEN 7 THEN 'Domingo'
    END)::VARCHAR(15) AS nombre_dia,
    (EXTRACT(ISODOW FROM d) IN (6, 7)) AS es_fin_semana
FROM generate_series('2025-01-01'::date, '2029-12-31'::date, '1 day'::interval) AS d;


/* =========================================================
   DIMENSION PELICULA
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_pelicula (
    pelicula_key BIGSERIAL PRIMARY KEY,
    codigo_pelicula VARCHAR(30) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    codigo_genero VARCHAR(20),
    genero VARCHAR(150),
    codigo_estudio VARCHAR(20),
    estudio VARCHAR(150),
    formato VARCHAR(150),
    clasificacion VARCHAR(20),
    costo_proyeccion_referencia NUMERIC(14,2),
    tarifa_referencia_sala NUMERIC(14,2),
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_pelicula_codigo UNIQUE (codigo_pelicula)
);


/* =========================================================
   DIMENSION CLIENTE
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_cliente (
    cliente_key BIGSERIAL PRIMARY KEY,
    documento VARCHAR(30) NOT NULL,
    nombres VARCHAR(150) NOT NULL,
    apellido1 VARCHAR(100),
    correo VARCHAR(200),
    tipo_cliente VARCHAR(20),
    permite_membresia VARCHAR(5),
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_cliente_documento UNIQUE (documento)
);


/* =========================================================
   DIMENSION SUCURSAL
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_sucursal (
    sucursal_key BIGSERIAL PRIMARY KEY,
    codigo_sucursal VARCHAR(20) NOT NULL,
    nombre_sucursal VARCHAR(150) NOT NULL,
    zona VARCHAR(100),
    ciudad VARCHAR(100),
    direccion VARCHAR(250),
    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dim_sucursal_codigo UNIQUE (codigo_sucursal)
);


/* =========================================================
   DIMENSION CANAL DE RESERVA
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_canal (
    canal_key SMALLSERIAL PRIMARY KEY,
    codigo_canal VARCHAR(20) NOT NULL,
    nombre_canal VARCHAR(50) NOT NULL,

    CONSTRAINT uq_dim_canal_codigo UNIQUE (codigo_canal)
);

INSERT INTO dw.dim_canal (codigo_canal, nombre_canal) VALUES
    ('TAQUILLA', 'Presencial'),
    ('WEB', 'En linea'),
    ('APP', 'Movil')
ON CONFLICT (codigo_canal) DO NOTHING;


/* =========================================================
   DIMENSION ESTADO DE RESERVA
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.dim_estado_reserva (
    estado_reserva_key SMALLSERIAL PRIMARY KEY,
    estado_reserva VARCHAR(20) NOT NULL,
    es_final BOOLEAN NOT NULL,
    color_semaforo VARCHAR(20),

    CONSTRAINT uq_dim_estado_reserva UNIQUE (estado_reserva)
);

INSERT INTO dw.dim_estado_reserva (estado_reserva, es_final, color_semaforo) VALUES
    ('CONFIRMADA', TRUE, 'verde'),
    ('CANCELADA', TRUE, 'rojo')
ON CONFLICT (estado_reserva) DO NOTHING;


/* =========================================================
   TABLA DE HECHOS RESERVA
   (grano: una fila por linea de detalle_reserva)
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.fact_reserva (
    reserva_key BIGSERIAL PRIMARY KEY,

    fecha_reserva_key INTEGER NOT NULL,
    pelicula_key BIGINT NOT NULL,
    cliente_key BIGINT,
    sucursal_key BIGINT NOT NULL,
    canal_key SMALLINT NOT NULL,
    estado_reserva_key SMALLINT NOT NULL,

    numero_reserva VARCHAR(15) NOT NULL,
    linea SMALLINT NOT NULL,
    tipo_asiento VARCHAR(20),

    cantidad_asientos INTEGER NOT NULL,
    descuento NUMERIC(14,2) NOT NULL DEFAULT 0,

    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_fact_reserva_linea UNIQUE (numero_reserva, linea),

    CONSTRAINT fk_fact_reserva_fecha
        FOREIGN KEY (fecha_reserva_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_reserva_pelicula
        FOREIGN KEY (pelicula_key) REFERENCES dw.dim_pelicula(pelicula_key),
    CONSTRAINT fk_fact_reserva_cliente
        FOREIGN KEY (cliente_key) REFERENCES dw.dim_cliente(cliente_key),
    CONSTRAINT fk_fact_reserva_sucursal
        FOREIGN KEY (sucursal_key) REFERENCES dw.dim_sucursal(sucursal_key),
    CONSTRAINT fk_fact_reserva_canal
        FOREIGN KEY (canal_key) REFERENCES dw.dim_canal(canal_key),
    CONSTRAINT fk_fact_reserva_estado
        FOREIGN KEY (estado_reserva_key) REFERENCES dw.dim_estado_reserva(estado_reserva_key),

    CONSTRAINT ck_fact_reserva_cantidad CHECK (cantidad_asientos > 0),
    CONSTRAINT ck_fact_reserva_descuento CHECK (descuento >= 0)
);

CREATE INDEX IF NOT EXISTS idx_fact_reserva_fecha ON dw.fact_reserva(fecha_reserva_key);
CREATE INDEX IF NOT EXISTS idx_fact_reserva_pelicula ON dw.fact_reserva(pelicula_key);
CREATE INDEX IF NOT EXISTS idx_fact_reserva_cliente ON dw.fact_reserva(cliente_key);
CREATE INDEX IF NOT EXISTS idx_fact_reserva_sucursal ON dw.fact_reserva(sucursal_key);
CREATE INDEX IF NOT EXISTS idx_fact_reserva_canal ON dw.fact_reserva(canal_key);
CREATE INDEX IF NOT EXISTS idx_fact_reserva_estado ON dw.fact_reserva(estado_reserva_key);
