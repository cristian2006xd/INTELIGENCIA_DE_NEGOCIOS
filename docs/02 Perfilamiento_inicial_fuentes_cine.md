# Perfilamiento inicial de fuentes

## Proyecto BI para una cadena de cines (CineHub)

**Fecha del perfilamiento:** 15 de julio de 2026
**Método:** análisis estático de los scripts SQL y lectura directa del libro Excel.
**Fuentes analizadas:**

1. `01_recrear_cine.sql` (MySQL, base `cine_db`)
2. `01_recrear_gestion.sql` (PostgreSQL, esquema `gestion`)
3. `programacion_funciones.xlsx`

> Este documento presenta los resultados contenidos en los archivos fuente. Los conteos se obtuvieron de las sentencias `INSERT` y de las filas efectivas del libro Excel, sin requerir la ejecución previa de los motores MySQL y PostgreSQL.

---

# 1. Resumen ejecutivo

| Fuente | Entidad principal | Registros | Periodo principal | Resultado general |
|---|---|---:|---|---|
| MySQL | Reservas | 4.102 | 2025-01-01 a 2026-12-31 | Datos completos, con necesidad de homologar sucursales, canales de reserva y clientes sin documento |
| MySQL | Detalle de reservas | 12.305 | 2025-2026 | Integridad referencial correcta |
| MySQL | Disponibilidad de funciones | 400 | Corte durante 2026 | 12 registros bajo mínimo y 172 fechas de última función posteriores al último movimiento |
| PostgreSQL | Clientes corporativos | 100 filas, 99 documentos únicos | Registros 2024-2026 | Un documento duplicado y 16 ciudades nulas |
| PostgreSQL | Metas mensuales | 96 | 2025-01 a 2026-12 | Cobertura completa: 4 sucursales × 24 meses |
| PostgreSQL | Encuestas | 1.460 | 2025-01-01 a 2026-12-31 | 3 puntuaciones fuera de rango y 28 clientes sin correspondencia |
| Excel | Programación de funciones | 874 | 2025-01-01 a 2026-12-31 | Sin claves duplicadas, nulos ni errores aritméticos detectados |
| Excel | Películas | 100 | Maestro | Coincidencia total con el maestro de MySQL |
| Excel | Salas | 4 | Maestro | Coincidencia total con las sucursales de PostgreSQL |

## Conclusión inicial

Las tres fuentes son utilizables para construir el proyecto BI. Los principales trabajos de calidad deberán concentrarse en:

- homologación de nombres de sucursales (cines) en MySQL;
- estandarización de canales de reserva;
- tratamiento de reservas sin documento de cliente;
- resolución del documento duplicado en PostgreSQL;
- normalización de ciudades;
- validación de encuestas;
- revisión de consistencia temporal de la disponibilidad de funciones;
- tratamiento de fechas posteriores al momento de ejecución del proyecto.

---

# 2. Fuente MySQL: sistema operacional de cine

## 2.1. Base y tablas

**Base definida:** `cine_db`

| Tabla | Registros | Clave primaria | Nulos relevantes |
|---|---:|---|---|
| `estudio` | 12 | `codigo_estudio` | 0 |
| `genero` | 12 | `codigo_genero` | 0 |
| `pelicula` | 100 | `codigo_pelicula` | 0 |
| `cliente` | 100 | `codigo_cliente` | `apellido2`: 100; `telefono_alterno`: 100; `observaciones`: 100 |
| `reserva` | 4.102 | `numero_reserva` | `documento_cliente`: 100 NULL; `observacion`: 4.102 |
| `detalle_reserva` | 12.305 | `numero_reserva`, `linea` | 0 |
| `disponibilidad` | 400 | `sucursal_origen`, `codigo_pelicula` | 0 |

## 2.2. Rangos de fechas

| Entidad | Campo | Fecha mínima | Fecha máxima |
|---|---|---|---|
| Cliente | `fecha_alta` | 2024-01-01 | 2026-11-26 |
| Reserva | `fecha_hora` | 2025-01-01 09:00 | 2026-12-31 12:51 |
| Disponibilidad | `fecha_ultima_funcion` | 2026-01-01 | 2026-12-25 |
| Disponibilidad | `fecha_ultimo_movimiento` | 2026-01-04 | 2026-12-26 |

## 2.3. Integridad y duplicados

