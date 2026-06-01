
INSERT INTO cliente (id_dni, nombres, apellido_p, apellido_m, region, direccion, provincia, distrito, fch_nacimiento, telefono, correo) VALUES
('12345678', 'Pedro Juan', 'Quispe', 'Huaman', 'Lima', 'Av. Los Sauces 123', 'Lima', 'San Juan de Lurigancho', '1980-05-15', '987654321', 'pedro.quispe@gmail.com'),
('87654321', 'Maria Elena', 'Condori', 'Mamani', 'Lima', 'Calle Las Flores 456', 'Lima', 'Comas', '1985-07-22', '987654322', 'maria.condori@gmail.com'),
('45678912', 'Carlos Andres', 'Huaman', 'Rojas', 'Arequipa', 'Av. Independencia 789', 'Arequipa', 'Cerro Colorado', '1990-11-30', '987654323', 'carlos.huaman@gmail.com'),
('78912345', 'Ana Maria', 'Flores', 'Gutierrez', 'La Libertad', 'Calle Progreso 321', 'Trujillo', 'Víctor Larco', '1995-02-18', '987654324', 'ana.flores@hotmail.com'),
('32165487', 'Luis Alberto', 'Torres', 'Mamani', 'Cusco', 'Av. El Sol 654', 'Cusco', 'Wanchaq', '1992-09-05', '987654325', 'luis.torres@yahoo.com');

UPDATE cliente SET telefono = '999888777' WHERE id_dni = '12345678';
UPDATE cliente SET direccion = 'Av. Los Sauces 456' WHERE id_dni = '87654321';
UPDATE cliente SET region = 'Lima' WHERE id_dni = '45678912';
UPDATE cliente SET correo = 'ana.flores.nuevo@gmail.com' WHERE id_dni = '78912345';
UPDATE cliente SET distrito = 'Santiago' WHERE id_dni = '32165487';

INSERT INTO cliente_vip (id_dni, nivel_cliente, tasa_descuento_vip) VALUES
('12345678', 'Oro', 10.00),
('87654321', 'Plata', 7.00),
('45678912', 'Oro', 10.00),
('78912345', 'Bronce', 5.00),
('32165487', 'Plata', 7.00);

UPDATE cliente_vip SET tasa_descuento_vip = 12.00 WHERE id_dni = '12345678';
UPDATE cliente_vip SET nivel_cliente = 'Oro' WHERE id_dni = '87654321';
UPDATE cliente_vip SET tasa_descuento_vip = 8.00 WHERE id_dni = '45678912';
UPDATE cliente_vip SET nivel_cliente = 'Plata' WHERE id_dni = '78912345';
UPDATE cliente_vip SET tasa_descuento_vip = 9.00 WHERE id_dni = '32165487';

INSERT INTO cliente_comun (id_dni, lim_descuento_acumulado, tasa_descuento) VALUES
('12345678', 300.00, 3.00),
('87654321', 200.00, 2.00),
('45678912', 500.00, 5.00),
('78912345', 100.00, 1.00),
('32165487', 400.00, 4.00);

UPDATE cliente_comun SET lim_descuento_acumulado = 350.00 WHERE id_dni = '12345678';
UPDATE cliente_comun SET tasa_descuento = 3.00 WHERE id_dni = '87654321';
UPDATE cliente_comun SET lim_descuento_acumulado = 550.00 WHERE id_dni = '45678912';
UPDATE cliente_comun SET tasa_descuento = 2.00 WHERE id_dni = '78912345';
UPDATE cliente_comun SET lim_descuento_acumulado = 450.00 WHERE id_dni = '32165487';

