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

reservas <- dbGetQuery(
  conexion,
  "
  SELECT codigo_sucursal, canal_homologado, COUNT(*) AS total_reservas
  FROM stg.mysql_reserva_valida
  GROUP BY codigo_sucursal, canal_homologado
  ORDER BY codigo_sucursal
  "
)

dbDisconnect(conexion)

ggplot(reservas, aes(x = codigo_sucursal, y = total_reservas, fill = canal_homologado)) +
  geom_col(position = "stack") +
  labs(
    title = "Reservas confirmadas por sucursal y canal",
    x = "Sucursal",
    y = "Total de reservas",
    fill = "Canal"
  ) +
  theme_minimal()
