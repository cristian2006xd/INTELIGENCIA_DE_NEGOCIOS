# Guía: ejecutar el ETL completo en Pentaho (Spoon)

Orden exacto para dejar `dw.*` poblado antes de abrir Power BI. Docker ya
debe estar arriba (`docker compose up -d` dentro de `docker/`).

## 0. Conexiones (solo la primera vez que abras el repo en Spoon)

Si al abrir cualquier `.ktr`/`.kjb` Spoon marca las conexiones en rojo,
créalas en `Vista Principal` → clic derecho en `Database connections` →
`Nueva`:

| Nombre     | Tipo       | Host      | Puerto | Base de datos  | Usuario | Password    |
|------------|------------|-----------|--------|----------------|---------|-------------|
| Cine_MySQL | MySQL      | localhost | 3308   | cine_db        | cris    | cristian123 |
| Gestion_PG | PostgreSQL | localhost | 5434   | cine_db        | cris    | cristian123 |
| Stage      | PostgreSQL | localhost | 5450   | datawarehouse  | cris    | cristian123 |

Los puertos son los que expone `docker/docker-compose.yml`, no los internos
de cada contenedor.

## 1. Staging: extraer todas las fuentes crudas

Abre y ejecuta (F9):

```text
pentaho/jobs/jProgramacion_Stage.kjb
```

Este job carga `stg.*` desde MySQL, PostgreSQL (gestion) y el Excel:
salas, distribuidoras, películas, estudio/género, cliente, reserva,
detalle_reserva, disponibilidad, zona, sucursal, segmento_cliente,
meta_mensual, encuesta_satisfaccion, programación. **Sin este paso, los
5 jobs siguientes van a fallar o cargar los hechos incompletos**, porque
todos leen de `stg.*`, no de las fuentes originales.

## 2. Cubos (dimensiones + hechos)

Ejecuta estos 5 jobs, en cualquier orden entre sí (cada uno es
autosuficiente y vuelve a cargar las dimensiones que necesita):

```text
pentaho/jobs/jDW_Cubo_Reserva.kjb
pentaho/jobs/jDW_Cubo_Satisfaccion.kjb
pentaho/jobs/jDW_Cubo_Programacion.kjb
pentaho/jobs/jDW_Cubo_Disponibilidad.kjb
pentaho/jobs/jDW_Cubo_Metas.kjb
```

Cada uno termina en un paso `Success` en verde si todo salió bien. Si un
paso queda en rojo, revisa el log de Spoon (pestaña inferior) — el error
más común es una conexión mal configurada (paso 0) o que el paso 1 no se
corrió antes.

## 3. Verificar que quedó poblado

En Adminer (`http://localhost:8090`, servidor `staging`, base
`datawarehouse`, usuario `cris` / `cristian123`) o por SQL:

```sql
SELECT 'fact_reserva' t, count(*) FROM dw.fact_reserva
UNION ALL SELECT 'fact_satisfaccion', count(*) FROM dw.fact_satisfaccion
UNION ALL SELECT 'fact_programacion', count(*) FROM dw.fact_programacion
UNION ALL SELECT 'fact_disponibilidad', count(*) FROM dw.fact_disponibilidad
UNION ALL SELECT 'fact_metas', count(*) FROM dw.fact_metas;
```

Todas deberían mostrar más de 0 filas (con los datos semilla del proyecto:
874 en programación, 400 en disponibilidad, 96 en metas).

## 4. Power BI

Con `dw.*` poblado, sigue:

1. [../powerbi/GUIA_PRIMERA_HOJA.md](../powerbi/GUIA_PRIMERA_HOJA.md) —
   conexión + hoja "Resumen de Reservas".
2. [../powerbi/GUIA_KPI_CUMPLIMIENTO.md](../powerbi/GUIA_KPI_CUMPLIMIENTO.md) —
   hoja de KPI (velocímetro + meta), usa `dw.fact_metas` recién cargado.

## 5. Lo que queda fuera de este alcance

El pronóstico (`dw.fact_pronostico_reservas`) todavía no tiene
transformación de carga: hoy solo existen la tabla y la vista
`dw.serie_reservas_mensuales` (ver `docker/datawarehouse-init/11_cubo_pronostico.sql`).
Para completarlo falta: correr el script de R (sección 17 del documento
del proyecto) dentro del contenedor `rstudio`, y crear una transformación
Pentaho que lea `stg.pronostico_reservas_r` y cargue
`dw.fact_pronostico_reservas`. Es la "Ampliación opcional" de
`GUIA_PRIMERA_HOJA.md`, no bloquea la hoja de KPI.