INSERT INTO empleado (id_dni, nombres, apellido_p, apellido_m, region, provincia, distrito, fch_nacimiento, telefono, correo, sueldo, fch_ingreso) VALUES
('11111111', 'Roberto Carlos', 'Mendoza', 'Perez', 'Lima', 'Lima', 'Miraflores', '1985-03-10', '988888111', 'roberto.mendoza@minimarket.com', 2500.00, '2018-03-01'),
('22222222', 'Patricia', 'Garcia', 'Lopez', 'Lima', 'Lima', 'San Borja', '1988-05-20', '988888222', 'patricia.garcia@minimarket.com', 2200.00, '2019-06-15'),
('33333333', 'Jorge Luis', 'Rojas', 'Torres', 'Arequipa', 'Arequipa', 'Cayma', '1990-08-05', '988888333', 'jorge.rojas@minimarket.com', 2000.00, '2020-02-10'),
('44444444', 'Carmen Rosa', 'Vargas', 'Flores', 'La Libertad', 'Trujillo', 'Trujillo', '1992-11-25', '988888444', 'carmen.vargas@minimarket.com', 2100.00, '2020-09-20'),
('55555555', 'Miguel Angel', 'Castillo', 'Nina', 'Cusco', 'Cusco', 'Cusco', '1995-01-15', '988888555', 'miguel.castillo@minimarket.com', 1900.00, '2021-01-05');

UPDATE empleado SET sueldo = 2800.00 WHERE id_dni = '11111111';
UPDATE empleado SET telefono = '977777222' WHERE id_dni = '22222222';
UPDATE empleado SET region = 'Lima' WHERE id_dni = '33333333';
UPDATE empleado SET sueldo = 2300.00 WHERE id_dni = '44444444';
UPDATE empleado SET fch_ingreso = '2020-01-05' WHERE id_dni = '55555555';

INSERT INTO gerente (id_dni, descripcion) VALUES
('11111111', 'Gerente General del Minimarket'),
('22222222', 'Gerente de Ventas'),
('33333333', 'Gerente de Abastecimiento'),
('44444444', 'Gerente de Marketing'),
('55555555', 'Gerente de Logística');

UPDATE gerente SET descripcion = 'Gerente General y Socio' WHERE id_dni = '11111111';
UPDATE gerente SET descripcion = 'Gerente de Ventas y Atención' WHERE id_dni = '22222222';
UPDATE gerente SET descripcion = 'Gerente de Compras' WHERE id_dni = '33333333';
UPDATE gerente SET descripcion = 'Gerente de Promociones' WHERE id_dni = '44444444';
UPDATE gerente SET descripcion = 'Gerente de Almacén' WHERE id_dni = '55555555';

INSERT INTO empleados_otros (id_dni, cargo, descripcion) VALUES
('11111111', 'Administrador', 'Encargado de la tienda'),
('22222222', 'Vendedor', 'Atención en caja'),
('33333333', 'Reponedor', 'Reposición de productos'),
('44444444', 'Promotor', 'Promociones y ofertas'),
('55555555', 'Almacenero', 'Control de inventario');

UPDATE empleados_otros SET cargo = 'Jefe de Tienda' WHERE id_dni = '11111111';
UPDATE empleados_otros SET descripcion = 'Ventas y cobranzas' WHERE id_dni = '22222222';
UPDATE empleados_otros SET cargo = 'Encargado de Almacén' WHERE id_dni = '33333333';
UPDATE empleados_otros SET descripcion = 'Mercaderista' WHERE id_dni = '44444444';
UPDATE empleados_otros SET cargo = 'Asistente de Almacén' WHERE id_dni = '55555555';

INSERT INTO metodo_pago (metodo) VALUES
('Efectivo'),
('Yape'),
('Plin'),
('Tarjeta Débito'),
('Transferencia');

UPDATE metodo_pago SET metodo = 'Pago en Efectivo' WHERE id_metodo = 1;
UPDATE metodo_pago SET metodo = 'Yape/Depósito' WHERE id_metodo = 2;
UPDATE metodo_pago SET metodo = 'Plin/Binance' WHERE id_metodo = 3;
UPDATE metodo_pago SET metodo = 'Visa Débito' WHERE id_metodo = 4;
UPDATE metodo_pago SET metodo = 'Transferencia BCP' WHERE id_metodo = 5;

