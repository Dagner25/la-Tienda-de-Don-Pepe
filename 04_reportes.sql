USE tienda_don_pepe;

DELIMITER //

-- ==========================
-- REPORTE DE PRODUCTOS MAS VENDIDOS
-- ==========================

DROP PROCEDURE IF EXISTS sp_reporte_productos_mas_vendidos//

CREATE PROCEDURE sp_reporte_productos_mas_vendidos(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_cantidad_minima INT
)
BEGIN
    -- Agrupacion por producto y categoria
    SELECT
        p.id_producto,
        p.nombre_prdct AS producto,
        COALESCE(c.nmbr_categoria, 'Sin categoria') AS categoria,
        SUM(dv.cantidad) AS cantidad_total_vendida,
        COUNT(DISTINCT v.id_venta) AS numero_de_ventas,
        SUM(dv.subtotal) AS ingreso_total_generado,
        AVG(dv.precio_unitario) AS precio_promedio,
        MIN(DATE(v.fch_compra)) AS primera_fecha_venta,
        MAX(DATE(v.fch_compra)) AS ultima_fecha_venta
    FROM detalle_venta AS dv
    INNER JOIN venta AS v ON v.id_venta = dv.id_venta
    INNER JOIN producto AS p ON p.id_producto = dv.id_producto
    LEFT JOIN categoria AS c ON c.id_categoria = p.id_categoria
    WHERE v.estado <> 'ANULADA'
      AND DATE(v.fch_compra) BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY p.id_producto, p.nombre_prdct, c.nmbr_categoria
    HAVING SUM(dv.cantidad) >= p_cantidad_minima
    ORDER BY cantidad_total_vendida DESC, ingreso_total_generado DESC;
END//

-- ==========================
-- REPORTE DE INGRESOS POR CATEGORIA
-- ==========================

DROP PROCEDURE IF EXISTS sp_reporte_ingresos_por_categoria//

CREATE PROCEDURE sp_reporte_ingresos_por_categoria(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_monto_minimo DECIMAL(12,2)
)
BEGIN
    -- Filtro minimo mediante HAVING
    SELECT
        COALESCE(c.nmbr_categoria, 'Sin categoria') AS categoria,
        COUNT(DISTINCT v.id_venta) AS ventas,
        COUNT(dv.id_detalle) AS lineas_vendidas,
        SUM(dv.cantidad) AS unidades_vendidas,
        SUM(dv.subtotal) AS ingresos,
        AVG(dv.subtotal) AS ticket_promedio_por_linea,
        MAX(dv.subtotal) AS mayor_subtotal
    FROM detalle_venta AS dv
    INNER JOIN venta AS v ON v.id_venta = dv.id_venta
    INNER JOIN producto AS p ON p.id_producto = dv.id_producto
    LEFT JOIN categoria AS c ON c.id_categoria = p.id_categoria
    WHERE v.estado <> 'ANULADA'
      AND DATE(v.fch_compra) BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY c.id_categoria, c.nmbr_categoria
    HAVING SUM(dv.subtotal) >= p_monto_minimo
    ORDER BY ingresos DESC;
END//

DELIMITER ;

-- ==========================
-- EJECUCION DE REPORTES
-- ==========================

CALL sp_reporte_productos_mas_vendidos('2026-06-01', '2026-07-31', 3);
CALL sp_reporte_ingresos_por_categoria('2026-06-01', '2026-07-31', 20.00);

-- Productos que requieren reposicion
SELECT
    p.id_producto,
    p.nombre_prdct,
    p.stock_actual,
    p.stock_minimo,
    COALESCE(c.nmbr_categoria, 'Sin categoria') AS categoria
FROM producto AS p
LEFT JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE p.stock_actual <= p.stock_minimo
ORDER BY p.stock_actual ASC;

-- ==========================
-- EXPORTACION A CSV
-- ==========================

-- Revisar la ruta permitida por MariaDB/MySQL antes de exportar
SHOW VARIABLES LIKE 'secure_file_priv';

-- La exportacion queda comentada porque depende de permisos FILE y de secure_file_priv
/*
SELECT
    'id_producto',
    'producto',
    'categoria',
    'cantidad_total_vendida',
    'numero_de_ventas',
    'ingreso_total_generado',
    'precio_promedio',
    'primera_fecha_venta',
    'ultima_fecha_venta'
UNION ALL
SELECT
    CAST(p.id_producto AS CHAR),
    p.nombre_prdct,
    COALESCE(c.nmbr_categoria, 'Sin categoria'),
    CAST(SUM(dv.cantidad) AS CHAR),
    CAST(COUNT(DISTINCT v.id_venta) AS CHAR),
    CAST(SUM(dv.subtotal) AS CHAR),
    CAST(AVG(dv.precio_unitario) AS CHAR),
    CAST(MIN(DATE(v.fch_compra)) AS CHAR),
    CAST(MAX(DATE(v.fch_compra)) AS CHAR)
FROM detalle_venta AS dv
INNER JOIN venta AS v ON v.id_venta = dv.id_venta
INNER JOIN producto AS p ON p.id_producto = dv.id_producto
LEFT JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE v.estado <> 'ANULADA'
GROUP BY p.id_producto, p.nombre_prdct, c.nmbr_categoria
HAVING SUM(dv.cantidad) >= 3
INTO OUTFILE 'C:/xampp/mysql/data/productos_mas_vendidos.csv'
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
*/
