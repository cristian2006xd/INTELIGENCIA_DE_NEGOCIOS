# Proyecto de Inteligencia de Negocios para una Cadena de Cines (CineHub)

## Implementación con Pentaho Data Integration, PostgreSQL, R y Power BI

---

## 1. Nombre del proyecto

**Sistema de Inteligencia de Negocios para la Gestión Integral de una Cadena de Cines (CineHub)**

El proyecto integra tres fuentes de datos heterogéneas, construye un Data Warehouse mediante **Pentaho Data Integration**, aplica un modelo de pronóstico de series de tiempo mediante **R** y utiliza **Power BI únicamente para el modelado semántico ligero, las medidas DAX y la visualización**.

---

## 2. Fuentes de datos

### 2.1. MySQL: sistema operacional de cine

Archivo:

```text
01_recrear_cine.sql
```

Principales entidades:

- `estudio`
- `genero`
- `pelicula`
- `cliente`
- `reserva`
- `detalle_reserva`
- `disponibilidad`

Información disponible:

- Películas, géneros y estudios productores.
- Clientes registrados en el sistema de reservas.
- Reservas y detalle de cada reserva (películas y cantidad de asientos incluidos).
- Canales de reserva.
- Disponibilidad de funciones por sucursal (cine).
- Costos de proyección y tarifas de referencia de sala.

---

### 2.2. PostgreSQL: sistema corporativo de gestión

Archivo:

```text
01_recrear_gestion.sql
```

Esquema operacional:

```text
gestion
```

Principales entidades:

- `zona`
- `sucursal`
- `segmento_cliente`
- `cliente`
- `meta_mensual`
- `encuesta_satisfaccion`

Información disponible:

- Zonas y sucursales (cines).
- Ubicación geográfica.
- Segmentación corporativa de clientes.
- Metas mensuales de reservas y clientes por sucursal.
- Encuestas de satisfacción.
- Tiempo de espera del cliente en taquilla.

---

### 2.3. Excel: sistema de programación de funciones

Archivo:

```text
programacion_funciones.xlsx
```

Hojas disponibles:

- `Programacion_2025_2026`
- `Distribuidoras`
- `Peliculas`
- `Salas`
- `Resumen_Mensual`

Información disponible:

- Programación de funciones por película y sucursal.
- Distribuidoras que entregan las copias.
- Copias, números de programación y fechas de fin de exhibición.
- Cantidades de funciones programadas.
- Costos y descuentos de proyección.
- Valor neto de la programación.
- Salas de destino.
- Estado de entrega de la copia.
- Resúmenes mensuales.

---

## 3. Situación problemática

La cadena de cines administra sus datos mediante varios sistemas independientes:

- MySQL contiene reservas y disponibilidad de funciones.
- PostgreSQL contiene clientes corporativos, sucursales, metas y encuestas.
- Excel contiene la programación de funciones y las distribuidoras.
- Los códigos, nombres y formatos no siempre coinciden entre las fuentes.
- No existe un Data Warehouse que consolide la información.
- La gerencia no dispone de una visión integrada de reservas, programación, ocupación, clientes, metas y satisfacción.
- No existe un mecanismo para pronosticar la demanda futura de reservas.
- Tampoco existe un control formal de calidad y ejecución de los procesos ETL.

Como resultado, la organización tiene dificultades para responder preguntas como:

- ¿Qué sucursales tienen mayor ocupación?
- ¿Qué películas generan más reservas?
- ¿Cuántas funciones se programan en comparación con las reservas efectivas?
- ¿Qué películas presentan riesgo de sobreprogramación o subprogramación?
- ¿Qué sucursales cumplen sus metas de reservas?
- ¿Existe relación entre satisfacción y ocupación?
- ¿Qué distribuidoras ofrecen mejores condiciones de entrega?
- ¿Qué nivel de reservas podría esperarse en los próximos meses?
- ¿Qué procesos ETL presentan errores, rechazos o retrasos?

---

## 4. Pregunta guía

> **¿Cómo puede una cadena de cines integrar sus datos de reservas, programación de funciones, disponibilidad, clientes, metas y satisfacción para mejorar la ocupación, la programación de contenido, la experiencia del cliente y la planificación futura?**

---

## 5. Objetivo general

**Diseñar e implementar una solución de Inteligencia de Negocios que integre información de reservas, programación de funciones, disponibilidad, clientes, metas y satisfacción mediante Pentaho Data Integration, consolide los datos en un Data Warehouse, aplique R para pronosticar una serie de tiempo y utilice Power BI para construir dashboards que apoyen la toma de decisiones.**

---

## 6. Objetivos específicos

1. Analizar la estructura y calidad de las tres fuentes de datos.
2. Definir requerimientos analíticos, procesos de negocio y KPIs.
3. Diseñar un modelo dimensional para el Data Warehouse.
4. Construir procesos ETL en Pentaho Data Integration.
5. Limpiar, transformar y homologar clientes, películas, sucursales y fechas.
6. Cargar dimensiones y tablas de hechos en PostgreSQL.
7. Registrar el estado, duración y calidad de cada ejecución ETL.
8. Aplicar R para analizar y pronosticar una serie temporal de reservas.
9. Almacenar los pronósticos generados por R dentro del Data Warehouse.
10. Conectar Power BI al Data Warehouse para crear medidas y visualizaciones.
11. Formular conclusiones y recomendaciones basadas en los resultados.

---

## 7. Alcance del proyecto

El proyecto cubrirá seis procesos analíticos:

| Proceso | Fuente principal |
|---|---|
| Reservas de funciones | MySQL |
| Programación de funciones | Excel |
| Disponibilidad por sucursal | MySQL |
| Metas comerciales | PostgreSQL |
| Satisfacción del cliente | PostgreSQL |
| Pronóstico de reservas | R sobre datos del Data Warehouse |

