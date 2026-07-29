/* =========================================================
   COORDENADAS GEORREFERENCIADAS
   Agrega latitud/longitud a dim_sucursal para el visual de
   Mapa en Power BI (ya vienen pobladas en gestion.sucursal).
   ========================================================= */

ALTER TABLE dw.dim_sucursal
ADD COLUMN IF NOT EXISTS latitud NUMERIC(9,6),
ADD COLUMN IF NOT EXISTS longitud NUMERIC(9,6);
