USE tienda_don_pepe;

-- ==========================
-- VISTA DE VENTA COMPLETA
-- ==========================

DROP VIEW IF EXISTS vw_ventas_detalladas;

CREATE VIEW vw_ventas_detalladas AS
SELECT
    v.id_venta,
    v.fch_compra AS fecha,
    CONCAT(c.nombres, ' ', c.apellido_p) AS cliente,
    COALESCE(CONCAT(e.nombres, ' ', e.apellido_p), 'Empleado eliminado') AS empleado,
    p.nombre_prdct AS producto,
    COALESCE(cat.nmbr_categoria, 'Sin categoria') AS categoria,
    dv.cantidad,
    dv.precio_unitario,
    dv.subtotal,
    v.total,
    v.estado
FROM venta AS v
INNER JOIN cliente AS c ON c.id_dni = v.id_cliente
LEFT JOIN empleado AS e ON e.id_dni = v.id_empleado
INNER JOIN detalle_venta AS dv ON dv.id_venta = v.id_venta
INNER JOIN producto AS p ON p.id_producto = dv.id_producto
LEFT JOIN categoria AS cat ON cat.id_categoria = p.id_categoria;

DELIMITER $$

-- ==========================
-- REGISTRO DE VENTA
-- ==========================

DROP PROCEDURE IF EXISTS sp_registrar_venta$$

CREATE PROCEDURE sp_registrar_venta(
    IN p_id_cliente CHAR(8),
    IN p_id_empleado CHAR(8),
    IN p_id_metodo INT,
    IN p_detalles LONGTEXT
)
BEGIN
    DECLARE v_id_venta INT DEFAULT 0;
    DECLARE v_total DECIMAL(12,2) DEFAULT 0.00;
    DECLARE v_indice INT DEFAULT 0;
    DECLARE v_numero_detalles INT DEFAULT 0;
    DECLARE v_id_producto INT DEFAULT 0;
    DECLARE v_cantidad INT DEFAULT 0;
    DECLARE v_precio DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_existe INT DEFAULT 0;

    -- Reversion ante cualquier error del proceso.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validacion del arreglo JSON recibido.
    IF p_detalles IS NULL OR TRIM(p_detalles) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe enviar los detalles de la venta.';
    END IF;

    IF JSON_VALID(p_detalles) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los detalles de la venta no contienen un JSON valido.';
    END IF;

    IF LEFT(TRIM(p_detalles), 1) <> '[' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los detalles deben enviarse como un arreglo JSON.';
    END IF;

    SET v_numero_detalles = JSON_LENGTH(p_detalles);

    IF v_numero_detalles IS NULL OR v_numero_detalles <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La venta debe contener al menos un producto.';
    END IF;

    START TRANSACTION;

    -- Validacion de cliente.
    SELECT COUNT(*) INTO v_existe
    FROM cliente
    WHERE id_dni = p_id_cliente;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente indicado no existe.';
    END IF;

    -- Validacion de empleado.
    IF p_id_empleado IS NOT NULL AND TRIM(p_id_empleado) <> '' THEN
        SELECT COUNT(*) INTO v_existe
        FROM empleado
        WHERE id_dni = p_id_empleado
          AND activo = 1;

        IF v_existe = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El empleado no existe o no se encuentra activo.';
        END IF;
    END IF;

    -- Validacion de metodo de pago.
    SELECT COUNT(*) INTO v_existe
    FROM metodo_pago
    WHERE id_metodo = p_id_metodo;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El metodo de pago indicado no existe.';
    END IF;

    -- Registro de cabecera.
    INSERT INTO venta (fch_compra, total, estado, id_cliente, id_empleado, id_metodo)
    VALUES (NOW(), 0.00, 'REGISTRADA', p_id_cliente, NULLIF(TRIM(p_id_empleado), ''), p_id_metodo);

    SET v_id_venta = LAST_INSERT_ID();

    -- Insercion de detalles y descuento de inventario.
    WHILE v_indice < v_numero_detalles DO
        SET v_id_producto = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_detalles, CONCAT('$[', v_indice, '].id_producto'))) AS UNSIGNED);
        SET v_cantidad = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_detalles, CONCAT('$[', v_indice, '].cantidad'))) AS UNSIGNED);

        IF v_id_producto IS NULL OR v_id_producto <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uno de los detalles no contiene un producto valido.';
        END IF;

        IF v_cantidad IS NULL OR v_cantidad <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cantidad de cada producto debe ser mayor que cero.';
        END IF;

        SELECT COUNT(*) INTO v_existe
        FROM producto
        WHERE id_producto = v_id_producto;

        IF v_existe = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uno de los productos indicados no existe.';
        END IF;

        -- Validacion de stock con bloqueo.
        SELECT precio_venta, stock_actual
        INTO v_precio, v_stock
        FROM producto
        WHERE id_producto = v_id_producto
        FOR UPDATE;

        IF v_precio IS NULL OR v_precio <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El producto no tiene un precio de venta valido.';
        END IF;

        IF v_stock < v_cantidad THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock insuficiente para registrar la venta.';
        END IF;

        INSERT INTO detalle_venta (cantidad, precio_unitario, subtotal, id_venta, id_producto)
        VALUES (v_cantidad, v_precio, ROUND(v_cantidad * v_precio, 2), v_id_venta, v_id_producto);

        UPDATE producto
        SET stock_actual = stock_actual - v_cantidad
        WHERE id_producto = v_id_producto;

        SET v_total = v_total + ROUND(v_cantidad * v_precio, 2);
        SET v_indice = v_indice + 1;
    END WHILE;

    -- Actualizacion del total y confirmacion.
    UPDATE venta
    SET total = ROUND(v_total, 2)
    WHERE id_venta = v_id_venta;

    COMMIT;

    SELECT v_id_venta AS id_venta_registrada, ROUND(v_total, 2) AS total_registrado;