INSERT INTO venta (fch_compra, total, id_cliente, id_empleado, id_metodo) VALUES
('2026-05-28', 45.50, '12345678', '22222222', 1),
('2026-05-29', 28.30, '87654321', '22222222', 2),
('2026-05-30', 67.80, '45678912', '44444444', 3),
('2026-05-31', 15.90, '78912345', '22222222', 1),
('2026-06-01', 89.20, '32165487', '33333333', 4);

UPDATE venta SET total = 50.00 WHERE id_venta = 1;
UPDATE venta SET id_metodo = 1 WHERE id_venta = 2;
UPDATE venta SET total = 70.00 WHERE id_venta = 3;
UPDATE venta SET id_empleado = '44444444' WHERE id_venta = 4;
UPDATE venta SET fch_compra = '2026-06-02' WHERE id_venta = 5;

INSERT INTO envio (direcc_entrega, estado, id_venta) VALUES
('Av. Los Sauces 123, SJL', 'Entregado', 1),
('Calle Las Flores 456, Comas', 'En camino', 2),
('Av. Independencia 789, Arequipa', 'Pendiente', 3),
('Calle Progreso 321, Trujillo', 'Entregado', 4),
('Av. El Sol 654, Cusco', 'En reparto', 5);

UPDATE envio SET estado = 'Entregado' WHERE id_envio = 2;
UPDATE envio SET estado = 'Cancelado' WHERE id_envio = 3;
UPDATE envio SET direcc_entrega = 'Calle Progreso 321, Trujillo Centro' WHERE id_envio = 4;
UPDATE envio SET estado = 'Entregado' WHERE id_envio = 5;
UPDATE envio SET estado = 'Preparando' WHERE id_envio = 1;

INSERT INTO devolucion (motivo, fecha, monto_reembolso, id_venta) VALUES
('Producto vencido', '2026-05-30', 15.50, 1),
('Leche en mal estado', '2026-05-31', 12.00, 2),
('Pan duro', '2026-06-01', 8.50, 3),
('Producto golpeado', '2026-06-01', 5.90, 4),
('Sabor alterado', '2026-06-02', 25.00, 5);

UPDATE devolucion SET motivo = 'Producto vencido - fecha expirada' WHERE id_devolucion = 1;
UPDATE devolucion SET monto_reembolso = 13.00 WHERE id_devolucion = 2;
UPDATE devolucion SET fecha = '2026-06-02' WHERE id_devolucion = 3;
UPDATE devolucion SET motivo = 'Envase roto' WHERE id_devolucion = 4;
UPDATE devolucion SET monto_reembolso = 28.00 WHERE id_devolucion = 5;

INSERT INTO categoria (nmbr_categoria) VALUES
('Lácteos'),
('Bebidas'),
('Abarrotes'),
('Limpieza'),
('Panadería');

UPDATE categoria SET nmbr_categoria = 'Lácteos y Derivados' WHERE id_categoria = 1;
UPDATE categoria SET nmbr_categoria = 'Gaseosas y Jugos' WHERE id_categoria = 2;
UPDATE categoria SET nmbr_categoria = 'Conservas y Enlatados' WHERE id_categoria = 3;
UPDATE categoria SET nmbr_categoria = 'Limpieza del Hogar' WHERE id_categoria = 4;
UPDATE categoria SET nmbr_categoria = 'Pan y Pasteles' WHERE id_categoria = 5;

INSERT INTO marca (nombre_marca) VALUES
('Gloria'),
('Coca-Cola'),
('Nestlé'),
('Alicorp'),
('Lavomatic');

UPDATE marca SET nombre_marca = 'Gloria S.A.' WHERE id_marca = 1;
UPDATE marca SET nombre_marca = 'Coca-Cola Company' WHERE id_marca = 2;
UPDATE marca SET nombre_marca = 'Nestlé Perú' WHERE id_marca = 3;
UPDATE marca SET nombre_marca = 'Alicorp S.A.A.' WHERE id_marca = 4;
UPDATE marca SET nombre_marca = 'Lavomatic Perú' WHERE id_marca = 5;

INSERT INTO producto (nombre_prdct, stock_minimo, id_categoria, id_marca) VALUES
('Leche Gloria 1L', 20, 1, 1),
('Inca Kola 3L', 30, 2, 2),
('Galletas Oreo', 25, 3, 3),
('Arroz Costeño 1kg', 15, 3, 4),
('Detergente Ace 500g', 10, 4, 5);