El proyecto incluirá:

- Integración de tres fuentes.
- Área de staging.
- Data Warehouse dimensional.
- ETL mediante Pentaho.
- Control de calidad y auditoría ETL.
- Pronóstico de series de tiempo con R.
- Visualización en Power BI.

No se utilizará Power BI como herramienta principal de limpieza o integración. Las transformaciones relevantes se realizarán en Pentaho antes de que los datos lleguen a Power BI.

---

## 8. Arquitectura propuesta

```text
┌──────────────────────────┐
│ MySQL cine_db            │
│ Reservas y disponibilidad│
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│ Pentaho Data Integration │
│ Extracción y staging     │
└────────────▲─────────────┘
             │
┌────────────┴─────────────┐
│ PostgreSQL gestion       │
│ Clientes, metas,         │
│ sucursales y encuestas   │
└──────────────────────────┘

┌──────────────────────────┐
│ Excel de programación    │
│ Distribuidoras, copias,  │
│ costos y entrega         │
└────────────┬─────────────┘
             │
             ▼
┌────────────────────────────────────┐
│ Pentaho Data Integration           │
│                                    │
│ - Perfilamiento                    │
│ - Limpieza                         │
│ - Homologación                     │
│ - Validación                       │
│ - Manejo de errores                │
│ - Carga dimensional                │
│ - Auditoría ETL                    │
└────────────────┬───────────────────┘
                 ▼
┌────────────────────────────────────┐
│ PostgreSQL Data Warehouse          │
│ Esquemas: stg, dw y audit          │
└──────────────┬─────────────┬───────┘
               │             │
               │             ▼
               │     ┌──────────────────────┐
               │     │ R                    │
               │     │ Serie de tiempo      │
               │     │ Pronóstico de        │
               │     │ reservas             │
               │     └──────────┬───────────┘
               │                │
               │                ▼
               │     ┌──────────────────────┐
               │     │ Tabla de pronósticos │
               │     │ en el Data Warehouse │
               │     └──────────┬───────────┘
               │                │
               └────────────────┴───────────────┐
                                                ▼
                                   ┌────────────────────────┐
                                   │ Power BI               │
                                   │ Medidas y visualización│
                                   └────────────────────────┘
```

---

## 9. Responsabilidad de cada herramienta

### Pentaho Data Integration

Pentaho será responsable de:

- Conectarse a MySQL.
- Conectarse a PostgreSQL.
- Leer el archivo Excel.
- Extraer los datos.
- Cargar tablas de staging.
- Limpiar y transformar los datos.
- Homologar claves de negocio.
- Detectar y separar registros inválidos.
- Generar claves sustitutas.
- Cargar dimensiones.
- Cargar tablas de hechos.
- Registrar auditoría y errores.
- Ejecutar o invocar el proceso de R.
- Programar el flujo completo mediante jobs.

### PostgreSQL

PostgreSQL será utilizado como:

- Base del sistema corporativo operacional.
- Motor del Data Warehouse.
- Repositorio de staging.
- Repositorio dimensional.
- Repositorio de auditoría ETL.
- Repositorio de los resultados del pronóstico.

### R

R será utilizado para:

- Preparar una serie temporal agregada.
- Explorar tendencia y estacionalidad.
- Ajustar un modelo de pronóstico.
- Evaluar el modelo.
- Generar predicciones futuras.
- Guardar los resultados en PostgreSQL.

### Power BI

Power BI será utilizado para:

- Conectarse al Data Warehouse.
- Crear medidas DAX.
- Definir jerarquías y formatos.
- Diseñar dashboards.
- Comparar datos reales y pronosticados.
- Presentar KPIs.
- Facilitar la exploración interactiva.

---

## 10. Esquemas recomendados en PostgreSQL

```sql
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS audit;
```

### Esquema `stg`

Contendrá copias temporales o normalizadas de las fuentes:

```text
stg_mysql_reserva
stg_mysql_detalle_reserva
stg_mysql_pelicula
stg_mysql_cliente
stg_mysql_disponibilidad

stg_pg_sucursal
stg_pg_zona
stg_pg_cliente
stg_pg_segmento
stg_pg_meta
stg_pg_encuesta

stg_excel_programacion
stg_excel_distribuidoras
stg_excel_peliculas
stg_excel_salas
```

### Esquema `dw`

Contendrá dimensiones, hechos y pronósticos:

```text
dim_fecha
dim_pelicula
dim_sucursal
dim_cliente
dim_distribuidora
dim_canal_reserva
dim_estado_entrega

fact_reservas
fact_programacion
fact_disponibilidad
fact_metas
fact_satisfaccion
fact_pronostico_reservas
```

### Esquema `audit`

Contendrá información de control:

```text
etl_ejecucion
etl_detalle
etl_error
etl_rechazo
```

---

## 11. Modelo dimensional

## 11.1. Dimensión fecha

```text
fecha_key
fecha
anio
semestre
trimestre
numero_mes
nombre_mes
anio_mes
numero_semana
dia_mes
nombre_dia
es_fin_semana
```

Debe utilizarse para:

- Fecha de reserva.
- Fecha de programación.
- Fecha estimada de estreno en sala.
- Fecha de fin de exhibición.
- Fecha de encuesta.
- Periodo de metas.
- Periodo del pronóstico.

---

## 11.2. Dimensión película

```text
pelicula_key
codigo_pelicula
titulo
presentacion_formato
codigo_genero
genero
codigo_estudio
estudio
pais_estudio
clasificacion
activo
costo_proyeccion_referencia
tarifa_referencia_sala
```