END$$

-- ==========================
-- ACTUALIZACION DE DETALLE
-- ==========================

DROP PROCEDURE IF EXISTS sp_actualizar_detalle_venta$$

CREATE PROCEDURE sp_actualizar_detalle_venta(
    IN p_id_detalle INT,
    IN p_nueva_cantidad INT
)
BEGIN
    DECLARE v_id_venta INT DEFAULT 0;
    DECLARE v_id_producto INT DEFAULT 0;
    DECLARE v_cantidad_anterior INT DEFAULT 0;
    DECLARE v_precio_actual DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_stock_actual INT DEFAULT 0;
    DECLARE v_stock_disponible INT DEFAULT 0;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_existe INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validacion inicial.
    IF p_id_detalle IS NULL OR p_id_detalle <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe indicar un detalle de venta valido.';
    END IF;

    IF p_nueva_cantidad IS NULL OR p_nueva_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La nueva cantidad debe ser mayor que cero.';
    END IF;

    START TRANSACTION;

    -- Recuperacion del detalle y estado de la venta.
    SELECT COUNT(*) INTO v_existe
    FROM detalle_venta
    WHERE id_detalle = p_id_detalle;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El detalle de venta indicado no existe.';
    END IF;

    SELECT dv.id_venta, dv.id_producto, dv.cantidad, v.estado
    INTO v_id_venta, v_id_producto, v_cantidad_anterior, v_estado
    FROM detalle_venta AS dv
    INNER JOIN venta AS v ON v.id_venta = dv.id_venta
    WHERE dv.id_detalle = p_id_detalle
    FOR UPDATE;

    IF v_estado = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede actualizar una venta anulada.';
    END IF;




    -- Reposicion temporal y nueva validacion de stock.
    SELECT precio_venta, stock_actual
    INTO v_precio_actual, v_stock_actual
    FROM producto
    WHERE id_producto = v_id_producto
    FOR UPDATE;

    SET v_stock_disponible = v_stock_actual + v_cantidad_anterior;

    IF v_stock_disponible < p_nueva_cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para actualizar el detalle.';
    END IF;

    -- Actualizacion vinculada.
    UPDATE producto
    SET stock_actual = stock_actual + v_cantidad_anterior - p_nueva_cantidad
    WHERE id_producto = v_id_producto;

    UPDATE detalle_venta
    SET cantidad = p_nueva_cantidad,
        precio_unitario = v_precio_actual,
        subtotal = ROUND(p_nueva_cantidad * v_precio_actual, 2)
    WHERE id_detalle = p_id_detalle;

    UPDATE venta
    SET total = (
        SELECT COALESCE(ROUND(SUM(dv2.subtotal), 2), 0.00)
        FROM detalle_venta AS dv2
        WHERE dv2.id_venta = v_id_venta
    )
    WHERE id_venta = v_id_venta;

    COMMIT;

    SELECT v_id_venta AS id_venta_actualizada, p_id_detalle AS id_detalle_actualizado, p_nueva_cantidad AS nueva_cantidad;
