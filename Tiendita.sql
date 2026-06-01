-- ==========================
-- TABLA CLIENTE
-- ==========================
CREATE TABLE cliente (
    id_dni VARCHAR(8) PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellido_p VARCHAR(50) NOT NULL,
    apellido_m VARCHAR(50),
    region VARCHAR(50),
    direccion VARCHAR(200),
    provincia VARCHAR(50),
    distrito VARCHAR(50),
    fch_nacimiento DATE,
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

-- CLIENTE VIP
CREATE TABLE cliente_vip (
    id_dni VARCHAR(8) PRIMARY KEY,
    nivel_cliente VARCHAR(20),
    tasa_descuento_vip DECIMAL(5,2),
    FOREIGN KEY (id_dni) REFERENCES cliente(id_dni)
);

-- CLIENTE COMUN
CREATE TABLE cliente_comun (
    id_dni VARCHAR(8) PRIMARY KEY,
    lim_descuento_acumulado DECIMAL(10,2),
    tasa_descuento DECIMAL(5,2),
    FOREIGN KEY (id_dni) REFERENCES cliente(id_dni)
);

-- ==========================
-- EMPLEADO
-- ==========================
CREATE TABLE empleado (
    id_dni VARCHAR(8) PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellido_p VARCHAR(50),
    apellido_m VARCHAR(50),
    region VARCHAR(50),
    provincia VARCHAR(50),
    distrito VARCHAR(50),
    fch_nacimiento DATE,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    sueldo NUMERIC(10,2),
    fch_ingreso DATE
);

-- GERENTE
CREATE TABLE gerente (
    id_dni VARCHAR(8) PRIMARY KEY,
    descripcion VARCHAR(200),
    FOREIGN KEY (id_dni) REFERENCES empleado(id_dni)
);

-- EMPLEADOS OTROS
CREATE TABLE empleados_otros (
    id_dni VARCHAR(8) PRIMARY KEY,
    cargo VARCHAR(50),
    descripcion VARCHAR(200),
    FOREIGN KEY (id_dni) REFERENCES empleado(id_dni)
);

-- ==========================
-- METODO DE PAGO
-- ==========================
CREATE TABLE metodo_pago (
    id_metodo SERIAL PRIMARY KEY,
    metodo VARCHAR(50) NOT NULL
);

-- ==========================
-- VENTA
-- ==========================
CREATE TABLE venta (
    id_venta SERIAL PRIMARY KEY,
    fch_compra DATE NOT NULL,
    total NUMERIC(12,2),
    id_cliente VARCHAR(8),
    id_empleado VARCHAR(8),
    id_metodo INTEGER,
    
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_dni),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_dni),
    FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo)
);

-- ==========================
-- ENVIO
-- ==========================
CREATE TABLE envio (
    id_envio SERIAL PRIMARY KEY,
    direcc_entrega VARCHAR(200),
    estado VARCHAR(50),
    id_venta INTEGER UNIQUE,
    
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta)
);

-- ==========================
-- DEVOLUCION
-- ==========================
CREATE TABLE devolucion (
    id_devolucion SERIAL PRIMARY KEY,
    motivo VARCHAR(200),
    fecha DATE,
    monto_reembolso NUMERIC(10,2),
    id_venta INTEGER,
    
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta)
);

-- ==========================
-- CATEGORIA
-- ==========================
CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nmbr_categoria VARCHAR(100) NOT NULL
);

-- ==========================
-- MARCA
-- ==========================
CREATE TABLE marca (
    id_marca SERIAL PRIMARY KEY,
    nombre_marca VARCHAR(100) NOT NULL
);

-- ==========================
-- PRODUCTO
-- ==========================
CREATE TABLE producto (
    id_producto SERIAL PRIMARY KEY,
    nombre_prdct VARCHAR(100) NOT NULL,
    stock_minimo INTEGER,
    id_categoria INTEGER,
    id_marca INTEGER,

    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
);

-- ==========================
-- PROMOCION
-- ==========================
CREATE TABLE promocion (
    id_promocion SERIAL PRIMARY KEY,
    porcentaje DECIMAL(5,2),
    fch_inicio DATE,
    fch_fin DATE
);

-- RELACION PRODUCTO - PROMOCION
CREATE TABLE producto_promocion (
    id_producto INTEGER,
    id_promocion INTEGER,
    
    PRIMARY KEY(id_producto, id_promocion),
    
    FOREIGN KEY(id_producto) REFERENCES producto(id_producto),
    FOREIGN KEY(id_promocion) REFERENCES promocion(id_promocion)
);

-- ==========================
-- DETALLE VENTA
-- ==========================
CREATE TABLE detalle_venta (
    id_detalle SERIAL PRIMARY KEY,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(10,2),
    subtotal NUMERIC(10,2),

    id_venta INTEGER,
    id_producto INTEGER,

    FOREIGN KEY (id_venta) REFERENCES venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- ==========================
-- ALMACEN
-- ==========================
CREATE TABLE almacen (
    id_almacen SERIAL PRIMARY KEY,
    nombre_almacen VARCHAR(100),
    tipo VARCHAR(50)
);

-- RELACION PRODUCTO - ALMACEN
CREATE TABLE producto_almacen (
    id_producto INTEGER,
    id_almacen INTEGER,

    PRIMARY KEY(id_producto, id_almacen),

    FOREIGN KEY(id_producto) REFERENCES producto(id_producto),
    FOREIGN KEY(id_almacen) REFERENCES almacen(id_almacen)
);

-- ==========================
-- INVENTARIO
-- ==========================
CREATE TABLE inventario (
    id_inventario SERIAL PRIMARY KEY,
    cantidad_actual INTEGER,
    id_almacen INTEGER,

    FOREIGN KEY(id_almacen) REFERENCES almacen(id_almacen)
);

-- ==========================
-- PROVEEDOR
-- ==========================
CREATE TABLE proveedor (
    id_proveedor SERIAL PRIMARY KEY,
    ruc_dni VARCHAR(20),
    contacto VARCHAR(100)
);

-- RELACION PRODUCTO - PROVEEDOR
CREATE TABLE producto_proveedor (
    id_producto INTEGER,
    id_proveedor INTEGER,

    PRIMARY KEY(id_producto, id_proveedor),

    FOREIGN KEY(id_producto) REFERENCES producto(id_producto),
    FOREIGN KEY(id_proveedor) REFERENCES proveedor(id_proveedor)
);

-- ==========================
-- VALORACION DEL SERVICIO
-- ==========================
CREATE TABLE valoracion_del_servicio (
    id_resena_servicio SERIAL PRIMARY KEY,
    puntuacion INTEGER,
    comentario TEXT,
    id_cliente VARCHAR(8),

    FOREIGN KEY(id_cliente) REFERENCES cliente(id_dni)
);

-- ==========================
-- VALORACION RESEÑA DE FABRICA
-- ==========================
CREATE TABLE valoracion_resena_de_fabrica (
    id_resena SERIAL PRIMARY KEY,
    puntuacion INTEGER,
    comentario TEXT,
    id_producto INTEGER,

    FOREIGN KEY(id_producto) REFERENCES producto(id_producto)
);
