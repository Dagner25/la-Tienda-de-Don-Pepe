-- ==========================
-- BASE DE DATOS
-- ==========================

DROP DATABASE IF EXISTS tienda_don_pepe;
CREATE DATABASE tienda_don_pepe
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE tienda_don_pepe;

-- ==========================
-- TABLA CLIENTE
-- ==========================

CREATE TABLE cliente (
    id_dni CHAR(8) PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellido_p VARCHAR(50) NOT NULL,
    apellido_m VARCHAR(50),
    region VARCHAR(50) NOT NULL DEFAULT 'Lima',
    direccion VARCHAR(200) NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    distrito VARCHAR(50) NOT NULL,
    fch_nacimiento DATE,
    telefono VARCHAR(20) NOT NULL UNIQUE,
    correo VARCHAR(100) NOT NULL UNIQUE,
    CHECK (id_dni REGEXP '^[0-9]{8}$')
) ENGINE=InnoDB;

-- ==========================
-- TABLA CLIENTE VIP
-- ==========================

CREATE TABLE cliente_vip (
    id_dni CHAR(8) PRIMARY KEY,
    nivel_cliente VARCHAR(20) NOT NULL DEFAULT 'Bronce',
    tasa_descuento_vip DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    CHECK (nivel_cliente IN ('Bronce', 'Plata', 'Oro')),
    CHECK (tasa_descuento_vip BETWEEN 0 AND 30),
    FOREIGN KEY (id_dni) REFERENCES cliente(id_dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA CLIENTE COMUN
-- ==========================

CREATE TABLE cliente_comun (
    id_dni CHAR(8) PRIMARY KEY,
    lim_descuento_acumulado DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tasa_descuento DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    CHECK (lim_descuento_acumulado >= 0),
    CHECK (tasa_descuento BETWEEN 0 AND 20),
    FOREIGN KEY (id_dni) REFERENCES cliente(id_dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA EMPLEADO
-- ==========================

CREATE TABLE empleado (
    id_dni CHAR(8) PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellido_p VARCHAR(50) NOT NULL,
    apellido_m VARCHAR(50),
    region VARCHAR(50) NOT NULL DEFAULT 'Lima',
    provincia VARCHAR(50) NOT NULL,
    distrito VARCHAR(50) NOT NULL,
    fch_nacimiento DATE,
    telefono VARCHAR(20) NOT NULL UNIQUE,
    correo VARCHAR(100) NOT NULL UNIQUE,
    sueldo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    fch_ingreso DATE NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    CHECK (id_dni REGEXP '^[0-9]{8}$'),
    CHECK (sueldo >= 0)
) ENGINE=InnoDB;

-- ==========================
-- TABLA GERENTE
-- ==========================

CREATE TABLE gerente (
    id_dni CHAR(8) PRIMARY KEY,
    descripcion VARCHAR(200) NOT NULL,
    FOREIGN KEY (id_dni) REFERENCES empleado(id_dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA EMPLEADOS OTROS
-- ==========================

CREATE TABLE empleados_otros (
    id_dni CHAR(8) PRIMARY KEY,
    cargo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200),
    FOREIGN KEY (id_dni) REFERENCES empleado(id_dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA METODO DE PAGO
-- ==========================

CREATE TABLE metodo_pago (
    id_metodo INT PRIMARY KEY AUTO_INCREMENT,
    metodo VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ==========================
-- TABLA CATEGORIA
-- ==========================

CREATE TABLE categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nmbr_categoria VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ==========================
-- TABLA MARCA
-- ==========================

CREATE TABLE marca (
    id_marca INT PRIMARY KEY AUTO_INCREMENT,
    nombre_marca VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ==========================
-- TABLA PRODUCTO
-- ==========================

-- Atributos permite guardar datos variables en formato JSON.
CREATE TABLE producto (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre_prdct VARCHAR(120) NOT NULL UNIQUE,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,
    id_categoria INT NULL,
    id_marca INT NULL,
    atributos JSON NULL,
    CHECK (precio_venta > 0),
    CHECK (stock_actual >= 0),
    CHECK (stock_minimo >= 0),
    CHECK (atributos IS NULL OR JSON_VALID(atributos)),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA PROVEEDOR
-- ==========================

CREATE TABLE proveedor (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    ruc_dni VARCHAR(20) NOT NULL UNIQUE,
    contacto VARCHAR(120) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100) UNIQUE
) ENGINE=InnoDB;

-- ==========================
-- TABLA PRODUCTO PROVEEDOR
-- ==========================

CREATE TABLE producto_proveedor (
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    PRIMARY KEY(id_producto, id_proveedor),
    FOREIGN KEY(id_producto) REFERENCES producto(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(id_proveedor) REFERENCES proveedor(id_proveedor)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA VENTA
-- ==========================

CREATE TABLE venta (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    fch_compra DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado VARCHAR(20) NOT NULL DEFAULT 'REGISTRADA',
    id_cliente CHAR(8) NOT NULL,
    id_empleado CHAR(8) NULL,
    id_metodo INT NOT NULL,
    CHECK (total >= 0),
    CHECK (estado IN ('REGISTRADA', 'PAGADA', 'ANULADA')),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_dni)
        ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_dni)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo)
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA DETALLE VENTA
-- ==========================

CREATE TABLE detalle_venta (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    CHECK (cantidad > 0),
    CHECK (precio_unitario > 0),
    CHECK (subtotal >= 0),
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA ENVIO
-- ==========================

CREATE TABLE envio (
    id_envio INT PRIMARY KEY AUTO_INCREMENT,
    direcc_entrega VARCHAR(200) NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    id_venta INT NOT NULL UNIQUE,
    CHECK (estado IN ('Pendiente', 'Preparando', 'En camino', 'Entregado', 'Cancelado')),
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA DEVOLUCION
-- ==========================

CREATE TABLE devolucion (
    id_devolucion INT PRIMARY KEY AUTO_INCREMENT,
    motivo VARCHAR(200) NOT NULL,
    fecha DATE NOT NULL,
    monto_reembolso DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    id_venta INT NULL,
    CHECK (monto_reembolso >= 0),
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA PROMOCION
-- ==========================

CREATE TABLE promocion (
    id_promocion INT PRIMARY KEY AUTO_INCREMENT,
    porcentaje DECIMAL(5,2) NOT NULL,
    fch_inicio DATE NOT NULL,
    fch_fin DATE NOT NULL,
    CHECK (porcentaje BETWEEN 0 AND 100),
    CHECK (fch_fin >= fch_inicio)
) ENGINE=InnoDB;




-- ==========================
-- TABLA PRODUCTO PROMOCION
-- ==========================

CREATE TABLE producto_promocion (
    id_producto INT NOT NULL,
    id_promocion INT NOT NULL,
    PRIMARY KEY(id_producto, id_promocion),
    FOREIGN KEY(id_producto) REFERENCES producto(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(id_promocion) REFERENCES promocion(id_promocion)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA ALMACEN
-- ==========================

CREATE TABLE almacen (
    id_almacen INT PRIMARY KEY AUTO_INCREMENT,
    nombre_almacen VARCHAR(100) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL,
    CHECK (tipo IN ('Principal', 'Secundario', 'Temporal'))
) ENGINE=InnoDB;

-- ==========================
-- TABLA PRODUCTO ALMACEN
-- ==========================

CREATE TABLE producto_almacen (
    id_producto INT NOT NULL,
    id_almacen INT NOT NULL,
    PRIMARY KEY(id_producto, id_almacen),
    FOREIGN KEY(id_producto) REFERENCES producto(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY(id_almacen) REFERENCES almacen(id_almacen)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA INVENTARIO
-- ==========================

CREATE TABLE inventario (
    id_inventario INT PRIMARY KEY AUTO_INCREMENT,
    cantidad_actual INT NOT NULL DEFAULT 0,
    id_almacen INT NOT NULL,
    CHECK (cantidad_actual >= 0),
    FOREIGN KEY(id_almacen) REFERENCES almacen(id_almacen)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TABLA VALORACION DEL SERVICIO
-- ==========================

CREATE TABLE valoracion_del_servicio (
    id_resena_servicio INT PRIMARY KEY AUTO_INCREMENT,
    puntuacion INT NOT NULL,
    comentario TEXT NOT NULL,
    id_cliente CHAR(8) NOT NULL,
    CHECK (puntuacion BETWEEN 1 AND 5),
    FOREIGN KEY(id_cliente) REFERENCES cliente(id_dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;




-- ==========================
-- TABLA VALORACION DE PRODUCTO
-- ==========================

CREATE TABLE valoracion_resena_de_fabrica (
    id_resena INT PRIMARY KEY AUTO_INCREMENT,
    puntuacion INT NOT NULL,
    comentario TEXT NOT NULL,
    id_producto INT NOT NULL,
    CHECK (puntuacion BETWEEN 1 AND 5),
    FOREIGN KEY(id_producto) REFERENCES producto(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;
