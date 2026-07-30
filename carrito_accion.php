-- ======================================================================
-- EXTENSION WEB - La Tiendita de Don Pepe
-- Agrega lo necesario para que la base de datos soporte el sitio PHP:
-- autenticacion de clientes, roles, imagenes de producto y descripcion
-- corta para el catalogo. Ejecutar DESPUES de los scripts 01 al 08.
-- ======================================================================

USE tienda_don_pepe;

-- ==========================
-- LOGIN / ROLES PARA CLIENTE
-- ==========================

ALTER TABLE cliente
    ADD COLUMN password_hash VARCHAR(255) NULL AFTER correo,
    ADD COLUMN rol VARCHAR(20) NOT NULL DEFAULT 'cliente' AFTER password_hash,
    ADD COLUMN activo TINYINT(1) NOT NULL DEFAULT 1 AFTER rol,
    ADD COLUMN fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER activo;

ALTER TABLE cliente
    ADD CONSTRAINT chk_cliente_rol CHECK (rol IN ('cliente', 'admin'));

-- ==========================
-- CATALOGO WEB PARA PRODUCTO
-- ==========================

ALTER TABLE producto
    ADD COLUMN descripcion VARCHAR(255) NULL AFTER nombre_prdct,
    ADD COLUMN imagen VARCHAR(150) NULL AFTER atributos;

-- Descripcion corta generada a partir de los atributos JSON existentes.
UPDATE producto
SET descripcion = CONCAT(
    COALESCE(JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.presentacion')), 'Producto'),
    COALESCE(CONCAT(' - ', JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.peso'))), ''),
    COALESCE(CONCAT(' - ', JSON_UNQUOTE(JSON_EXTRACT(atributos, '$.contenido'))), '')
)
WHERE atributos IS NOT NULL;

UPDATE producto SET descripcion = nombre_prdct WHERE descripcion IS NULL;

-- Icono/imagen simbolica por categoria (usada por el catalogo si el
-- producto no tiene imagen propia cargada por el admin).
UPDATE producto p
INNER JOIN categoria c ON c.id_categoria = p.id_categoria
SET p.imagen = CASE c.nmbr_categoria
    WHEN 'Abarrotes' THEN 'abarrotes.svg'
    WHEN 'Lacteos'   THEN 'lacteos.svg'
    WHEN 'Bebidas'   THEN 'bebidas.svg'
    WHEN 'Limpieza'  THEN 'limpieza.svg'
    WHEN 'Higiene'   THEN 'higiene.svg'
    ELSE 'producto.svg'
END
WHERE p.imagen IS NULL;

-- ==========================
-- CUENTAS DE PRUEBA
-- ==========================
-- Contrasena para las 5 cuentas demo: 123456
-- Hash bcrypt generado con password_hash() de PHP.

UPDATE cliente SET password_hash = '$2y$10$7fFeUM7QWP0MMp8pix1ayexA2ZheQNXD73XSdLHy2RTxv/KSOF5q2' WHERE id_dni = '12345678';
UPDATE cliente SET password_hash = '$2y$10$7fFeUM7QWP0MMp8pix1ayexA2ZheQNXD73XSdLHy2RTxv/KSOF5q2' WHERE id_dni = '87654321';
UPDATE cliente SET password_hash = '$2y$10$7fFeUM7QWP0MMp8pix1ayexA2ZheQNXD73XSdLHy2RTxv/KSOF5q2' WHERE id_dni = '45678912';
UPDATE cliente SET password_hash = '$2y$10$7fFeUM7QWP0MMp8pix1ayexA2ZheQNXD73XSdLHy2RTxv/KSOF5q2' WHERE id_dni = '78912345';
UPDATE cliente SET password_hash = '$2y$10$7fFeUM7QWP0MMp8pix1ayexA2ZheQNXD73XSdLHy2RTxv/KSOF5q2' WHERE id_dni = '32165487';

-- Cuenta administradora de la tienda (DNI ficticio, no es empleado real
-- de la tabla empleado; solo se usa para entrar al panel /admin).
INSERT INTO cliente (id_dni, nombres, apellido_p, apellido_m, region, direccion, provincia, distrito, telefono, correo, password_hash, rol)
VALUES ('00000000', 'Administrador', 'Don Pepe', '', 'Arequipa', 'Tienda Principal', 'Arequipa', 'Cercado', '900000000', 'admin@donpepe.pe',
        '$2y$10$7fFeUM7QWP0MMp8pix1ayexA2ZheQNXD73XSdLHy2RTxv/KSOF5q2', 'admin');

INSERT INTO cliente_comun (id_dni, lim_descuento_acumulado, tasa_descuento) VALUES ('00000000', 0.00, 0.00);
