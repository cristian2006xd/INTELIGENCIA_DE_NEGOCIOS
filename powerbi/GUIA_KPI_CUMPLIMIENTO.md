# Guía: hoja de KPI de cumplimiento (CineHub)

Réplica de la hoja de KPI que el ingeniero construyó en `Cubo_Compras.pbix`
("Pocentaje recibido" con velocímetro, área y tarjetas), adaptada al cubo
de reservas de CineHub. Igual que en [GUIA_PRIMERA_HOJA.md](GUIA_PRIMERA_HOJA.md),
esto no genera el `.pbix` (formato binario propietario): son los pasos
exactos para reproducir la misma hoja en `powerbi/Cubo_Cine.pbix`.

El indicador elegido es **cumplimiento de la meta de reservas**: compara
`Asientos reservados` (real, desde `fact_reserva`) contra `meta_reservas`
(objetivo mensual por sucursal, tabla `meta_mensual` del sistema de
gestión). Es el mismo tipo de KPI real-vs-meta que farmacia usa para
"porcentaje recibido".

## 0. Prerrequisito: que la meta esté en el Data Warehouse

La meta mensual vive en la base operativa `gestion` (Postgres, puerto
5434) y se copia a `stg.pg_meta_mensual` dentro de la base `datawarehouse`
(puerto 5450) mediante el job de Pentaho `jProgramacion_Stage.kjb` →
transformación `tPG_MetaMensual.ktr`.

Antes de continuar, ejecuta ese job (o el job completo de staging) para
que `stg.pg_meta_mensual` tenga filas. Verifica en Adminer
(`localhost:8090`, servidor `staging`, usuario `cris` / `cristian123`):

```sql
SELECT * FROM stg.pg_meta_mensual LIMIT 5;
```

## 1. Importar la tabla de metas a Power BI

En el mismo archivo donde ya importaste `dw.*` (ver paso 1 de
GUIA_PRIMERA_HOJA.md), añade una tabla más desde la misma conexión
PostgreSQL (`localhost:5450`, base `datawarehouse`):

```text
Esquema: stg
Tabla:   pg_meta_mensual
```

Columnas: `codigo_sucursal`, `periodo`, `meta_reservas`, `meta_clientes`.

## 2. Columna calculada `anio_mes`

`stg.pg_meta_mensual` es staging: no trae llave a `dim_tiempo`. Para
poder cruzarla por mes, agrega una columna calculada sobre la tabla
`pg_meta_mensual`:

```DAX
anio_mes = FORMAT(pg_meta_mensual[periodo], "YYYY-MM")
```

Esto reproduce el mismo texto que ya existe en `dim_tiempo[anio_mes]`
(columna `VARCHAR(7)` con formato `"2026-01"`).

## 3. Relación con `dim_sucursal`

En la vista de modelo, crea la relación:

```text
pg_meta_mensual[codigo_sucursal]  →  dim_sucursal[codigo_sucursal]
```

Cardinalidad "varios a uno", dirección única desde `pg_meta_mensual`
hacia `dim_sucursal`. Así, cualquier filtro por sucursal afecta tanto
las reservas reales como la meta.

**No** relaciones `pg_meta_mensual` directamente con `dim_tiempo`:
`dim_tiempo` está a grano diario (muchas filas por mes), así que la
relación quedaría "varios a varios" y Power BI la rechazaría o la
volvería ambigua. El cruce por mes se resuelve con DAX (`TREATAS`) en
el siguiente paso, exactamente para evitar ese problema.

## 4. Medidas nuevas (tabla `Medidas`)

Sobre la misma tabla `Medidas` de GUIA_PRIMERA_HOJA.md, agrega:

```DAX
Meta reservas =
CALCULATE(
    SUM(pg_meta_mensual[meta_reservas]),
    TREATAS(VALUES(dim_tiempo[anio_mes]), pg_meta_mensual[anio_mes])
)

Porcentaje cumplimiento reservas =
DIVIDE([Asientos reservados], [Meta reservas])

Meta porcentaje cumplimiento = 0.90

Indice de cumplimiento =
DIVIDE([Porcentaje cumplimiento reservas], [Meta porcentaje cumplimiento])
```

`TREATAS` aplica los valores de `dim_tiempo[anio_mes]` (el que sí tiene
un slicer/árbol de filtro normal) como si fuera una relación hacia
`pg_meta_mensual[anio_mes]`, sin tener que crear la relación física
problemática del paso 3. Por eso `[Meta reservas]` respeta el mismo
filtro de año/mes que `[Asientos reservados]`.

`Meta porcentaje cumplimiento` es el umbral de gestión (90 %, igual que
el ejemplo de farmacia); ajústalo si el docente pide otro valor.

## 5. Hoja "KPI Cumplimiento de Reservas"

Página nueva, mismo layout que la hoja de farmacia:

1. **Filtro en árbol (arriba a la izquierda)**, fuera de los visuales:
   jerarquía `dim_tiempo[anio]` → `dim_tiempo[anio_mes]` como segmentador
   (Filtros o un visual de segmentación jerárquica).

2. **Velocímetro (Gauge)** — arriba a la izquierda.
   - Valor: `Medidas[Porcentaje cumplimiento reservas]`
   - Valor de destino (target): `Medidas[Meta porcentaje cumplimiento]`
   - Mínimo 0 %, máximo 100 %.

3. **Gráfico de área (Area chart)** — arriba a la derecha, mismo alto
   que el velocímetro.
   - Eje X: `dim_tiempo[anio_mes]`
   - Valores: `Medidas[Porcentaje cumplimiento reservas]` y
     `Medidas[Meta porcentaje cumplimiento]`

4. **Tres tarjetas (Card)** — abajo, una fila:
   - `Medidas[Meta porcentaje cumplimiento]`
   - `Medidas[Porcentaje cumplimiento reservas]`
   - `Medidas[Indice de cumplimiento]`

Guarda. Esta hoja queda como segunda página de
`powerbi/Cubo_Cine.pbix`, después de "Resumen de Reservas".

## 6. Variación opcional: KPI por sucursal

Si el docente pide desglosar el indicador (no solo el agregado), añade
una tabla o gráfico de columnas con `dim_sucursal[nombre_sucursal]` en
el eje y `Medidas[Porcentaje cumplimiento reservas]` como valor, con
formato condicional (rojo/verde) según si supera
`Medidas[Meta porcentaje cumplimiento]`. Esto reutiliza la misma lógica
de indicador de semáforo que ya existe en `dw.dim_estado_reserva`
(`color_semaforo`).