- No se detectaron claves primarias duplicadas en ninguna tabla.
- No existen líneas de detalle sin cabecera de reserva.
- No existen líneas asociadas a películas inexistentes.
- No existen películas asociadas a géneros o estudios inexistentes.
- Los 100 documentos de la tabla `cliente` tienen 10 dígitos y son únicos.

## 2.4. Calidad de reservas

### Documentos de cliente

- 100 reservas contienen `documento_cliente = NULL`.
- 108 reservas adicionales contienen una cadena vacía.
- Total de reservas sin documento utilizable: **208**.
- Los documentos no vacíos corresponden a clientes existentes en el maestro MySQL.

### Sucursales (cines) encontradas

Se detectaron 12 variantes textuales para cuatro cines corporativos:

| Valor de origen | Registros |
|---|---:|
| `NORTE` | 522 |
| `Cine Norte` | 248 |
| `CINE NORTE` | 246 |
| `CENTRO` | 339 |
| `Cine Centro` | 373 |
| `CINE CENTRO` | 327 |
| `SUR` | 361 |
| `Cine Sur` | 340 |
| `CINE SUR` | 332 |
| `VALLE` | 332 |
| `Cine Valle` | 346 |
| `CINE VALLE` | 336 |

**Acción ETL requerida:** mapear todas las variantes a los códigos `NORTE`, `CENTRO`, `SUR` y `VALLE`.

### Canales de reserva

| Valor original | Registros |
|---|---:|
| `APP` | 821 |
| `app` | 820 |
| `WEB` | 821 |
| `Taquilla` | 820 |
| `TAQUILLA` | 820 |

**Acción ETL requerida:** convertir a mayúsculas y consolidar en `APP`, `WEB` y `TAQUILLA`.

### Estado de reservas

| Estado | Registros |
|---|---:|
| `CONFIRMADA` | 4.024 |
| `CANCELADA` | 78 |

Las reservas canceladas deben conservarse para trazabilidad, pero excluirse de las medidas de ocupación efectivas cuando corresponda.

## 2.5. Calidad de películas

- 100 películas.
- 2 películas inactivas (fuera de cartelera).
- No existen costos de proyección menores o iguales a cero.
- No existen tarifas de referencia menores o iguales a cero.
- No se detectaron películas cuyo costo de proyección sea mayor o igual a la tarifa de referencia de sala.
- La integridad con género y estudio es completa.

## 2.6. Calidad de disponibilidad

- 400 registros: 4 sucursales × 100 películas.
- 12 registros tienen `funciones_disponibles < funciones_minimas`.
- No existen existencias negativas.
- No existen mínimos negativos.
- En 172 registros, `fecha_ultima_funcion` es posterior a `fecha_ultimo_movimiento`.

**Interpretación:** la última función registrada debería constituir un movimiento. La regla temporal debe revisarse o el campo `fecha_ultimo_movimiento` debe actualizarse tomando la mayor fecha entre ambos campos.

## 2.7. Problemas detectados en MySQL

| Código | Problema | Registros afectados | Severidad | Tratamiento |
|---|---|---:|---|---|
| MY-01 | Reservas sin documento de cliente | 208 | Media | Asignar espectador "Consumidor final/Desconocido" |
| MY-02 | Variantes de nombres de cine (sucursal) | 4.102 | Alta | Aplicar tabla de homologación |
| MY-03 | Variantes de canal de reserva | 1.640 requieren normalización de mayúsculas | Media | `TRIM` + `UPPER` |
| MY-04 | Fechas inconsistentes en disponibilidad | 172 | Alta | Validar y corregir regla de fecha |
| MY-05 | Películas bajo mínimo de funciones | 12 | Informativa | Mantener como indicador de programación |
| MY-06 | Fechas posteriores al 15-07-2026 | Parte de clientes, reservas y disponibilidad | Media | Marcar como datos simulados futuros |

---

# 3. Fuente PostgreSQL: sistema corporativo de gestión

## 3.1. Esquema y tablas

**Esquema definido:** `gestion`

| Tabla | Registros | Clave esperada | Nulos relevantes |
|---|---:|---|---|
| `zona` | 4 | `codigo_zona` | 0 |
| `sucursal` | 4 | `codigo_sucursal` | 0 |
| `segmento_cliente` | 4 | `codigo_segmento` | 0 |
| `cliente` | 100 | `documento` | `ciudad`: 16 |
| `meta_mensual` | 96 | `codigo_sucursal`, `periodo` | 0 |
| `encuesta_satisfaccion` | 1.460 | Identificador generado por la tabla | 0 |

