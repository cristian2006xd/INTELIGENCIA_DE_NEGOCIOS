/* =========================================================
   CUBO PRONOSTICO DE RESERVAS
   Proceso de negocio: pronostico de series de tiempo generado
   en R (ver docs/proyecto_bi_cinehub_pentaho_r_powerbi.md,
   seccion 17) y cargado al Data Warehouse por Pentaho.

   stg.pronostico_reservas_r NO se declara aqui: R la crea/
   reemplaza en cada corrida con dbWriteTable(overwrite = TRUE),
   por lo que cualquier DDL previo seria sobrescrito igual.
   ========================================================= */

/* =========================================================
   VISTA SERIE MENSUAL DE RESERVAS
   Insumo que R consulta (seccion 17.6) para entrenar el
   modelo. sucursal_key = NULL identifica la serie agregada
   total; cada sucursal_key propio identifica su propia serie.
   ========================================================= */

CREATE OR REPLACE VIEW dw.serie_reservas_mensuales AS
SELECT
    date_trunc('month', dt.fecha)::date AS periodo,
    fr.sucursal_key,
    SUM(fr.cantidad_asientos) AS asientos_reservados
FROM dw.fact_reserva fr
JOIN dw.dim_tiempo dt ON dt.fecha_key = fr.fecha_reserva_key
JOIN dw.dim_estado_reserva der ON der.estado_reserva_key = fr.estado_reserva_key
WHERE der.estado_reserva = 'CONFIRMADA'
GROUP BY GROUPING SETS (
    (date_trunc('month', dt.fecha)::date),
    (date_trunc('month', dt.fecha)::date, fr.sucursal_key)
);


/* =========================================================
   TABLA DE HECHOS PRONOSTICO DE RESERVAS
   (grano: una fila por periodo, sucursal y nivel de pronostico)
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.fact_pronostico_reservas (
    pronostico_key BIGSERIAL PRIMARY KEY,

    fecha_key INTEGER NOT NULL,
    sucursal_key BIGINT,

    tipo_serie VARCHAR(60) NOT NULL,
    modelo VARCHAR(30) NOT NULL,

    valor_pronosticado NUMERIC(14,2) NOT NULL,
    limite_inferior_80 NUMERIC(14,2),
    limite_superior_80 NUMERIC(14,2),
    limite_inferior_95 NUMERIC(14,2),
    limite_superior_95 NUMERIC(14,2),

    fecha_generacion TIMESTAMP NOT NULL,
    horizonte SMALLINT NOT NULL,
    mae_validacion NUMERIC(14,4),
    rmse_validacion NUMERIC(14,4),
    mape_validacion NUMERIC(14,4),

    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fact_pronostico_fecha
        FOREIGN KEY (fecha_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_pronostico_sucursal
        FOREIGN KEY (sucursal_key) REFERENCES dw.dim_sucursal(sucursal_key),

    CONSTRAINT ck_fact_pronostico_horizonte CHECK (horizonte > 0)
);

CREATE INDEX IF NOT EXISTS idx_fact_pronostico_fecha ON dw.fact_pronostico_reservas(fecha_key);
CREATE INDEX IF NOT EXISTS idx_fact_pronostico_sucursal ON dw.fact_pronostico_reservas(sucursal_key);
CREATE INDEX IF NOT EXISTS idx_fact_pronostico_tipo ON dw.fact_pronostico_reservas(tipo_serie);

/*
   sucursal_key es NULL para "Asientos reservados mensuales totales"
   (la serie recomendada en la seccion 17.6 para el curso). No se agrega
   una unica constraint sobre (fecha_key, sucursal_key, tipo_serie, modelo)
   porque Postgres trata cada NULL como distinto y no bloquearia recargas
   duplicadas de la serie total; si se pronostica tambien por sucursal,
   filtrar duplicados desde Pentaho (Delete + Insert) antes de cargar.
*/
