import pandas as pd
import matplotlib.pyplot as plt

from sqlalchemy import create_engine
from sklearn.linear_model import LinearRegression


# 1. Conexión a PostgreSQL
conexion = create_engine(
    "postgresql+psycopg://victor:victor123@staging:5432/datawarehouse"
)


# 2. Consultar datos de reservas
sql = """
SELECT fecha_hora, descuento
FROM stg.mysql_reserva_valida
WHERE codigo_sucursal = 'CENTRO'
ORDER BY fecha_hora
"""

reservas = pd.read_sql(sql, conexion)


# 3. Preparar los datos
reservas["fecha_hora"] = pd.to_datetime(reservas["fecha_hora"])

reservas["dias"] = (
    reservas["fecha_hora"] - reservas["fecha_hora"].min()
).dt.days


# 4. Variables del modelo
X = reservas[["dias"]]
y = reservas["descuento"]


# 5. Crear y entrenar el modelo
modelo = LinearRegression()

modelo.fit(X, y)


# 6. Calcular predicciones
reservas["descuento_estimado"] = modelo.predict(X)


# 7. Mostrar resultados
print("Intercepto:", modelo.intercept_)
print("Pendiente:", modelo.coef_[0])


# 8. Graficar
plt.scatter(
    reservas["fecha_hora"],
    reservas["descuento"],
    label="Descuento real"
)

plt.plot(
    reservas["fecha_hora"],
    reservas["descuento_estimado"],
    linewidth=2,
    label="Regresión"
)

plt.xlabel("Fecha de reserva")
plt.ylabel("Descuento ($)")
plt.title("Regresión del descuento - Sucursal CENTRO")
plt.legend()

# Guardar el gráfico en un archivo
plt.savefig(
    "/app/resultados/regresion.png",
    dpi=150,
    bbox_inches="tight"
)

plt.close()

print("Gráfico guardado en resultados/regresion.png")
