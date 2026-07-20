library(DBI)
library(RPostgres)
library(ggplot2)
library(dplyr)

conexion <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("DW_HOST"),
  port = as.integer(Sys.getenv("DW_PORT")),
  dbname = Sys.getenv("DW_DATABASE"),
  user = Sys.getenv("DW_USER"),
  password = Sys.getenv("DW_PASSWORD")
)

encuestas <- dbGetQuery(
  conexion,
  "
  SELECT codigo_sucursal, categoria_satisfaccion, COUNT(*) AS total
  FROM stg.pg_encuesta_valida
  GROUP BY codigo_sucursal, categoria_satisfaccion
  ORDER BY codigo_sucursal
  "
)

dbDisconnect(conexion)

encuestas$categoria_satisfaccion <- factor(
  encuestas$categoria_satisfaccion,
  levels = c("Insatisfecho", "Neutral", "Satisfecho")
)

ggplot(encuestas, aes(x = codigo_sucursal, y = total, fill = categoria_satisfaccion)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Distribución de satisfacción por sucursal",
    x = "Sucursal",
    y = "Porcentaje de encuestas",
    fill = "Categoría"
  ) +
  theme_minimal()
