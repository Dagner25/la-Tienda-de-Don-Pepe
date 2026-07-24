USE tienda_don_pepe;

-- ==========================
-- INDICE PARA PRODUCTOS POR CATEGORIA Y PRECIO
-- ==========================

-- Plan de ejecucion antes del indice
EXPLAIN
SELECT id_producto, nombre_prdct, precio_venta, stock_actual
FROM producto
WHERE id_categoria = 1
  AND precio_venta BETWEEN 4.00 AND 25.00
ORDER BY precio_venta;

-- Creacioon del indice compuesto
CREATE INDEX idx_producto_categoria_precio
ON producto(id_categoria, precio_venta);

-- Plan de ejecucion despues del indice
EXPLAIN
SELECT id_producto, nombre_prdct, precio_venta, stock_actual
FROM producto
WHERE id_categoria = 1
  AND precio_venta BETWEEN 4.00 AND 25.00
ORDER BY precio_venta;

-- Mejora esperada: filtra por categoria y luego por rango de precio

-- ==========================
-- INDICE PARA VENTAS POR ESTADO Y FECHA
-- ==========================

-- Plan de ejecucion antes del indice
EXPLAIN
SELECT id_venta, fch_compra, total, estado
FROM venta
WHERE estado = 'PAGADA'
  AND fch_compra BETWEEN '2026-06-01' AND '2026-07-31';

-- Creacion del indice compuesto
CREATE INDEX idx_venta_estado_fecha
ON venta(estado, fch_compra);

-- Plan de ejecucion despues del indice
EXPLAIN
SELECT id_venta, fch_compra, total, estado
FROM venta
WHERE estado = 'PAGADA'
  AND fch_compra BETWEEN '2026-06-01' AND '2026-07-31';

-- Mejora esperada: usa igualdad por estado y rango por fecha

-- ==========================
-- INDICE PARA DETALLE POR PRODUCTO Y VENTA
-- ==========================

-- Plan de ejecucion antes del indice
EXPLAIN
SELECT id_venta, id_producto, SUM(cantidad) AS unidades, SUM(subtotal) AS ingresos
FROM detalle_venta
WHERE id_producto = 1
GROUP BY id_venta, id_producto;

-- Creacion del indice compuesto
CREATE INDEX idx_detalle_producto_venta
ON detalle_venta(id_producto, id_venta);

-- Plan de ejecucion despues del indice
EXPLAIN
SELECT id_venta, id_producto, SUM(cantidad) AS unidades, SUM(subtotal) AS ingresos
FROM detalle_venta
WHERE id_producto = 1
GROUP BY id_venta, id_producto;

-- Mejora esperada: reduce filas leidas en reportes por producto

-- ==========================
-- INDICE PARA HISTORIAL DE CLIENTE
-- ==========================

-- Plan de ejecucion antes del indice
EXPLAIN
SELECT id_venta, fch_compra, total
FROM venta
WHERE id_cliente = '12345678'
ORDER BY fch_compra DESC;

-- Creacion del indice compuesto.
CREATE INDEX idx_venta_cliente_fecha
ON venta(id_cliente, fch_compra);

-- Plan de ejecucion despues del indice
EXPLAIN
SELECT id_venta, fch_compra, total
FROM venta
WHERE id_cliente = '12345678'
ORDER BY fch_compra DESC;

-- Revisar en EXPLAIN: type, possible_keys, key, rows, filtered y Extra.
-- Con pocos registros MariaDB puede preferir recorrer toda la tabla.
