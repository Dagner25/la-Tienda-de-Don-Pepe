USE tienda_don_pepe;

DELIMITER $$

-- ==========================
-- PRUEBA DE COMMIT
-- ==========================

DROP PROCEDURE IF EXISTS sp_prueba_commit_venta$$

CREATE PROCEDURE sp_prueba_commit_venta()
BEGIN
    DECLARE v_id_producto INT;
    DECLARE v_id_cliente CHAR(8);
    DECLARE v_id_empleado CHAR(8);
    DECLARE v_id_metodo INT;
    DECLARE v_stock_antes INT;
    DECLARE v_stock_despues INT;
    DECLARE v_ventas_antes INT;
    DECLARE v_ventas_despues INT;

    -- Datos disponibles para una venta correcta
    SELECT id_producto INTO v_id_producto
    FROM producto
    WHERE stock_actual >= 2
      AND precio_venta > 0
    ORDER BY id_producto
    LIMIT 1;

    SELECT id_dni INTO v_id_cliente
    FROM cliente
    ORDER BY id_dni
    LIMIT 1;

    SELECT id_dni INTO v_id_empleado
    FROM empleado
    WHERE activo = 1
    ORDER BY id_dni
    LIMIT 1;

    SELECT id_metodo INTO v_id_metodo
    FROM metodo_pago
    ORDER BY id_metodo
    LIMIT 1;

    IF v_id_producto IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe un producto con stock suficiente para la prueba.';
    END IF;

    IF v_id_cliente IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existen clientes para realizar la prueba.';
    END IF;

    IF v_id_metodo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existen metodos de pago para realizar la prueba.';
    END IF;

    -- Registro valido que debe confirmar la transaccion
    SELECT stock_actual INTO v_stock_antes
    FROM producto
    WHERE id_producto = v_id_producto;

    SELECT COUNT(*) INTO v_ventas_antes
    FROM venta;

    CALL sp_registrar_venta(
        v_id_cliente,
        v_id_empleado,
        v_id_metodo,
        JSON_ARRAY(JSON_OBJECT('id_producto', v_id_producto, 'cantidad', 2))
    );

    SELECT stock_actual INTO v_stock_despues
    FROM producto
    WHERE id_producto = v_id_producto;

    SELECT COUNT(*) INTO v_ventas_despues
    FROM venta;

    SELECT
        'COMMIT CORRECTO' AS resultado,
        v_id_producto AS id_producto,
        v_stock_antes AS stock_antes,
        v_stock_despues AS stock_despues,
        v_stock_antes - v_stock_despues AS unidades_descontadas,
        v_ventas_antes AS ventas_antes,
        v_ventas_despues AS ventas_despues;
END$$

-- ==========================
-- PRUEBA DE ROLLBACK
-- ==========================

DROP PROCEDURE IF EXISTS sp_prueba_rollback_stock$$

CREATE PROCEDURE sp_prueba_rollback_stock()
BEGIN
    DECLARE v_id_producto INT;
    DECLARE v_id_cliente CHAR(8);
    DECLARE v_id_empleado CHAR(8);
    DECLARE v_id_metodo INT;
    DECLARE v_stock_antes INT;
    DECLARE v_stock_despues INT;
    DECLARE v_ventas_antes INT;
    DECLARE v_ventas_despues INT;
    DECLARE v_error VARCHAR(500) DEFAULT 'No se produjo error';

    -- Compatible con MariaDB/XAMPP: usa un mensaje fijo en el manejador
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error = 'Error esperado: stock insuficiente o validacion de venta.';
    END;

    -- Datos disponibles para forzar un error de stock
    SELECT id_producto INTO v_id_producto
    FROM producto
    WHERE stock_actual >= 0
      AND precio_venta > 0
    ORDER BY id_producto
    LIMIT 1;

    SELECT id_dni INTO v_id_cliente
    FROM cliente
    ORDER BY id_dni
    LIMIT 1;

    SELECT id_dni INTO v_id_empleado
    FROM empleado
    WHERE activo = 1
    ORDER BY id_dni
    LIMIT 1;

    SELECT id_metodo INTO v_id_metodo
    FROM metodo_pago
    ORDER BY id_metodo
    LIMIT 1;

    IF v_id_producto IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existen productos para realizar la prueba.';
    END IF;

    IF v_id_cliente IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existen clientes para realizar la prueba.';
    END IF;

    IF v_id_metodo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existen metodos de pago para realizar la prueba.';
    END IF;

    SELECT stock_actual INTO v_stock_antes
    FROM producto
    WHERE id_producto = v_id_producto;

    SELECT COUNT(*) INTO v_ventas_antes
    FROM venta;

    -- Cantidad superior al stock para provocar ROLLBACK.
    CALL sp_registrar_venta(
        v_id_cliente,
        v_id_empleado,
        v_id_metodo,
        JSON_ARRAY(JSON_OBJECT('id_producto', v_id_producto, 'cantidad', v_stock_antes + 9999))
    );

    SELECT stock_actual INTO v_stock_despues
    FROM producto
    WHERE id_producto = v_id_producto;

    SELECT COUNT(*) INTO v_ventas_despues
    FROM venta;

    SELECT
        'ROLLBACK COMPROBADO' AS resultado,
        v_error AS error_capturado,
        v_id_producto AS id_producto,
        v_stock_antes AS stock_antes,
        v_stock_despues AS stock_despues,
        v_ventas_antes AS ventas_antes,
        v_ventas_despues AS ventas_despues,
        CASE
            WHEN v_stock_antes = v_stock_despues
             AND v_ventas_antes = v_ventas_despues
            THEN 'La base de datos no sufrio cambios'
            ELSE 'Revisar: se detectaron cambios'
        END AS comprobacion;
END$$

DELIMITER ;