END$$

-- ==========================
-- ANULACION DE VENTA
-- ==========================



DROP PROCEDURE IF EXISTS sp_anular_venta$$

CREATE PROCEDURE sp_anular_venta(IN p_id_venta INT)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_id_producto INT DEFAULT 0;
    DECLARE v_cantidad INT DEFAULT 0;
    DECLARE v_fin INT DEFAULT 0;
    DECLARE v_existe INT DEFAULT 0;

    -- Detalles usados para devolver stock.
    DECLARE cur_detalles CURSOR FOR
        SELECT id_producto, cantidad
        FROM detalle_venta
        WHERE id_venta = p_id_venta;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_id_venta IS NULL OR p_id_venta <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe indicar una venta valida.';
    END IF;

    START TRANSACTION;

    -- Validacion de venta.
    SELECT COUNT(*) INTO v_existe
    FROM venta
    WHERE id_venta = p_id_venta;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La venta indicada no existe.';
    END IF;

    SELECT estado INTO v_estado
    FROM venta
    WHERE id_venta = p_id_venta
    FOR UPDATE;

    IF v_estado = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La venta ya fue anulada anteriormente.';
    END IF;

    -- Devolucion de stock.
    OPEN cur_detalles;

    leer_detalles: LOOP
        FETCH cur_detalles INTO v_id_producto, v_cantidad;

        IF v_fin = 1 THEN
            LEAVE leer_detalles;
        END IF;

        UPDATE producto
        SET stock_actual = stock_actual + v_cantidad
        WHERE id_producto = v_id_producto;
    END LOOP;

    CLOSE cur_detalles;

    -- Conserva el historial y cambia solo el estado.
    UPDATE venta
    SET estado = 'ANULADA'
    WHERE id_venta = p_id_venta;

    COMMIT;

    SELECT p_id_venta AS id_venta_anulada, 'ANULADA' AS nuevo_estado;
END$$

DELIMITER ;

-- ==========================
-- CRUD BASICO
-- ==========================

-- INSERT de categorea de prueba
INSERT INTO categoria (nmbr_categoria)
SELECT 'Mascotas'
WHERE NOT EXISTS (
    SELECT 1
    FROM categoria
    WHERE nmbr_categoria = 'Mascotas'
);

SET @id_categoria_mascotas = (
    SELECT id_categoria
    FROM categoria
    WHERE nmbr_categoria = 'Mascotas'
    LIMIT 1
);

SET @id_marca_demo = (
    SELECT MIN(id_marca)
    FROM marca
);

-- INSERT de producto de prueba
INSERT INTO producto (nombre_prdct, precio_venta, stock_actual, stock_minimo, id_categoria, id_marca, atributos)
SELECT
    'Arena Sanitaria Demo 2 kg',
    12.50,
    10,
    3,
    @id_categoria_mascotas,
    @id_marca_demo,
    JSON_OBJECT('marca', 'Don Pepe', 'uso', 'demo', 'presentacion', 'Bolsa de 2 kg')
WHERE @id_categoria_mascotas IS NOT NULL
  AND @id_marca_demo IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM producto
      WHERE nombre_prdct = 'Arena Sanitaria Demo 2 kg'
  );

-- SELECT y UPDATE del producto de prueba
SELECT id_producto, nombre_prdct, precio_venta, stock_actual, atributos
FROM producto
WHERE nombre_prdct = 'Arena Sanitaria Demo 2 kg';

UPDATE producto
SET precio_venta = 13.00,
    stock_actual = stock_actual + 5
WHERE nombre_prdct = 'Arena Sanitaria Demo 2 kg';

SELECT id_producto, nombre_prdct, precio_venta, stock_actual
FROM producto
WHERE nombre_prdct = 'Arena Sanitaria Demo 2 kg';

-- DELETE dee datos de prueba
DELETE FROM producto
WHERE nombre_prdct = 'Arena Sanitaria Demo 2 kg';

DELETE FROM categoria
WHERE nmbr_categoria = 'Mascotas'
  AND NOT EXISTS (
      SELECT 1
      FROM producto
      WHERE producto.id_categoria = categoria.id_categoria
  );
