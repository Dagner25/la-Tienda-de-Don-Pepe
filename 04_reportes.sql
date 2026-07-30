USE tienda_don_pepe;

-- ==========================
-- DATOS DE CLIENTES
-- ==========================

-- Clientes principales
INSERT INTO cliente (id_dni, nombres, apellido_p, apellido_m, region, direccion, provincia, distrito, fch_nacimiento, telefono, correo) VALUES
('12345678', 'Pedro Juan', 'Quispe', 'Huaman', 'Lima', 'Av. Los Sauces 123', 'Lima', 'San Juan de Lurigancho', '1980-05-15', '987654321', 'pedro.quispe@gmail.com'),
('87654321', 'Maria Elena', 'Condori', 'Mamani', 'Lima', 'Calle Las Flores 456', 'Lima', 'Comas', '1985-07-22', '987654322', 'maria.condori@gmail.com'),
('45678912', 'Carlos Andres', 'Huaman', 'Rojas', 'Arequipa', 'Av. Independencia 789', 'Arequipa', 'Cerro Colorado', '1990-11-30', '987654323', 'carlos.huaman@gmail.com'),
('78912345', 'Ana Maria', 'Flores', 'Gutierrez', 'La Libertad', 'Calle Progreso 321', 'Trujillo', 'Victor Larco', '1995-02-18', '987654324', 'ana.flores@gmail.com'),
('32165487', 'Luis Alberto', 'Torres', 'Mamani', 'Cusco', 'Av. El Sol 654', 'Cusco', 'Wanchaq', '1992-09-05', '987654325', 'luis.torres@yahoo.com');

-- Clientes VIP y comunes
INSERT INTO cliente_vip (id_dni, nivel_cliente, tasa_descuento_vip) VALUES
('12345678', 'Oro', 12.00),
('87654321', 'Plata', 7.00);

INSERT INTO cliente_comun (id_dni, lim_descuento_acumulado, tasa_descuento) VALUES
('45678912', 500.00, 5.00),
('78912345', 100.00, 1.00),
('32165487', 400.00, 4.00);

-- ==========================
-- DATOS DE EMPLEADOS
-- ==========================

INSERT INTO empleado (id_dni, nombres, apellido_p, apellido_m, region, provincia, distrito, fch_nacimiento, telefono, correo, sueldo, fch_ingreso) VALUES
('11111111', 'Roberto Carlos', 'Mendoza', 'Perez', 'Lima', 'Lima', 'Miraflores', '1985-03-10', '988888111', 'roberto.mendoza@donpepe.pe', 2800.00, '2018-03-01'),
('22222222', 'Patricia', 'Garcia', 'Lopez', 'Lima', 'Lima', 'San Borja', '1988-05-20', '988888222', 'patricia.garcia@donpepe.pe', 2200.00, '2019-06-15'),
('33333333', 'Jorge Luis', 'Rojas', 'Torres', 'Arequipa', 'Arequipa', 'Cayma', '1990-08-05', '988888333', 'jorge.rojas@donpepe.pe', 2000.00, '2020-02-10');

-- Roles internos
INSERT INTO gerente (id_dni, descripcion) VALUES
('11111111', 'Gerente general de La Tienda de Don Pepe');

INSERT INTO empleados_otros (id_dni, cargo, descripcion) VALUES
('22222222', 'Cajera', 'Atencion de ventas y cobranzas'),
('33333333', 'Almacenero', 'Reposicion y control de inventario');

-- ==========================
-- CATALOGOS BASICOS
-- ==========================

INSERT INTO metodo_pago (metodo) VALUES
('Efectivo'), ('Yape'), ('Plin'), ('Tarjeta Debito'), ('Transferencia BCP');

INSERT INTO categoria (nmbr_categoria) VALUES
('Abarrotes'), ('Lacteos'), ('Bebidas'), ('Limpieza'), ('Higiene');

INSERT INTO marca (nombre_marca) VALUES
('Don Pepe'), ('Gloria'), ('Alicorp'), ('San Jorge'), ('Inca Kola'), ('Bolivar'), ('Elite'), ('Florida');

-- ==========================
-- DATOS DE PRODUCTOS
-- ==========================

