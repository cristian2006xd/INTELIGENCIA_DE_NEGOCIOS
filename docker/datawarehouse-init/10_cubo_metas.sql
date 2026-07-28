/* =========================================================
   CUBO METAS
   Proceso de negocio: metas comerciales mensuales por sucursal
   Fuente: PostgreSQL gestion.meta_mensual -> stg.pg_meta_mensual
   ========================================================= */

/* =========================================================
   TABLA DE HECHOS METAS
   (grano: una fila por sucursal y mes)
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.fact_metas (
    meta_key BIGSERIAL PRIMARY KEY,

    periodo_key INTEGER NOT NULL,
    sucursal_key BIGINT NOT NULL,

    meta_reservas NUMERIC(14,2) NOT NULL,
    meta_clientes INTEGER,

    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_fact_metas_periodo_sucursal UNIQUE (periodo_key, sucursal_key),

    CONSTRAINT fk_fact_metas_periodo
        FOREIGN KEY (periodo_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_metas_sucursal
        FOREIGN KEY (sucursal_key) REFERENCES dw.dim_sucursal(sucursal_key),

    CONSTRAINT ck_fact_metas_reservas CHECK (meta_reservas >= 0)
);

CREATE INDEX IF NOT EXISTS idx_fact_metas_periodo ON dw.fact_metas(periodo_key);
CREATE INDEX IF NOT EXISTS idx_fact_metas_sucursal ON dw.fact_metas(sucursal_key);

/*
   periodo_key referencia el primer dia del mes (p. ej. 2026-01-01) dentro
   de dw.dim_tiempo, que ya cubre esa fecha porque su calendario es diario
   2025-2026. No se crea una dimension de periodo mensual aparte: Pentaho
   solo debe truncar stg.pg_meta_mensual.periodo al primer dia del mes al
   resolver la llave.
*/
