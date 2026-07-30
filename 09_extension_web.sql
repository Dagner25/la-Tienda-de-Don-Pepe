USE tienda_don_pepe;

-- ==========================
-- ATRIBUTOS SEMIESTRUCTURADOS DEL PRODUCTO
-- ==========================



-- Insercion de informacion JSON
INSERT INTO producto (nombre_prdct, precio_venta, stock_actual, stock_minimo, id_categoria, id_marca, atributos)
SELECT
    'Quinua Perlada Don Pepe 500 g',
    8.70,
    45,
    8,
    1,
    1,
    JSON_OBJECT(
        'marca', 'Don Pepe',
        'presentacion', 'Bolsa',
        'peso', '500 g',
        'etiquetas', JSON_ARRAY('abarrote', 'andino', 'oferta'),
        'informacion_adicional', JSON_OBJECT('origen', 'Peru', 'conservacion', 'Lugar fresco')
    )
WHERE NOT EXISTS (
    SELECT 1
    FROM producto
    WHERE nombre_prdct = 'Quinua Perlada Don Pepe 500 g'
);

SET @id_producto_json = (
    SELECT id_producto
    FROM producto
    WHERE nombre_prdct = 'Quinua Perlada Don Pepe 500 g'
    LIMIT 1
);




-- Actualizacion de propiedades
UPDATE producto
SET atributos = JSON_SET(atributos, '$.informacion_adicional.conservacion', 'Mantener cerrado en lugar seco')
WHERE id_producto = @id_producto_json;

-- Consulta del JSON completo
SELECT id_producto, nombre_prdct, atributos
FROM producto
WHERE id_producto = @id_producto_json;

-- Consulta de propiedades
SELECT
    id_producto,
    nombre_prdct,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.marca')) AS marca_json
FROM producto
WHERE id_producto = @id_producto_json;

-- Filtro por marca
SELECT id_producto, nombre_prdct
FROM producto
WHERE JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.marca')) = 'Don Pepe';

-- Agregar y eliminar propiedades
UPDATE producto
SET atributos = JSON_SET(atributos, '$.apto_para', JSON_ARRAY('desayuno', 'lonchera'))
WHERE id_producto = @id_producto_json;

UPDATE producto
SET atributos = JSON_REMOVE(atributos, '$.peso')
WHERE id_producto = @id_producto_json;

-- Consulta de arreglo JSON






SELECT
    nombre_prdct,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.etiquetas[0]')) AS primera_etiqueta,
    JSON_EXTRACT(atributos, '$.etiquetas') AS etiquetas,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.presentacion')) AS presentacion
FROM producto
WHERE id_producto = @id_producto_json;

-- Validacion de JSON
SELECT
    id_producto,
    nombre_prdct,
    JSON_VALID(atributos) AS json_valido
FROM producto
WHERE atributos IS NOT NULL;




-- ==========================
-- VISTA DE CONSULTA JSON
-- ==========================

DROP VIEW IF EXISTS vw_productos_atributos_json;

CREATE VIEW vw_productos_atributos_json AS
SELECT
    id_producto,
    nombre_prdct,
    precio_venta,
    stock_actual,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.marca')) AS marca_json,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.presentacion')) AS presentacion_json,
    JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.informacion_adicional.origen')) AS origen_json
FROM producto
WHERE atributos IS NOT NULL;

SELECT *
FROM vw_productos_atributos_json
WHERE marca_json = 'Don Pepe';