UPDATE producto SET stock_minimo = 25 WHERE id_producto = 1;
UPDATE producto SET stock_minimo = 35 WHERE id_producto = 2;
UPDATE producto SET nombre_prdct = 'Galletas Oreo 12 unidades' WHERE id_producto = 3;
UPDATE producto SET stock_minimo = 20 WHERE id_producto = 4;
UPDATE producto SET stock_minimo = 15 WHERE id_producto = 5;

INSERT INTO promocion (porcentaje, fch_inicio, fch_fin) VALUES
(15.00, '2026-06-01', '2026-06-30'),
(10.00, '2026-06-15', '2026-07-15'),
(20.00, '2026-07-01', '2026-07-31'),
(5.00, '2026-06-10', '2026-06-20'),
(25.00, '2026-08-01', '2026-08-31');

UPDATE promocion SET porcentaje = 12.00 WHERE id_promocion = 1;
UPDATE promocion SET fch_fin = '2026-07-20' WHERE id_promocion = 2;
UPDATE promocion SET porcentaje = 18.00 WHERE id_promocion = 3;
UPDATE promocion SET fch_inicio = '2026-06-12' WHERE id_promocion = 4;
UPDATE promocion SET porcentaje = 30.00 WHERE id_promocion = 5;

INSERT INTO producto_promocion (id_producto, id_promocion) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

UPDATE producto_promocion SET id_promocion = 2 WHERE id_producto = 1;
UPDATE producto_promocion SET id_promocion = 3 WHERE id_producto = 2;
UPDATE producto_promocion SET id_promocion = 1 WHERE id_producto = 3;
UPDATE producto_promocion SET id_promocion = 5 WHERE id_producto = 4;
UPDATE producto_promocion SET id_promocion = 4 WHERE id_producto = 5;

INSERT INTO detalle_venta (cantidad, precio_unitario, subtotal, id_venta, id_producto) VALUES
(2, 4.50, 9.00, 1, 1),
(1, 12.00, 12.00, 1, 2),
(3, 2.50, 7.50, 2, 3),
(1, 5.50, 5.50, 3, 4),
(2, 8.50, 17.00, 4, 5);

UPDATE detalle_venta SET cantidad = 3 WHERE id_detalle = 1;
UPDATE detalle_venta SET precio_unitario = 13.00 WHERE id_detalle = 2;
UPDATE detalle_venta SET subtotal = 10.00 WHERE id_detalle = 3;
UPDATE detalle_venta SET cantidad = 2 WHERE id_detalle = 4;
UPDATE detalle_venta SET precio_unitario = 9.00 WHERE id_detalle = 5;

INSERT INTO almacen (nombre_almacen, tipo) VALUES
('Almacén Central', 'Principal'),
('Almacén Norte', 'Secundario'),
('Almacén Sur', 'Secundario'),
('Almacén Este', 'Secundario'),
('Almacén Oeste', 'Temporal');

UPDATE almacen SET tipo = 'Principal' WHERE id_almacen = 2;
UPDATE almacen SET nombre_almacen = 'Almacén La Molina' WHERE id_almacen = 3;
UPDATE almacen SET tipo = 'Principal' WHERE id_almacen = 4;
UPDATE almacen SET tipo = 'Secundario' WHERE id_almacen = 5;
UPDATE almacen SET nombre_almacen = 'Almacén San Isidro' WHERE id_almacen = 1;

INSERT INTO producto_almacen (id_producto, id_almacen) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 4);

UPDATE producto_almacen SET id_almacen = 2 WHERE id_producto = 1;
UPDATE producto_almacen SET id_almacen = 3 WHERE id_producto = 2;
UPDATE producto_almacen SET id_almacen = 1 WHERE id_producto = 3;
UPDATE producto_almacen SET id_almacen = 5 WHERE id_producto = 4;
UPDATE producto_almacen SET id_almacen = 4 WHERE id_producto = 5;