Fuente maestra recomendada:

```text
MySQL
```

La información del Excel se utilizará para validar y complementar códigos, títulos y formatos.

---

## 11.3. Dimensión sucursal

```text
sucursal_key
codigo_sucursal
nombre_sucursal
codigo_zona
zona
responsable_zona
ciudad
direccion
latitud
longitud
fecha_apertura
activa
```

Fuente maestra recomendada:

```text
PostgreSQL gestion.sucursal
```

Los nombres operacionales de MySQL y las salas del Excel deberán homologarse con el código corporativo.

---

## 11.4. Dimensión cliente

```text
cliente_key
documento_normalizado
nombres
ciudad
sexo
fecha_nacimiento
grupo_edad
codigo_segmento
segmento
fecha_registro
correo
activo
origen_cliente
estado_integracion
```

Valores posibles para `estado_integracion`:

- Integrado.
- Solo MySQL.
- Solo PostgreSQL.
- Duplicado probable.
- Documento inválido.
- Consumidor final.

---

## 11.5. Dimensión distribuidora

```text
distribuidora_key
codigo_distribuidora
nombre_distribuidora
contacto_ventas
telefono_contacto
correo_contacto
```

Fuente:

```text
Hoja Distribuidoras del Excel
```

---

## 11.6. Dimensión canal de reserva

```text
canal_reserva_key
canal_reserva
```

---

## 11.7. Dimensión estado de entrega

```text
estado_entrega_key
estado_entrega_copia
```

---

## 12. Tablas de hechos

## 12.1. Hecho reservas

**Granularidad:** una fila por película incluida en una reserva.

```text
reserva_key
numero_reserva
linea
fecha_key
sucursal_key
cliente_key
pelicula_key
canal_reserva_key
cantidad_asientos
tipo_asiento
descuento_asignado
estado_reserva
```

Medidas:

- Asientos reservados.
- Número de reservas.
- Reservas canceladas.
- Clientes distintos.
- Asientos promedio por reserva.

---

## 12.2. Hecho programación

**Granularidad:** una fila por película y copia incluida en una programación.

```text
programacion_key
numero_programacion
fecha_programacion_key
fecha_estreno_key
fecha_fin_exhibicion_key
sucursal_key
pelicula_key
distribuidora_key
estado_entrega_key
numero_copia
funciones_programadas
costo_proyeccion_unitario
subtotal_bruto
porcentaje_descuento
valor_descuento
valor_neto
dias_hasta_estreno
dias_hasta_fin_exhibicion
```

---

## 12.3. Hecho disponibilidad

**Granularidad:** una fila por película y sucursal para la fecha de corte.

```text
disponibilidad_key
fecha_corte_key
sucursal_key
pelicula_key
funciones_disponibles
funciones_minimas
exceso_programacion
deficit_programacion
fecha_ultimo_movimiento
```

---

## 12.4. Hecho metas

**Granularidad:** una fila por sucursal y mes.

```text
meta_key
periodo_key
sucursal_key
meta_reservas
meta_clientes
```

Los valores reales se calcularán a partir de `fact_reservas`.

---

## 12.5. Hecho satisfacción

**Granularidad:** una fila por encuesta.

```text
encuesta_key
id_encuesta_origen
fecha_key
sucursal_key
cliente_key
puntuacion
tiempo_espera_minutos
comentario
es_satisfaccion_positiva
es_satisfaccion_negativa
```

---

## 12.6. Hecho pronóstico de reservas

**Granularidad:** una fila por periodo, sucursal y nivel de pronóstico.

```text
pronostico_key
fecha_key
sucursal_key
tipo_serie
modelo
valor_pronosticado
limite_inferior_80
limite_superior_80
limite_inferior_95
limite_superior_95
fecha_generacion
horizonte
mae_validacion
rmse_validacion
mape_validacion
```

`tipo_serie` puede contener:

- Asientos reservados mensuales totales.
- Asientos reservados mensuales por sucursal.
- Reservas mensuales por género.
- Número de reservas mensuales.

Para el curso se recomienda comenzar con:

```text
Asientos reservados mensuales totales
```

Como ampliación se puede pronosticar por sucursal.

---

## 13. Esquema lógico simplificado

```text
DimCliente ───────────────┐
DimSucursal ──────────────┤
DimPelicula ──────────────┤
DimCanalReserva ──────────┤
DimFecha ─────────────────┴── FactReservas

DimDistribuidora ─────────┐
DimEstadoEntrega ─────────┤
DimSucursal ──────────────┤
DimPelicula ──────────────┤
DimFecha ─────────────────┴── FactProgramacion

DimSucursal ──────────────┐
DimPelicula ──────────────┤
DimFecha ─────────────────┴── FactDisponibilidad

DimSucursal ──────────────┐
DimFecha ─────────────────┴── FactMetas

DimCliente ───────────────┐
DimSucursal ──────────────┤
DimFecha ─────────────────┴── FactSatisfaccion

DimSucursal ──────────────┐
DimFecha ─────────────────┴── FactPronosticoReservas
```

---

## 14. Flujo ETL en Pentaho

## 14.1. Etapa de extracción

Transformaciones sugeridas:

```text
tr_01_extraer_mysql_reservas.ktr
tr_02_extraer_mysql_disponibilidad.ktr
tr_03_extraer_mysql_maestros.ktr

tr_04_extraer_postgresql_gestion.ktr

tr_05_extraer_excel_programacion.ktr
tr_06_extraer_excel_maestros.ktr
```

Pasos habituales:

- Table Input.
- Microsoft Excel Input.
- Select Values.
- String Operations.
- Data Validator.
- Table Output.
- Write to Log.

---

## 14.2. Etapa de perfilamiento

