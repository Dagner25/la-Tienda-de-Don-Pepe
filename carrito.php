USE tienda_don_pepe;

-- ==========================
-- PRUEBA DE INTEGRIDAD
-- ==========================

-- CHECK: precio_venta debe ser mayor que cero.
-- Debe fallar si se descomenta.
-- INSERT INTO producto (nombre_prdct, precio_venta, stock_actual, stock_minimo)
-- VALUES ('Producto invalido', 0, 1, 1);

-- UNIQUE: el correo del cliente no puede repetirse.
-- Debe fallar si se descomenta.
-- INSERT INTO cliente (id_dni, nombres, apellido_p, region, direccion, provincia, distrito, telefono, correo)
-- VALUES ('11223344', 'Cliente', 'Duplicado', 'Lima', 'Direccion', 'Lima', 'Comas', '900000001', 'pedro.quispe@gmail.com');

-- NOT NULL: nombres es obligatorio.
-- Debe fallar si se descomenta.
-- INSERT INTO cliente (id_dni, apellido_p, region, direccion, provincia, distrito, telefono, correo)
-- VALUES ('11223345', 'SinNombre', 'Lima', 'Direccion', 'Lima', 'Comas', '900000002', 'sin.nombre@demo.pe');

-- Integridad referencial: la venta debe apuntar a un cliente existente.
-- Debe fallar si se descomenta.
-- INSERT INTO venta (id_cliente, id_empleado, id_metodo)
-- VALUES ('00000000', '22222222', 1);

-- ==========================
-- PRUEBA DE CASCADE
-- ==========================

-- Se crea una venta de prueba y luego se elimina la cabecera
CALL sp_registrar_venta(
    '45678912',
    '22222222',
    1,
    JSON_ARRAY(
        JSON_OBJECT('id_producto', 3, 'cantidad', 1),
        JSON_OBJECT('id_producto', 4, 'cantidad', 1)
    )
);

SET @venta_cascade = (
    SELECT MAX(id_venta)
    FROM venta
    WHERE id_cliente = '45678912'
      AND estado = 'REGISTRADA'
);





SELECT COUNT(*) AS detalles_antes_cascade
FROM detalle_venta
WHERE id_venta = @venta_cascade;

DELETE FROM venta
WHERE id_venta = @venta_cascade;

SELECT COUNT(*) AS detalles_despues_cascade
FROM detalle_venta
WHERE id_venta = @venta_cascade;

-- ==========================
-- PRUEBA DE SET NULL
-- ==========================

-- La venta conserva historial aunque se elimine el empleado
DELETE FROM empleado
WHERE id_dni = '99990000';

INSERT INTO empleado (id_dni, nombres, apellido_p, region, provincia, distrito, telefono, correo, sueldo, fch_ingreso)
VALUES ('99990000', 'Empleado', 'Temporal', 'Lima', 'Lima', 'Surco', '999900000', 'temporal@donpepe.pe', 1200.00, '2026-07-01');

CALL sp_registrar_venta(
    '78912345',
    '99990000',
    1,
    JSON_ARRAY(JSON_OBJECT('id_producto', 10, 'cantidad', 1))
);

SET @venta_set_null = (
    SELECT MAX(id_venta)
    FROM venta
    WHERE id_cliente = '78912345'
      AND id_empleado = '99990000'
);

DELETE FROM empleado
WHERE id_dni = '99990000';

SELECT id_venta, id_empleado
FROM venta
WHERE id_venta = @venta_set_null;

-- ==========================
-- PRUEBA DE CRUD COMPLEJO
-- ==========================

-- Registro correcto de una venta
CALL sp_registrar_venta(
    '12345678',
    '22222222',
    2,
    JSON_ARRAY(
        JSON_OBJECT('id_producto', 1, 'cantidad', 1),
        JSON_OBJECT('id_producto', 6, 'cantidad', 2)
    )
);

SET @venta_prueba = (
    SELECT MAX(id_venta)
    FROM venta
    WHERE id_cliente = '12345678'
      AND estado = 'REGISTRADA'
);

SELECT *
FROM venta
WHERE id_venta = @venta_prueba;

SELECT *
FROM detalle_venta
WHERE id_venta = @venta_prueba;

-- Actualizacion vinculada
SET @detalle_prueba = (
    SELECT MIN(id_detalle)
    FROM detalle_venta
    WHERE id_venta = @venta_prueba
);

CALL sp_actualizar_detalle_venta(@detalle_prueba, 3);

SELECT *
FROM venta
WHERE id_venta = @venta_prueba;

SELECT *
FROM detalle_venta
WHERE id_detalle = @detalle_prueba;

-- Anulacion de la venta
CALL sp_anular_venta(@venta_prueba);

SELECT id_venta, estado, total
FROM venta
WHERE id_venta = @venta_prueba;

-- ==========================
-- PRUEBA DE TRANSACCIONES
-- ==========================

-- COMMIT correcto.
CALL sp_prueba_commit_venta();

-- ROLLVACK por stock insuficiente
CALL sp_prueba_rollback_stock();

-- ==========================
-- PRUEBA DE REPORTES
-- ==========================

-- GROUP BY y HAVING
CALL sp_reporte_productos_mas_vendidos('2026-06-01', '2026-07-31', 3);

-- ==========================
-- PRUEBA DE EXPORTACION
-- ==========================

-- Revisar permisos y ruta antes de ejecutar INTO OUTFILE
SHOW VARIABLES LIKE 'secure_file_priv';
-- Ejecutar la sentencia INTO OUTFILE que esta en el archivo de  04_reportes.sql 

-- ==========================
-- PRUEBA DE EXPLAIN
-- ==========================

EXPLAIN
SELECT id_venta, fch_compra, total, estado
FROM venta
WHERE estado = 'PAGADA'
  AND fch_compra BETWEEN '2026-06-01' AND '2026-07-31';

-- ==========================
-- PRUEBA DE JSON
-- ==========================

-- Insercion de JSON.
INSERT INTO producto (nombre_prdct, precio_venta, stock_actual, stock_minimo, id_categoria, id_marca, atributos)
SELECT
    'Mermelada Don Pepe Fresa 320 g',
    7.40,
    28,
    5,
    1,
    1,
    JSON_OBJECT(
        'marca', 'Don Pepe',
        'sabor', 'Fresa',
        'etiquetas', JSON_ARRAY('desayuno', 'dulce')
    )
WHERE NOT EXISTS (
    SELECT 1
    FROM producto
    WHERE nombre_prdct = 'Mermelada Don Pepe Fresa 320 g'
);

SET @producto_json_prueba = (
    SELECT id_producto
    FROM producto
    WHERE nombre_prdct = 'Mermelada Don Pepe Fresa 320 g'
    LIMIT 1
);

-- ConsultaR de JSON
SELECT id_producto, nombre_prdct, atributos
FROM producto
WHERE id_producto = @producto_json_prueba;

-- Actualizacion de JSON
UPDATE producto
SET atributos = JSON_SET(atributos, '$.presentacion', 'Frasco')
WHERE id_producto = @producto_json_prueba;

-- Filtro  mediante la propiedad JSON
SELECT
    id_producto,
    nombre_prdct,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.marca')) AS marca_json
FROM producto
WHERE JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.marca')) = 'Don Pepe';

-- Validacion de del contenido JSON
SELECT
    id_producto,
    nombre_prdct,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.presentacion')) AS presentacion_json,
    JSON_VALID(atributos) AS json_valido
FROM producto
WHERE id_producto = @producto_json_prueba;