INSERT INTO inventario (cantidad_actual, id_almacen) VALUES
(150, 1),
(200, 2),
(100, 3),
(80, 4),
(50, 5);

UPDATE inventario SET cantidad_actual = 180 WHERE id_inventario = 1;
UPDATE inventario SET cantidad_actual = 220 WHERE id_inventario = 2;
UPDATE inventario SET cantidad_actual = 120 WHERE id_inventario = 3;
UPDATE inventario SET cantidad_actual = 90 WHERE id_inventario = 4;
UPDATE inventario SET cantidad_actual = 60 WHERE id_inventario = 5;

INSERT INTO proveedor (ruc_dni, contacto) VALUES
('20100123456', 'Distribuidora Gloria'),
('20400123456', 'Coca-Cola Andina Perú'),
('20500123456', 'Nestlé Perú S.A.'),
('20300123456', 'Alicorp S.A.A.'),
('20600123456', 'Procter & Gamble Perú');

UPDATE proveedor SET contacto = 'Gloria Distribuciones' WHERE id_proveedor = 1;
UPDATE proveedor SET ruc_dni = '20400123457' WHERE id_proveedor = 2;
UPDATE proveedor SET contacto = 'Nestlé Alimentos Perú' WHERE id_proveedor = 3;
UPDATE proveedor SET ruc_dni = '20300123457' WHERE id_proveedor = 4;
UPDATE proveedor SET contacto = 'P&G Perú' WHERE id_proveedor = 5;

INSERT INTO producto_proveedor (id_producto, id_proveedor) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

UPDATE producto_proveedor SET id_proveedor = 2 WHERE id_producto = 1;
UPDATE producto_proveedor SET id_proveedor = 3 WHERE id_producto = 2;
UPDATE producto_proveedor SET id_proveedor = 1 WHERE id_producto = 3;
UPDATE producto_proveedor SET id_proveedor = 5 WHERE id_producto = 4;
UPDATE producto_proveedor SET id_proveedor = 4 WHERE id_producto = 5;

INSERT INTO valoracion_del_servicio (puntuacion, comentario, id_cliente) VALUES
(5, 'Muy buena atención, volveré a comprar', '12345678'),
(4, 'Buen servicio, pero falta variedad', '87654321'),
(5, 'Excelente los precios promocionales', '45678912'),
(3, 'Demoraron en atender', '78912345'),
(4, 'Productos frescos y buenos precios', '32165487');

UPDATE valoracion_del_servicio SET puntuacion = 5 WHERE id_resena_servicio = 2;
UPDATE valoracion_del_servicio SET comentario = 'Atención rápida y amable' WHERE id_resena_servicio = 3;
UPDATE valoracion_del_servicio SET puntuacion = 4 WHERE id_resena_servicio = 4;
UPDATE valoracion_del_servicio SET comentario = 'Mejor surtido de productos' WHERE id_resena_servicio = 5;
UPDATE valoracion_del_servicio SET puntuacion = 5 WHERE id_resena_servicio = 1;

INSERT INTO valoracion_resena_de_fabrica (puntuacion, comentario, id_producto) VALUES
(5, 'Leche fresca y de calidad', 1),
(4, 'Sabor tradicional', 2),
(5, 'Crujientes y deliciosas', 3),
(4, 'Arroz grano largo excelente', 4),
(5, 'Limpia muy bien la ropa', 5);

UPDATE valoracion_resena_de_fabrica SET puntuacion = 5 WHERE id_resena = 2;
UPDATE valoracion_resena_de_fabrica SET comentario = 'La mejor galleta del mercado' WHERE id_resena = 3;
UPDATE valoracion_resena_de_fabrica SET puntuacion = 4 WHERE id_resena = 4;
UPDATE valoracion_resena_de_fabrica SET comentario = 'Excelente para ropa blanca' WHERE id_resena = 5;
UPDATE valoracion_resena_de_fabrica SET puntuacion = 5 WHERE id_resena = 1;

-- =====================================================
-- FIN DEL ARCHIVO - DATOS DE MINIMARKET
-- =====================================================