-- Productos con atributos variables en JSON
INSERT INTO producto (nombre_prdct, precio_venta, stock_actual, stock_minimo, id_categoria, id_marca, atributos) VALUES
('Arroz Extra Don Pepe 5 kg', 21.90, 80, 15, 1, 1, JSON_OBJECT('marca','Don Pepe','presentacion','Bolsa','peso','5 kg','etiquetas',JSON_ARRAY('abarrote','familiar'),'informacion_adicional',JSON_OBJECT('origen','Peru','conservacion','Lugar fresco'))),
('Azucar Rubia Don Pepe 1 kg', 4.20, 120, 20, 1, 1, JSON_OBJECT('marca','Don Pepe','presentacion','Bolsa','peso','1 kg','etiquetas',JSON_ARRAY('abarrote','basico'))),
('Aceite Vegetal Primor 1 L', 9.80, 70, 12, 1, 3, JSON_OBJECT('marca','Primor','presentacion','Botella','contenido','1 L','etiquetas',JSON_ARRAY('cocina'))),
('Fideos Tallarin Don Vittorio 500 g', 4.50, 95, 20, 1, 3, JSON_OBJECT('marca','Don Vittorio','presentacion','Bolsa','peso','500 g')),
('Atun Florida en Trozos 170 g', 6.90, 60, 10, 1, 8, JSON_OBJECT('marca','Florida','presentacion','Lata','peso','170 g')),
('Leche Evaporada Gloria 400 g', 4.80, 100, 18, 2, 2, JSON_OBJECT('marca','Gloria','presentacion','Lata','peso','400 g','etiquetas',JSON_ARRAY('lacteo','desayuno'))),
('Yogurt Gloria Fresa 1 kg', 8.50, 40, 8, 2, 2, JSON_OBJECT('marca','Gloria','presentacion','Botella','sabor','Fresa')),
('Queso Fresco Don Pepe 250 g', 7.90, 25, 6, 2, 1, JSON_OBJECT('marca','Don Pepe','presentacion','Empaque','peso','250 g','requiere_refrigeracion',true)),
('Inca Kola 1.5 L', 7.50, 75, 15, 3, 5, JSON_OBJECT('marca','Inca Kola','presentacion','Botella','contenido','1.5 L')),
('Agua San Luis 625 ml', 2.00, 90, 20, 3, 5, JSON_OBJECT('marca','San Luis','presentacion','Botella','contenido','625 ml')),
('Galletas Soda San Jorge', 3.20, 85, 15, 1, 4, JSON_OBJECT('marca','San Jorge','presentacion','Paquete','etiquetas',JSON_ARRAY('snack','lonchera'))),
('Detergente Bolivar 800 g', 11.90, 35, 8, 4, 6, JSON_OBJECT('marca','Bolivar','presentacion','Bolsa','peso','800 g')),
('Lavavajilla Liquido 750 ml', 8.90, 22, 6, 4, 6, JSON_OBJECT('marca','Bolivar','presentacion','Botella','contenido','750 ml')),
('Papel Higienico Elite x4', 10.50, 30, 10, 5, 7, JSON_OBJECT('marca','Elite','presentacion','Paquete','unidades',4)),
('Jabon de Tocador Don Pepe 90 g', 2.80, 55, 12, 5, 1, JSON_OBJECT('marca','Don Pepe','presentacion','Barra','peso','90 g'));

-- ==========================
-- DATOS DE PROVEEDORES
-- ==========================

INSERT INTO proveedor (ruc_dni, contacto, telefono, correo) VALUES
('20100123456', 'Distribuidora Don Pepe', '914111111', 'ventas@distribuidoradonpepe.pe'),
('20400123456', 'Gloria Distribuciones', '914222222', 'pedidos@gloria.pe'),
('20500123456', 'Alicorp Mayorista', '914333333', 'ventas@alicorp.pe'),
('20600123456', 'Bebidas Lima Sur', '914444444', 'contacto@bebidaslimasur.pe'),
('20700123456', 'Limpieza y Hogar SAC', '914555555', 'ventas@limpiezahogar.pe');

-- Relacion entre productos y proveedores
INSERT INTO producto_proveedor (id_producto, id_proveedor) VALUES
(1,1),(2,1),(8,1),(15,1),(6,2),(7,2),(3,3),(4,3),(5,3),(9,4),(10,4),(12,5),(13,5),(14,5),(11,3);

-- ==========================
-- PROMOCIONES Y ALMACEN
-- ==========================

INSERT INTO promocion (porcentaje, fch_inicio, fch_fin) VALUES
(10.00, '2026-06-01', '2026-07-31'),
(5.00, '2026-07-01', '2026-07-30'),
(15.00, '2026-07-10', '2026-08-10');