Transformaciones sugeridas:

```text
tr_10_perfilar_clientes.ktr
tr_11_perfilar_peliculas.ktr
tr_12_perfilar_sucursales.ktr
tr_13_perfilar_programacion.ktr
tr_14_perfilar_reservas.ktr
```

Controles:

- Total de filas.
- Valores nulos.
- Valores distintos.
- Duplicados.
- Rangos de fechas.
- Valores máximos y mínimos.
- Integridad referencial.
- Valores fuera de rango.

---

## 14.3. Etapa de limpieza

Operaciones:

- Eliminar espacios iniciales y finales.
- Normalizar mayúsculas y minúsculas.
- Corregir tipos de datos.
- Convertir fechas de Excel.
- Validar documentos.
- Estandarizar ciudades.
- Estandarizar sucursales (cines).
- Estandarizar estados.
- Separar registros válidos e inválidos.
- Registrar errores.

Transformaciones sugeridas:

```text
tr_20_limpiar_clientes.ktr
tr_21_limpiar_peliculas.ktr
tr_22_limpiar_sucursales.ktr
tr_23_limpiar_programacion.ktr
tr_24_limpiar_reservas.ktr
tr_25_limpiar_encuestas.ktr
```

---

## 14.4. Homologación de clientes

Regla inicial:

```text
documento_normalizado =
TRIM(documento)
→ eliminar guiones
→ eliminar espacios internos
→ conservar solo dígitos
→ validar longitud
```

El proceso deberá:

1. Normalizar documento.
2. Comparar clientes de MySQL y PostgreSQL.
3. Identificar coincidencias exactas.
4. Identificar duplicados probables.
5. Clasificar registros no integrados.
6. Conservar trazabilidad del origen.

---

## 14.5. Homologación de sucursales

Se recomienda una tabla de equivalencias:

```text
dw.map_sucursal
```

Ejemplo:

| valor_origen | sistema_origen | codigo_sucursal |
|---|---|---|
| Cine Norte | MySQL | NORTE |
| NORTE | Excel | NORTE |
| Cine Centro Historico | MySQL | CENTRO |
| CENTRO | Excel | CENTRO |
| Cine del Sur | MySQL | SUR |
| SUR | Excel | SUR |
| Cine Valle de los Chillos | MySQL | VALLE |
| VALLE | Excel | VALLE |

Pentaho puede resolver la correspondencia mediante:

- Database Lookup.
- Stream Lookup.
- Merge Join.

---

## 14.6. Carga de dimensiones

Orden recomendado:

```text
1. dim_fecha
2. dim_pelicula
3. dim_sucursal
4. dim_cliente
5. dim_distribuidora
6. dim_canal_reserva
7. dim_estado_entrega
```

Pasos de Pentaho recomendados:

- Dimension Lookup/Update.
- Database Lookup.
- Combination Lookup/Update.
- Insert/Update.
- Table Output.

Para fines didácticos puede aplicarse:

- SCD tipo 1 para correcciones simples.
- SCD tipo 2 como ampliación para conservar historia.

---

## 14.7. Carga de hechos

Transformaciones sugeridas:

```text
tr_40_cargar_fact_reservas.ktr
tr_41_cargar_fact_programacion.ktr
tr_42_cargar_fact_disponibilidad.ktr
tr_43_cargar_fact_metas.ktr
tr_44_cargar_fact_satisfaccion.ktr
```

Cada transformación deberá:

1. Leer datos limpios.
2. Resolver claves sustitutas.
3. Calcular medidas derivadas.
4. Validar campos obligatorios.
5. Separar errores.
6. Insertar registros.
7. Registrar cantidad procesada.

---

## 15. Jobs de Pentaho

## 15.1. Job principal

```text
jb_00_carga_dw_cinehub.kjb
```

Secuencia:

```text
Inicio
  ↓
Crear registro de ejecución
  ↓
Extraer MySQL
  ↓
Extraer PostgreSQL
  ↓
Extraer Excel
  ↓
Validar staging
  ↓
Cargar dimensiones
  ↓
Cargar hechos
  ↓
Generar agregados para R
  ↓
Ejecutar script de R
  ↓
Cargar pronósticos
  ↓
Actualizar auditoría
  ↓
Fin correcto
```

Ruta alternativa de error:

```text
Error de transformación
  ↓
Registrar detalle del error
  ↓
Marcar ejecución como fallida
  ↓
Finalizar job
```

---

## 15.2. Job de dimensiones

```text
jb_10_cargar_dimensiones.kjb
```

---

## 15.3. Job de hechos

```text
jb_20_cargar_hechos.kjb
```

---

## 15.4. Job de pronóstico

```text
jb_30_pronostico_r.kjb
```

Pasos:

1. Ejecutar consulta de agregación.
2. Exportar CSV temporal o preparar tabla de entrada.
3. Ejecutar script R.
4. Validar archivo o tabla de salida.
5. Cargar resultados en `dw.fact_pronostico_reservas`.
6. Registrar métricas del modelo.

---

## 16. Auditoría ETL

## 16.1. Tabla de ejecución

```sql
CREATE TABLE audit.etl_ejecucion (
    id_ejecucion BIGSERIAL PRIMARY KEY,
    nombre_job VARCHAR(150) NOT NULL,
    fecha_hora_inicio TIMESTAMP NOT NULL,
    fecha_hora_fin TIMESTAMP,
    estado VARCHAR(20) NOT NULL,
    registros_leidos BIGINT DEFAULT 0,
    registros_validos BIGINT DEFAULT 0,
    registros_rechazados BIGINT DEFAULT 0,
    registros_cargados BIGINT DEFAULT 0,
    duracion_segundos NUMERIC(12,2),
    mensaje TEXT
);
```

