# Guía: primera hoja de Power BI (CineHub)

Réplica de lo que el ingeniero construyó en el proyecto de farmacia
(`Cubo_Compras.pbix`, hoja **"Resumen de Compras"**), adaptada al cubo de
reservas de CineHub. No se puede generar el `.pbix` por código: es un
formato binario propietario (modelo tabular de Analysis Services)
que solo Power BI Desktop puede escribir de forma segura. Estos son los
pasos exactos para reproducir la misma hoja en tu propio archivo.

## 1. Conexión al Data Warehouse

Levanta el stack (`docker compose up -d` dentro de `docker/`) y en Power BI
Desktop:

`Obtener datos` → `Base de datos PostgreSQL`

```text
Servidor:     localhost:5450
Base de datos: datawarehouse
Usuario:      victor
Contraseña:   victor123
Modo:         Importar
```

Importa del esquema `dw`:

- `dim_tiempo`
- `dim_pelicula`
- `dim_sucursal`
- `dim_cliente`
- `dim_canal`
- `dim_estado_reserva`
- `fact_reserva`

Verifica que Power BI cree las relaciones automáticamente (todas van de
`fact_reserva` hacia cada `dim_*` por su `_key`). Si no las detecta, créalas
manualmente en la vista de modelo (cardinalidad "uno a varios", dirección
única desde la dimensión hacia el hecho).

## 2. Tabla de medidas

El ingeniero no puso las medidas sueltas dentro de `fact_compras`: creó una
tabla desconectada llamada **`Medidas`** solo para alojar el DAX. Haz lo
mismo aquí:

`Insertar datos` → nombra la tabla `Medidas` → deja una sola columna con un
valor cualquiera (por ejemplo `Valor = 1`).

Sobre esa tabla, crea estas medidas (ya están documentadas en
`docs/proyecto_bi_cinehub_pentaho_r_powerbi.md`, sección 20):

```DAX
Asientos reservados =
SUM(fact_reserva[cantidad_asientos])

Número de reservas =
DISTINCTCOUNT(fact_reserva[numero_reserva])

Reservas canceladas =
CALCULATE(
    DISTINCTCOUNT(fact_reserva[numero_reserva]),
    fact_reserva[estado_reserva] = "CANCELADA"
)
```

## 3. Hoja "Resumen de Reservas"

Crea una página nueva, renómbrala `Resumen de Reservas` y añade tres
visuales, en el mismo orden y disposición que la hoja de farmacia:

1. **Tarjeta (Card)** — arriba a la izquierda.
   Campo: `Medidas[Asientos reservados]`.

2. **Gráfico de líneas (Line chart)** — debajo, ancho completo.
   Eje X: `dim_tiempo[anio_mes]`.
   Eje Y: `Medidas[Asientos reservados]`.
   Esto muestra la tendencia mensual, igual que "Valor neto comprado" por
   `anio_mes` en farmacia.

3. **Gráfico de columnas (Column chart)** — debajo del anterior, ancho
   completo.
   Eje X: `dim_sucursal[nombre_sucursal]`.
   Eje Y: `Medidas[Asientos reservados]`.
   Farmacia desglosaba por `dim_distribuidor`; en CineHub el desglose
   equivalente para una hoja de reservas es por sucursal (cine).

Guarda como `powerbi/Reservas_CineHub.pbix`.

## 4. Ampliación opcional

Cuando tengas `fact_pronostico_reservas` cargado (ver sección 17 del
documento del proyecto), añade una segunda hoja con el pronóstico, igual
que contempla el plan original (`21.8. Página 8: pronóstico de reservas`).