INSERT INTO producto_promocion (id_producto, id_promocion) VALUES
(1,1),(6,1),(9,2),(12,3);

INSERT INTO almacen (nombre_almacen, tipo) VALUES
('Almacen Central Don Pepe', 'Principal'),
('Almacen Mostrador', 'Secundario'),
('Almacen Temporal Campana', 'Temporal');

INSERT INTO producto_almacen (id_producto, id_almacen)
SELECT id_producto, CASE WHEN id_producto <= 8 THEN 1 WHEN id_producto <= 13 THEN 2 ELSE 3 END
FROM producto;

INSERT INTO inventario (cantidad_actual, id_almacen) VALUES
(450, 1), (307, 2), (85, 3);

-- ==========================
-- DATOS DE VENTAS
-- ==========================



-- Cabeceras de ventas
INSERT INTO venta (fch_compra, total, estado, id_cliente, id_empleado, id_metodo) VALUES
('2026-06-01 09:15:00', 26.10, 'PAGADA', '12345678', '22222222', 1),
('2026-06-03 10:30:00', 19.20, 'PAGADA', '87654321', '22222222', 2),
('2026-06-05 18:20:00', 37.30, 'PAGADA', '45678912', '33333333', 3),
('2026-06-10 08:50:00', 15.00, 'REGISTRADA', '78912345', '22222222', 1),
('2026-06-15 19:05:00', 31.50, 'PAGADA', '32165487', '11111111', 4),
('2026-06-20 13:40:00', 24.60, 'PAGADA', '12345678', '22222222', 2),
('2026-06-25 17:10:00', 22.40, 'ANULADA', '87654321', '33333333', 5),
('2026-07-02 11:25:00', 42.70, 'PAGADA', '45678912', '22222222', 1),
('2026-07-08 16:45:00', 18.30, 'PAGADA', '78912345', '11111111', 2),
('2026-07-12 12:10:00', 55.20, 'PAGADA', '32165487', '33333333', 3);

-- Detalles asociados a cada venta
INSERT INTO detalle_venta (cantidad, precio_unitario, subtotal, id_venta, id_producto) VALUES
(1,21.90,21.90,1,1),(1,4.20,4.20,1,2),
(4,4.80,19.20,2,6),
(2,9.80,19.60,3,3),(2,6.90,13.80,3,5),(1,3.90,3.90,3,11),
(2,7.50,15.00,4,9),
(3,3.20,9.60,5,11),(2,10.50,21.00,5,14),
(1,11.90,11.90,6,12),(3,4.20,12.60,6,2),
(2,7.50,15.00,7,9),(1,7.40,7.40,7,13),
(1,21.90,21.90,8,1),(2,4.80,9.60,8,6),(2,5.60,11.20,8,15),
(1,8.50,8.50,9,7),(3,2.80,8.40,9,15),(1,1.40,1.40,9,10),
(2,21.90,43.80,10,1),(1,6.90,6.90,10,5),(1,4.50,4.50,10,4);

-- ==========================
-- ENVIOS Y DEVOLUCIONES
-- ==========================

INSERT INTO envio (direcc_entrega, estado, id_venta) VALUES
('Av. Los Sauces 123, San Juan de Lurigancho', 'Entregado', 1),
('Calle Las Flores 456, Comas', 'Entregado', 2),
('Av. Independencia 789, Arequipa', 'En camino', 3),
('Calle Progreso 321, Trujillo', 'Pendiente', 4),
('Av. El Sol 654, Cusco', 'Entregado', 5);




INSERT INTO devolucion (motivo, fecha, monto_reembolso, id_venta) VALUES
('Producto con envase abollado', '2026-06-06', 6.90, 3),
('Pedido anulado por cliente', '2026-06-25', 22.40, 7);

-- ==========================
-- VALORACIONES
-- ==========================

INSERT INTO valoracion_del_servicio (puntuacion, comentario, id_cliente) VALUES
(5, 'Atencion rapida y amable', '12345678'),
(4, 'Buenos precios en abarrotes', '87654321'),
(5, 'Productos frescos', '45678912'),
(3, 'Falta mas variedad de bebidas', '78912345'),
(4, 'Buen control de entregas', '32165487');

INSERT INTO valoracion_resena_de_fabrica (puntuacion, comentario, id_producto) VALUES
(5, 'Arroz de buena calidad', 1),
(4, 'Leche rendidora', 6),
(5, 'Galletas frescas', 11),
(4, 'Detergente efectivo', 12),
(5, 'Jabon economico', 15);