## 16.2. Tabla de detalle

```sql
CREATE TABLE audit.etl_detalle (
    id_detalle BIGSERIAL PRIMARY KEY,
    id_ejecucion BIGINT REFERENCES audit.etl_ejecucion(id_ejecucion),
    nombre_transformacion VARCHAR(150),
    fuente VARCHAR(80),
    tabla_destino VARCHAR(120),
    fecha_hora_inicio TIMESTAMP,
    fecha_hora_fin TIMESTAMP,
    registros_leidos BIGINT,
    registros_rechazados BIGINT,
    registros_cargados BIGINT,
    estado VARCHAR(20),
    mensaje TEXT
);
```

## 16.3. Tabla de rechazos

```sql
CREATE TABLE audit.etl_rechazo (
    id_rechazo BIGSERIAL PRIMARY KEY,
    id_ejecucion BIGINT REFERENCES audit.etl_ejecucion(id_ejecucion),
    fuente VARCHAR(80),
    entidad VARCHAR(80),
    clave_origen VARCHAR(150),
    tipo_error VARCHAR(80),
    descripcion_error TEXT,
    datos_origen TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 17. Aplicación de R a una serie de tiempo

## 17.1. Serie seleccionada

Para mantener el proyecto manejable se recomienda utilizar:

> **Asientos reservados mensuales de toda la cadena**

La serie se obtiene agregando `fact_reservas`:

```sql
SELECT
    DATE_TRUNC('month', f.fecha)::date AS periodo,
    SUM(r.cantidad_asientos) AS asientos_reservados
FROM dw.fact_reservas r
JOIN dw.dim_fecha f
    ON f.fecha_key = r.fecha_key
WHERE r.estado_reserva <> 'CANCELADA'
GROUP BY DATE_TRUNC('month', f.fecha)
ORDER BY periodo;
```

Como ampliación se pueden crear series por:

- Sucursal.
- Género.
- Estudio.
- Película.
- Número de reservas.

---

## 17.2. Objetivo analítico

Pronosticar los asientos reservados de los próximos:

```text
3 meses
```

o, si la cantidad de observaciones lo permite:

```text
6 meses
```

El ejercicio debe permitir al estudiante:

- Identificar tendencia.
- Analizar posible estacionalidad.
- Separar entrenamiento y validación.
- Comparar valores reales y pronosticados.
- Interpretar intervalos de confianza.
- Evaluar el error del modelo.

---

## 17.3. Flujo de datos hacia R

Opción recomendada:

```text
Pentaho → PostgreSQL → R → PostgreSQL → Power BI
```

Secuencia:

1. Pentaho carga `fact_reservas`.
2. Pentaho genera una tabla agregada mensual.
3. R consulta la tabla agregada desde PostgreSQL.
4. R ajusta el modelo.
5. R inserta los pronósticos en el Data Warehouse.
6. Power BI consulta los datos reales y pronosticados.

Tabla intermedia sugerida:

```text
dw.serie_reservas_mensuales
```

Campos:

```text
periodo
sucursal_key
asientos_reservados
numero_reservas
clientes_distintos
```

---

## 17.4. Modelos recomendados

Para el nivel del curso se recomienda comparar:

- Promedio móvil como línea base.
- Suavizamiento exponencial ETS.
- ARIMA automático.

Modelo principal recomendado:

```text
ETS o ARIMA
```

La selección final puede basarse en:

- MAE.
- RMSE.
- MAPE.
- Comportamiento de los residuos.

---

## 17.5. Paquetes de R

```r
install.packages(c(
  "DBI",
  "RPostgres",
  "dplyr",
  "lubridate",
  "forecast",
  "ggplot2"
))
```

---

## 17.6. Script base de R

```r
library(DBI)
library(RPostgres)
library(dplyr)
library(lubridate)
library(forecast)

conexion <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("DW_HOST"),
  port = as.integer(Sys.getenv("DW_PORT")),
  dbname = Sys.getenv("DW_DATABASE"),
  user = Sys.getenv("DW_USER"),
  password = Sys.getenv("DW_PASSWORD")
)

serie <- dbGetQuery(
  conexion,
  "
  SELECT periodo, asientos_reservados
  FROM dw.serie_reservas_mensuales
  WHERE sucursal_key IS NULL
  ORDER BY periodo
  "
)

serie$periodo <- as.Date(serie$periodo)

anio_inicio <- year(min(serie$periodo))
mes_inicio <- month(min(serie$periodo))

reservas_ts <- ts(
  serie$asientos_reservados,
  start = c(anio_inicio, mes_inicio),
  frequency = 12
)

modelo_ets <- ets(reservas_ts)
pronostico <- forecast(modelo_ets, h = 3, level = c(80, 95))

periodos_futuros <- seq(
  from = floor_date(max(serie$periodo), "month") %m+% months(1),
  by = "month",
  length.out = 3
)

resultado <- data.frame(
  periodo = periodos_futuros,
  tipo_serie = "ASIENTOS_RESERVADOS_MENSUAL",
  modelo = "ETS",
  valor_pronosticado = as.numeric(pronostico$mean),
  limite_inferior_80 = as.numeric(pronostico$lower[, "80%"]),
  limite_superior_80 = as.numeric(pronostico$upper[, "80%"]),
  limite_inferior_95 = as.numeric(pronostico$lower[, "95%"]),
  limite_superior_95 = as.numeric(pronostico$upper[, "95%"]),
  fecha_generacion = Sys.time(),
  horizonte = 1:3
)

dbWriteTable(
  conexion,
  Id(schema = "stg", table = "pronostico_reservas_r"),
  resultado,
  overwrite = TRUE,
  row.names = FALSE
)

