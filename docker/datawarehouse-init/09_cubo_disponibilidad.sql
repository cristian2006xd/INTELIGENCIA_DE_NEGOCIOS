/* =========================================================
   CUBO DISPONIBILIDAD
   Proceso de negocio: control de funciones disponibles por
   pelicula y sucursal en la fecha de corte de cada carga
   Fuente: MySQL cine.disponibilidad -> stg.mysql_disponibilidad
   ========================================================= */

/* =========================================================
   TABLA DE HECHOS DISPONIBILIDAD
   (grano: una fila por pelicula y sucursal para la fecha de
   corte de la carga)
   ========================================================= */

CREATE TABLE IF NOT EXISTS dw.fact_disponibilidad (
    disponibilidad_key BIGSERIAL PRIMARY KEY,

    fecha_corte_key INTEGER NOT NULL,
    sucursal_key BIGINT NOT NULL,
    pelicula_key BIGINT NOT NULL,

    funciones_disponibles INTEGER NOT NULL,
    funciones_minimas INTEGER NOT NULL,
    exceso_programacion INTEGER NOT NULL DEFAULT 0,
    deficit_programacion INTEGER NOT NULL DEFAULT 0,
    fecha_ultimo_movimiento DATE,

    fecha_carga_dw TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_fact_disponibilidad_corte UNIQUE (fecha_corte_key, sucursal_key, pelicula_key),

    CONSTRAINT fk_fact_disponibilidad_fecha
        FOREIGN KEY (fecha_corte_key) REFERENCES dw.dim_tiempo(fecha_key),
    CONSTRAINT fk_fact_disponibilidad_sucursal
        FOREIGN KEY (sucursal_key) REFERENCES dw.dim_sucursal(sucursal_key),
    CONSTRAINT fk_fact_disponibilidad_pelicula
        FOREIGN KEY (pelicula_key) REFERENCES dw.dim_pelicula(pelicula_key),

    CONSTRAINT ck_fact_disponibilidad_funciones CHECK (funciones_disponibles >= 0),
    CONSTRAINT ck_fact_disponibilidad_minimas CHECK (funciones_minimas >= 0)
);

CREATE INDEX IF NOT EXISTS idx_fact_disponibilidad_fecha ON dw.fact_disponibilidad(fecha_corte_key);
CREATE INDEX IF NOT EXISTS idx_fact_disponibilidad_sucursal ON dw.fact_disponibilidad(sucursal_key);
CREATE INDEX IF NOT EXISTS idx_fact_disponibilidad_pelicula ON dw.fact_disponibilidad(pelicula_key);

/*
   exceso_programacion = GREATEST(funciones_disponibles - funciones_minimas, 0)
   deficit_programacion = GREATEST(funciones_minimas - funciones_disponibles, 0)
   Pentaho debe calcularlos al cargar (Calculator/Formula) antes del Table Output;
   se dejan como columnas propias (no generadas) porque el motor tabular de
   Power BI las necesita como medidas simples, sin depender de STORED GENERATED.
*/