## 3.2. Rangos de fechas

| Entidad | Campo | Fecha mínima | Fecha máxima |
|---|---|---|---|
| Sucursal | `fecha_apertura` | 2020-08-15 | 2024-04-20 |
| Cliente | `fecha_nacimiento` | 1968-01-27 | 2005-10-01 |
| Cliente | `fecha_registro` | 2024-01-01 | 2026-11-26 |
| Meta mensual | `periodo` | 2025-01-01 | 2026-12-01 |
| Encuesta | `fecha` | 2025-01-01 | 2026-12-31 |

## 3.3. Calidad de clientes

- 100 filas.
- 99 documentos únicos.
- Documento duplicado: **`1710000605`**.
- El documento duplicado pertenece a dos personas diferentes.
- Existe un documento de MySQL que no aparece como registro único en PostgreSQL: **`1710000666`**.
- 16 clientes tienen ciudad nula.
- Valores de ciudad:
  - `Quito`: 17.
  - `quito`: 17.
  - `Quito ` (con espacio): 17.
  - `Sangolquí`: 17.
  - `Cumbayá`: 16.
  - NULL: 16.
- Parte de los clientes posee `fecha_registro` posterior al 15 de julio de 2026.

**Acciones ETL requeridas:**

1. Resolver el duplicado mediante revisión del registro correcto.
2. Normalizar ciudad con `TRIM` y formato título.
3. Asignar "No especificada" a ciudades nulas, conservando una bandera de calidad.
4. Etiquetar los registros futuros como datos simulados.

## 3.4. Calidad de sucursales, zonas y segmentos

- No existen códigos duplicados.
- Las cuatro sucursales tienen una zona válida.
- Los clientes utilizan segmentos existentes.
- No se detectaron claves foráneas huérfanas.

## 3.5. Calidad de metas

- 96 registros.
- Cobertura esperada completa:
  - 4 sucursales.
  - 24 meses.
  - Periodo de enero de 2025 a diciembre de 2026.
- No existen metas de reservas negativas o iguales a cero.
- No existen metas de clientes negativas o iguales a cero.
- No existen sucursales inexistentes en las metas.

## 3.6. Calidad de encuestas

- 1.460 encuestas.
- 3 puntuaciones se encuentran fuera del rango permitido de 1 a 5.
- No existen tiempos de espera negativos.
- Todas las sucursales existen.
- 28 encuestas hacen referencia a documentos que no aparecen en el maestro de clientes PostgreSQL.
- Distribución de comentarios prácticamente uniforme entre valores como "Excelente atención", "Falto la película solicitada en cartelera", "Demasiada espera en taquilla", "Sala cómoda", "Proceso de reserva ágil", entre otros.

## 3.7. Problemas detectados en PostgreSQL

| Código | Problema | Registros afectados | Severidad | Tratamiento |
|---|---|---:|---|---|
| PG-01 | Documento duplicado asignado a personas diferentes | 2 filas | Crítica | Corregir antes de integrar clientes |
| PG-02 | Cliente de MySQL ausente en PostgreSQL | 1 documento | Media | Clasificar como "Solo MySQL" |
| PG-03 | Ciudad nula | 16 | Media | Asignar valor desconocido y bandera |
| PG-04 | Diferencia entre `Quito` y `quito` | 17 | Baja | Normalizar texto |
| PG-05 | Puntuaciones fuera de 1 a 5 | 3 | Alta | Rechazar o corregir mediante regla |
| PG-06 | Encuestas con cliente inexistente | 28 | Alta | Cargar cliente desconocido o enviar a rechazo |
| PG-07 | Registros futuros | Clientes y datos de 2026 posteriores al corte | Media | Etiquetar como simulados |

---

# 4. Fuente Excel: programación de funciones

## 4.1. Hojas y dimensiones

| Hoja | Filas de datos | Columnas | Nulos |
|---|---:|---:|---:|
| `Programacion_2025_2026` | 874 | 17 | 0 |
| `Distribuidoras` | 8 | 5 | 0 |
| `Peliculas` | 100 | 7 | 0 |
| `Salas` | 4 | 5 | 0 |
| `Resumen_Mensual` | 24 | 9 | Columna separadora vacía |

## 4.2. Programación

### Rangos