dbDisconnect(conexion)
```

Pentaho deberá leer `stg.pronostico_reservas_r`, resolver las claves de fecha y cargar `dw.fact_pronostico_reservas`.

---

## 17.7. Evaluación del modelo

Se recomienda reservar los últimos tres meses conocidos como conjunto de validación.

Métricas:

```text
MAE  = error absoluto medio
RMSE = raíz del error cuadrático medio
MAPE = error porcentual absoluto medio
```

El modelo deberá considerarse útil cuando:

- Supere a una línea base simple.
- No presente errores extremos.
- Los residuos no muestren patrones evidentes.
- El pronóstico sea coherente con el contexto del negocio.

Debe aclararse que una serie con pocos periodos limita la confiabilidad del pronóstico. El objetivo académico es aplicar el proceso completo y evaluar críticamente sus limitaciones.

---

## 18. Integración de R con Pentaho

Pentaho puede ejecutar R mediante una entrada de job como:

```text
Shell
```

Ejemplo conceptual:

```bash
Rscript pronostico_reservas.R
```

El job debe:

1. Establecer variables de conexión.
2. Ejecutar el script.
3. Verificar el código de salida.
4. Comprobar que se generaron resultados.
5. Cargar los pronósticos.
6. Registrar éxito o error en auditoría.

Variables recomendadas:

```text
DW_HOST
DW_PORT
DW_DATABASE
DW_USER
DW_PASSWORD
```

No se deben guardar contraseñas directamente dentro del script R ni en el repositorio público.

---

## 19. Indicadores del proyecto

## 19.1. Reservas

- Asientos reservados.
- Número de reservas.
- Reservas canceladas.
- Asientos promedio por reserva.
- Clientes distintos.
- Reservas por canal.
- Reservas por género de película.

## 19.2. Programación

- Funciones programadas.
- Valor neto de programación.
- Descuento obtenido.
- Costo promedio por función.
- Programación por distribuidora.
- Programaciones pendientes de entrega.
- Días estimados hasta el estreno en sala.

## 19.3. Disponibilidad

- Funciones disponibles totales.
- Películas bajo el mínimo de funciones.
- Déficit de funciones programadas.
- Exceso de programación.
- Películas sin movimiento reciente.
- Cobertura estimada de cartelera.

## 19.4. Metas

- Meta mensual de reservas.
- Reservas reales.
- Cumplimiento porcentual.
- Brecha frente a meta.
- Meta de clientes.
- Clientes atendidos.

## 19.5. Satisfacción

- Puntuación promedio.
- Tiempo promedio de espera.
- Número de encuestas.
- Porcentaje de satisfacción positiva.
- Porcentaje de satisfacción negativa.

## 19.6. Pronóstico

- Asientos reservados pronosticados.
- Diferencia entre real y pronosticado.
- Crecimiento esperado.
- Límite inferior.
- Límite superior.
- MAE.
- RMSE.
- MAPE.

## 19.7. ETL

- Registros leídos.
- Registros válidos.
- Registros rechazados.
- Porcentaje de calidad.
- Duración del proceso.
- Fuentes cargadas correctamente.
- Transformaciones fallidas.
- Última fecha de actualización.

---

## 20. Medidas DAX sugeridas

Power BI se conectará a las tablas ya transformadas del Data Warehouse.

### Reservas

```DAX
Asientos reservados =
SUM(fact_reservas[cantidad_asientos])
```

```DAX
Número de reservas =
DISTINCTCOUNT(fact_reservas[numero_reserva])
```

```DAX
Asientos promedio por reserva =
DIVIDE(
    [Asientos reservados],
    [Número de reservas],
    0
)
```

```DAX
Reservas canceladas =
CALCULATE(
    DISTINCTCOUNT(fact_reservas[numero_reserva]),
    fact_reservas[estado_reserva] = "CANCELADA"
)
```

### Programación

```DAX
Valor neto programado =
SUM(fact_programacion[valor_neto])
```

```DAX
Funciones programadas =
SUM(fact_programacion[funciones_programadas])
```

### Metas

```DAX
Meta de reservas =
SUM(fact_metas[meta_reservas])
```

```DAX
Cumplimiento de reservas =
DIVIDE(
    [Asientos reservados],
    [Meta de reservas],
    0
)
```

```DAX
Brecha frente a meta =
[Asientos reservados] - [Meta de reservas]
```

### Pronóstico

```DAX
Asientos pronosticados =
SUM(fact_pronostico_reservas[valor_pronosticado])
```

```DAX
Desviación frente al pronóstico =
[Asientos reservados] - [Asientos pronosticados]
```

```DAX
Desviación porcentual =
DIVIDE(
    [Desviación frente al pronóstico],
    [Asientos pronosticados],
    0
)
```

### Calidad ETL

```DAX
Porcentaje de registros válidos =
DIVIDE(
    SUM(etl_ejecucion[registros_validos]),
    SUM(etl_ejecucion[registros_leidos]),
    0
)
```

---

## 21. Dashboards en Power BI

## 21.1. Página 1: resumen ejecutivo

Tarjetas:

- Asientos reservados.
- Funciones programadas.
- Valor neto programado.
- Cumplimiento de meta.
- Satisfacción promedio.
- Películas bajo mínimo de funciones.
- Asientos pronosticados del siguiente mes.

Visualizaciones:

- Reservas y programación por mes.
- Cumplimiento por sucursal.
- Ocupación por género.
- Mapa de sucursales (cines).
- Indicador de calidad ETL.

---

## 21.2. Página 2: reservas

- Evolución mensual.
- Reservas por sucursal.
- Reservas por género.
- Top 10 películas.
- Reservas por estudio.
- Asientos promedio por reserva.
- Canal de reserva.
- Reservas por segmento de cliente.

---

## 21.3. Página 3: programación y distribuidoras

- Programación mensual.
- Valor neto por distribuidora.
- Descuento por distribuidora.
- Funciones programadas.
- Estado de entrega de copias.
- Programaciones próximas a fin de exhibición.
- Comparación de costos de proyección.

---

## 21.4. Página 4: ocupación

- Asientos reservados por película.
- Funciones disponibles.
- Ocupación estimada.
- Películas de alta demanda y baja disponibilidad.
- Películas de baja demanda y alta disponibilidad.
- Matriz reservas frente a disponibilidad.

---

## 21.5. Página 5: disponibilidad

- Funciones disponibles.
- Funciones mínimas.
- Déficit.
- Exceso.
- Disponibilidad por sucursal.
- Programación frente a reservas.
- Semáforo de disponibilidad.

---

## 21.6. Página 6: metas y sucursales

- Reservas reales frente a meta.
- Cumplimiento.
- Brecha.
- Clientes reales frente a meta.
- Ranking de sucursales.
- Evolución mensual.
- Cumplimiento por zona.

---

## 21.7. Página 7: clientes y satisfacción

- Clientes por segmento.
- Clientes activos.
- Puntuación promedio.
- Tiempo de espera.
- Satisfacción por sucursal.
- Satisfacción frente a reservas.
- Comentarios negativos.

---

## 21.8. Página 8: pronóstico de reservas

Visualizaciones:

- Línea de reservas históricas.
- Línea de reservas pronosticadas.
- Banda de confianza.
- Reservas reales frente a pronóstico.
- Error del modelo.
- Pronóstico por sucursal, como ampliación.
- Tabla de periodos futuros.

Preguntas:

- ¿Qué nivel de reservas se espera?
- ¿Cuál es el rango probable?
- ¿La tendencia esperada es creciente o decreciente?
- ¿Qué sucursales requieren ajustar programación o metas?
- ¿Qué tan preciso ha sido el modelo?

---

## 21.9. Página 9: monitoreo ETL

- Última ejecución.
- Estado del job.
- Duración total.
- Registros procesados.
- Registros rechazados.
- Calidad por fuente.
- Transformaciones fallidas.
- Tabla de errores.
- Histórico de duración de cargas.

---

## 22. Problemas de calidad que deben analizarse

### Clientes

- Documentos con espacios o guiones.
- Registros duplicados.
- Clientes presentes en una sola fuente.
- Nombres con formatos diferentes.
- Correos diferentes para la misma persona.
- Documentos inválidos.
- Valores nulos.

### Ciudades

Ejemplos:

```text
Quito
quito
Quito 
QUITO
```

Reglas:

- Trim.
- Formato título.
- Tabla de equivalencias.
- Separación entre ciudad y sector.

### Sucursales (cines)

- Nombre operacional frente a código corporativo.
- Diferencias entre MySQL y Excel.
- Salas sin correspondencia.

### Películas

- Códigos inexistentes.
- Títulos distintos para el mismo código.
- Formatos inconsistentes.
- Costos de proyección superiores a la tarifa de referencia.
- Películas inactivas con reservas asociadas.

### Fechas

- Fechas de Excel interpretadas como números.
- Fechas fuera del periodo esperado.
- Fecha de fin de exhibición anterior a la fecha de programación.
- Fecha de estreno en sala anterior a la fecha de programación.

### Encuestas

- Puntuaciones fuera del rango 1 a 5.
- Tiempo de espera negativo.
- Cliente inexistente.
- Sucursal inexistente.

---

## 23. Requerimientos funcionales

El sistema debe permitir:

1. Consultar reservas por periodo, sucursal, película y género.
2. Comparar reservas con metas.
3. Analizar programación por distribuidora.
4. Calcular descuentos.
5. Comparar funciones programadas y reservas efectivas.
6. Detectar películas bajo el mínimo de funciones.
7. Identificar programaciones próximas a fin de exhibición.
8. Analizar ocupación estimada.
9. Analizar satisfacción y tiempo de espera.
10. Consultar clientes por segmento.
11. Identificar inconsistencias entre fuentes.
12. Monitorear procesos ETL.
13. Visualizar reservas pronosticadas.
14. Comparar valores reales y pronosticados.
15. Filtrar dashboards por fecha, sucursal, película y distribuidora.

---

## 24. Requerimientos no funcionales

- El ETL debe implementarse en Pentaho.
- El Data Warehouse debe almacenarse en PostgreSQL.
- El modelo debe ser dimensional.
- Las relaciones deben ser principalmente uno a muchos.
- Las claves de las dimensiones deben ser sustitutas.
- Los datos rechazados deben conservarse.
- Cada ejecución debe generar auditoría.
- El script R debe ser reproducible.
- Las credenciales no deben almacenarse en código.
- Power BI no debe repetir transformaciones ya realizadas en Pentaho.
- Los dashboards no deben exponer documentos, teléfonos o correos completos.
- Los gráficos deben tener títulos, unidades y contexto.
- El proceso debe poder ejecutarse nuevamente sin duplicar información.

---

## 25. Distribución por unidades del curso

## Unidad 1: fundamentos y planificación

Producto:

```text
Documento de definición del proyecto
```

Contenido:

- Problema.
- Objetivos.
- Alcance.
- Usuarios.
- Preguntas de negocio.
- Fuentes.
- KPIs.
- Arquitectura.
- Boceto del dashboard.
- Riesgos.

---

## Unidad 2: preparación, minería y serie de tiempo

Producto:

```text
Informe de calidad y análisis predictivo inicial
```

Actividades:

- Perfilamiento.
- Limpieza.
- Transformación.
- Selección de atributos.
- Identificación de valores atípicos.
- Construcción de la serie mensual.
- Exploración de tendencia.
- Aplicación inicial de R.
- Evaluación del modelo.

---

## Unidad 3: Data Warehouse y Pentaho

Producto:

```text
Data Warehouse y procesos ETL
```

Actividades:

- Definición de granularidad.
- Diseño dimensional.
- Creación de staging.
- Creación de dimensiones.
- Creación de hechos.
- Transformaciones Pentaho.
- Jobs de carga.
- Auditoría.
- Manejo de errores.
- Integración del script R.

---

## Unidad 4: visualización en Power BI

Producto:

```text
Reporte final de Power BI
```

Debe incluir:

- Modelo conectado al Data Warehouse.
- Medidas DAX.
- Indicadores.
- Dashboards.
- Pronósticos.
- Panel ETL.
- Conclusiones.
- Recomendaciones.

---

## 26. Entregables

### Entregable 1: planificación

Documento con:

- Problema.
- Objetivos.
- Alcance.
- Arquitectura.
- Fuentes.
- KPIs.
- Cronograma.

### Entregable 2: perfilamiento

- Diccionario de datos.
- Problemas detectados.
- Reglas de limpieza.
- Evidencias.
- Registros rechazados.

### Entregable 3: modelo dimensional

- Diagrama estrella.
- Granularidad.
- Dimensiones.
- Hechos.
- Relaciones.
- Justificación.

### Entregable 4: Pentaho

- Archivos `.ktr`.
- Archivos `.kjb`.
- Variables de ambiente de ejemplo.
- Evidencias de ejecución.
- Auditoría.
- Manejo de errores.

### Entregable 5: R

- Script `.R`.
- Consulta o tabla de entrada.
- Modelo aplicado.
- Métricas de evaluación.
- Pronósticos.
- Interpretación.

### Entregable 6: Power BI

- Archivo `.pbix`.
- Al menos seis páginas analíticas.
- Página de pronóstico.
- Página de monitoreo ETL.
- Medidas DAX.
- Segmentadores.
- Navegación.

### Entregable 7: informe ejecutivo

- Hallazgos.
- Conclusiones.
- Recomendaciones.
- Limitaciones.
- Lecciones aprendidas.

---

## 27. Estructura de carpetas recomendada

```text
CineHub/
│
├── docker/
│   ├── docker-compose.yml
│   ├── cine-init/
│   ├── gestion-init/
│   └── datawarehouse-init/
│
├── dw/
│   └── CrearModelo.sql
│
├── excel/
│   └── programacion_funciones.xlsx
│
├── pentaho/
│   ├── transforms/
│   └── jobs/
│
├── docs/
│   ├── 00 Diseño ER.md
│   ├── 01 Claves comunes.md
│   ├── 02 Perfilamiento_inicial_fuentes_cine.md
│   └── proyecto_bi_cinehub_pentaho_r_powerbi.md
│
├── tareas.md
└── README.md
```

---

## 28. Cronograma técnico resumido

| Fase | Actividad | Herramienta |
|---|---|---|
| 1 | Análisis del negocio | Documentación |
| 2 | Perfilamiento de fuentes | Pentaho y SQL |
| 3 | Diseño dimensional | PostgreSQL |
| 4 | Construcción de staging | Pentaho |
| 5 | Limpieza y homologación | Pentaho |
| 6 | Carga de dimensiones | Pentaho |
| 7 | Carga de hechos | Pentaho |
| 8 | Auditoría ETL | Pentaho y PostgreSQL |
| 9 | Serie temporal | SQL y R |
| 10 | Pronóstico | R |
| 11 | Carga de pronósticos | Pentaho |
| 12 | Dashboards | Power BI |
| 13 | Validación | Todas |
| 14 | Informe final | Documentación |

---

## 29. Decisiones que debería apoyar

- Incrementar o reducir la programación de funciones.
- Redistribuir disponibilidad entre sucursales.
- Negociar con distribuidoras.
- Identificar distribuidoras con retrasos de entrega.
- Promocionar películas de alta demanda.
- Revisar películas de baja ocupación y alta disponibilidad.
- Ajustar metas.
- Mejorar atención en sucursales con altos tiempos de espera.
- Depurar clientes duplicados.
- Planificar programación con base en el pronóstico.
- Corregir problemas recurrentes de calidad.
- Optimizar la duración de los jobs ETL.

---

## 30. Recomendación metodológica

El proyecto debe desarrollarse como un único caso incremental:

```text
Unidad 1 → comprender el negocio y planificar
Unidad 2 → perfilar, limpiar, analizar y pronosticar
Unidad 3 → integrar, modelar y cargar con Pentaho
Unidad 4 → visualizar e interpretar con Power BI
```

La separación de responsabilidades será:

```text
Pentaho = integración y ETL
PostgreSQL = staging, Data Warehouse y auditoría
R = análisis de serie temporal y pronóstico
Power BI = medidas, visualización e interpretación
```

Esta arquitectura permite que los estudiantes comprendan un flujo BI completo y evita utilizar Power BI como sustituto del proceso ETL.

---

## 31. Resultado final esperado

Al finalizar el proyecto, el estudiante habrá construido una solución que:

1. Integra MySQL, PostgreSQL y Excel.
2. Ejecuta procesos ETL mediante Pentaho.
3. Almacena información en un Data Warehouse dimensional.
4. Registra calidad, errores y duración de las cargas.
5. Aplica R para pronosticar reservas.
6. Almacena los pronósticos dentro del Data Warehouse.
7. Presenta KPIs y dashboards en Power BI.
8. Formula recomendaciones para la toma de decisiones.
