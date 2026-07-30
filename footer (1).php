# La Tiendita de Don Pepe — Tienda Online (PHP + MySQL)

E-commerce completo construido en **PHP puro (PDO) + MySQL/MariaDB**, sobre la
base de datos `tienda_don_pepe` del proyecto de Base de Datos. Incluye
catálogo con filtros, carrito de compras, login/registro, checkout real
(con procedimientos almacenados), historial de pedidos y un panel de
administración.

## Funcionalidades

**Tienda (cliente)**
- Catálogo de productos con imágenes, paginación y orden (relevancia, precio, nombre).
- Filtros por categoría, marca, rango de precio y "solo ofertas activas".
- Buscador por nombre/descripción.
- Detalle de producto: atributos JSON (`producto.atributos`), reseñas de clientes, productos relacionados.
- Carrito de compras en sesión, con agregar/actualizar/quitar por AJAX (y respaldo sin JS).
- Registro e inicio de sesión de clientes (contraseñas con `password_hash`/bcrypt).
- Checkout que llama al procedimiento `sp_registrar_venta` (transacción real, valida stock con `FOR UPDATE`) y genera el envío.
- "Mi cuenta": edición de datos, historial de pedidos, detalle de pedido y anulación (`sp_anular_venta`, repone stock).

**Panel de administración** (`/admin`, solo rol `admin`)
- Dashboard con métricas (productos, clientes, pedidos, ingresos, stock bajo).
- CRUD de productos.
- Listado y detalle de pedidos, cambio de estado de envío y anulación de ventas.

## Requisitos

- XAMPP (o cualquier stack con PHP 8+, extensión `pdo_mysql`, y MySQL/MariaDB).
- No requiere Composer ni dependencias externas.

## Instalación

1. Copia la carpeta `tienda-web` dentro de `htdocs` de tu XAMPP
   (por ejemplo `C:\xampp\htdocs\tienda-web`).
2. Abre phpMyAdmin (o la consola de MySQL) y ejecuta, **en este orden**, todos
   los scripts de la carpeta `sql/`:
   1. `01_creacion_base_datos.sql`
   2. `02_insercion_datos.sql`
   3. `03_crud_complejo.sql`
   4. `04_reportes.sql`
   5. `05_indices_explain.sql`
   6. `06_transacciones.sql`
   7. `07_json_hibrido.sql`
   8. `08_pruebas.sql`
   9. `09_extension_web.sql` ← **nuevo**, agrega login/roles/imágenes y las cuentas de prueba.
3. Revisa `config/conexion.php` si tu MySQL no usa usuario `root` sin
   contraseña (por defecto en XAMPP sí).
4. Abre `http://localhost/tienda-web/index.php`.

## Cuentas de prueba

Contraseña para todas: **`123456`**

| Tipo    | DNI / usuario | Notas                                   |
|---------|----------------|------------------------------------------|
| Cliente | `12345678`     | Cliente VIP nivel Oro (12% dscto.)       |
| Cliente | `87654321`     | Cliente VIP nivel Plata                  |
| Cliente | `45678912`     | Cliente común                            |
| Admin   | `00000000`     | Entra también a `/admin`                 |

También puedes registrar una cuenta nueva desde "Crear cuenta".

## Estructura del proyecto

```
tienda-web/
├── config/conexion.php        Conexión PDO a MySQL
├── includes/funciones.php     Sesión, carrito, auth, helpers de vista
├── includes/header.php|footer.php
├── assets/css/estilo.css      Estilos propios (sin frameworks)
├── assets/js/carrito.js       Agregar al carrito por AJAX, +/- de cantidad
├── assets/img/*.svg           Imágenes ilustrativas por categoría
├── sql/01..09_*.sql           Scripts de base de datos (originales + extensión web)
├── index.php                  Catálogo + filtros
├── producto.php                Detalle de producto + reseñas
├── carrito.php / carrito_accion.php
├── checkout.php / procesar_pedido.php / pedido_confirmado.php
├── login.php / registro.php / logout.php
├── mi_cuenta.php / pedido_detalle.php
└── admin/                     Panel de administración
```

## Notas de diseño

- El carrito se guarda en `$_SESSION`, no en la base de datos, para mantenerlo simple.
- El checkout reutiliza el procedimiento `sp_registrar_venta` ya existente en
  `03_crud_complejo.sql`, así que toda la validación de stock, transacciones
  y rollback ya estaba resuelta a nivel de base de datos.
- Anular un pedido (cliente o admin) llama a `sp_anular_venta`, que repone el stock automáticamente.
- Las contraseñas se guardan con `password_hash()` (bcrypt) y se verifican con `password_verify()`.
- Todas las consultas usan sentencias preparadas (PDO) para evitar inyección SQL.
- Hay protección CSRF (token de sesión) en todos los formularios que modifican datos.
- El registro usa el DNI como identificador (igual que la tabla `cliente` original); el login acepta DNI o correo.