| Campo | Mínimo | Máximo |
|---|---|---|
| `fecha_programacion` | 2025-01-01 | 2026-12-31 |
| `fecha_fin_exhibicion` | 2026-01-04 | 2028-01-30 |

### Claves y duplicados

- 0 identificadores `id_programacion` duplicados.
- 0 números de programación duplicados.
- 0 copias de distribuidora duplicadas.
- 0 fechas de fin de exhibición anteriores a la fecha de programación.
- 0 estrenos de sala anteriores a la fecha de programación.

### Integridad referencial

- 0 registros con distribuidora inexistente.
- 0 registros con película inexistente.
- 0 registros con sala de destino inexistente.

### Valores numéricos

- 0 cantidades de funciones menores o iguales a cero.
- 0 costos menores o iguales a cero.
- 0 descuentos fuera del rango 0 % a 100 %.
- 0 inconsistencias en el cálculo de subtotal bruto, valor de descuento y valor neto.

### Estado de entrega de copia

| Estado | Registros |
|---|---:|
| `RECIBIDO` | 860 |
| `PENDIENTE` | 14 |

Las 14 programaciones pendientes deben mantenerse para medir entregas abiertas y cumplimiento de distribuidoras.

## 4.3. Distribuidoras

- 8 distribuidoras.
- Códigos únicos.
- Sin campos nulos.
- Sin duplicados de clave.
- Contienen datos suficientes para construir `dim_distribuidora`.

## 4.4. Películas

- 100 películas.
- Códigos únicos.
- Sin campos nulos.
- Coincidencia total con el maestro de películas MySQL en: código, título, género, estudio, formato, costo base y tarifa de referencia.

**Resultado:** MySQL puede mantenerse como fuente maestra y Excel como fuente de validación.

## 4.5. Salas

- 4 salas (cines).
- Códigos únicos.
- Sin nulos.
- Coincidencia total con las sucursales PostgreSQL en: código, nombre, zona, ciudad y dirección.

**Resultado:** PostgreSQL puede mantenerse como fuente maestra de sucursales.

## 4.6. Resumen mensual

La hoja contiene 24 periodos y dos bloques de resumen separados visualmente por una columna vacía. Debido a esta estructura no debe utilizarse como fuente transaccional principal.

**Uso recomendado:** validación de totales mensuales calculados desde `Programacion_2025_2026`.

## 4.7. Problemas detectados en Excel

| Código | Problema | Registros afectados | Severidad | Tratamiento |
|---|---|---:|---|---|
| XL-01 | Fechas representadas internamente como serial de Excel | 874 registros | Normal | Convertir a fecha durante ETL |
| XL-02 | Hoja `Resumen_Mensual` con columna separadora | 24 filas | Baja | No cargar directamente; usar solo para control |
| XL-03 | Programaciones pendientes | 14 | Informativa | Mantener como estado analítico |
| XL-04 | Datos posteriores al 15-07-2026 | Parte del periodo 2026 | Media | Identificar como datos simulados futuros |

---

# 5. Comparación e integración entre fuentes

## 5.1. Películas: MySQL frente a Excel

| Validación | Resultado |
|---|---|
| Códigos presentes en ambas fuentes | 100 |
| Solo en MySQL | 0 |
| Solo en Excel | 0 |
| Diferencias de título, género, estudio, formato, costo o tarifa | 0 |

**Decisión:** usar MySQL como fuente maestra de `dim_pelicula`.

## 5.2. Sucursales: PostgreSQL frente a Excel

| Validación | Resultado |
|---|---|
| Códigos presentes en ambas fuentes | 4 |
| Solo en PostgreSQL | 0 |
| Solo en Excel | 0 |
| Diferencias de nombre, zona, ciudad o dirección | 0 |

**Decisión:** usar PostgreSQL como fuente maestra de `dim_sucursal`.

## 5.3. Clientes: MySQL frente a PostgreSQL

| Validación | Resultado |
|---|---:|
| Clientes MySQL | 100 |
| Filas de clientes PostgreSQL | 100 |
| Documentos únicos PostgreSQL | 99 |
| Documentos coincidentes | 99 |
| Solo en MySQL | 1 |
| Solo en PostgreSQL | 0 |
| Documento duplicado PostgreSQL | `1710000605` |
| Documento solo MySQL | `1710000666` |

**Decisión:** integrar por documento normalizado y crear estados:

- `Integrado`.
- `Solo MySQL`.
- `Solo PostgreSQL`.
- `Duplicado probable`.
- `Documento inválido`.
- `Consumidor final`.

## 5.4. Homologación propuesta para sucursales MySQL

| Valor MySQL | Código corporativo |
|---|---|
| `NORTE`, `Cine Norte`, `CINE NORTE` | `NORTE` |
| `CENTRO`, `Cine Centro`, `CINE CENTRO` | `CENTRO` |
| `SUR`, `Cine Sur`, `CINE SUR` | `SUR` |
| `VALLE`, `Cine Valle`, `CINE VALLE` | `VALLE` |

---

# 6. Reglas iniciales de limpieza y validación

## 6.1. Texto

```text
TRIM
UPPER o formato título según el atributo
eliminación de espacios dobles
normalización de tildes solo para comparación, no para presentación
```

## 6.2. Documentos

```text
eliminar espacios
eliminar guiones y caracteres no numéricos
validar longitud de 10 dígitos
identificar duplicados
asignar clave desconocida a reservas sin documento
```

## 6.3. Fechas

```text
convertir seriales de Excel a DATE
validar fecha_fin_exhibicion >= fecha_programacion
validar fecha_estreno_sala >= fecha_programacion
validar fecha_ultimo_movimiento >= fecha_ultima_funcion
marcar fechas posteriores a la fecha de corte como simuladas
```

## 6.4. Valores numéricos

```text
cantidad_asientos > 0
costo_proyeccion_unitario > 0
tarifa_referencia_sala > costo_proyeccion_referencia
0 <= descuento_pct <= 100
1 <= puntuacion_encuesta <= 5
tiempo_espera_minutos >= 0
funciones_disponibles >= 0
funciones_minimas >= 0
```

## 6.5. Integridad

```text
pelicula debe existir en maestro
sucursal debe existir en maestro
distribuidora debe existir en maestro
cliente debe existir o resolverse como desconocido
segmento y zona deben existir
```

---

# 7. Registros que deben enviarse a rechazo o revisión

| Origen | Regla | Cantidad |
|---|---|---:|
| PostgreSQL clientes | Documento duplicado con personas diferentes | 2 filas |
| PostgreSQL encuestas | Puntuación fuera de 1 a 5 | 3 |
| PostgreSQL encuestas | Cliente sin correspondencia | 28 |
| MySQL disponibilidad | Fecha de última función posterior al último movimiento | 172 |
| MySQL reservas | Documento NULL o vacío | 208; no se rechazan, se asignan a cliente desconocido |
| MySQL reservas | Estado `CANCELADA` | 78; no se rechazan, se excluyen de reservas efectivas |
| Excel programación | Inconsistencias estructurales o aritméticas | 0 |

---

# 8. Evaluación general por fuente

| Fuente | Completitud | Unicidad | Integridad | Consistencia | Evaluación |
|---|---|---|---|---|---|
| MySQL | Alta | Alta | Alta | Media por sucursales, canales y fechas de disponibilidad | Apta con transformación |
| PostgreSQL | Media-alta | Media por duplicado de cliente | Media-alta | Media por ciudades y encuestas | Apta con depuración |
| Excel | Muy alta | Alta | Alta | Alta | Apta para carga |

---

# 9. Próximo paso recomendado

Después de aprobar este perfilamiento se debe:

1. crear los esquemas `stg`, `dw` y `audit`;
2. crear tablas de equivalencia para sucursales y canales de reserva;
3. definir el miembro desconocido de cada dimensión;
4. implementar en Pentaho las extracciones hacia staging;
5. separar registros válidos, rechazados y sujetos a revisión;
6. cargar primero las dimensiones;
7. cargar después las tablas de hechos;
8. registrar métricas de calidad en `audit.etl_ejecucion`, `audit.etl_detalle` y `audit.etl_rechazo`.

---

# 10. Criterio de aceptación de la fase de perfilamiento

La fase se considera completa cuando:

- los conteos de cada fuente han sido verificados;
- las reglas de calidad han sido aprobadas;
- el duplicado de cliente está identificado;
- las 12 variantes de sucursal tienen equivalencia;
- los canales de reserva están normalizados;
- los registros de encuesta inválidos tienen tratamiento definido;
- las fechas futuras se reconocen como parte del conjunto simulado;
- el equipo acepta MySQL como maestro de películas y PostgreSQL como maestro de sucursales.
