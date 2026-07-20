library(DBI)
library(RPostgres)

# 1. Conexión a PostgreSQL staging
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
  SELECT fecha_hora, descuento
  FROM stg.mysql_reserva_valida
  WHERE codigo_sucursal = 'CENTRO'
  ORDER BY fecha_hora
  "
)

dbDisconnect(conexion)

reservas$fecha_hora <- as.Date(reservas$fecha_hora)

reservas$tiempo <- as.numeric(
  reservas$fecha_hora - min(reservas$fecha_hora)
)

modelo <- lm(descuento ~ tiempo, data = reservas)

plot(reservas$fecha_hora, reservas$descuento,
     main = "Tendencia de descuentos - Sucursal CENTRO",
     xlab = "Fecha", ylab = "Descuento ($)")

orden <- order(reservas$fecha_hora)

lines(
  reservas$fecha_hora[orden],
  predict(modelo)[orden],
  lwd = 2,
  col = "blue"
)

summary(modelo)
