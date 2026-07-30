# La-Tiendita-de-Don-Pepe

Proyecto final de Base de Datos
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
En la actualidad, la gestión eficiente de la información es un factor fundamental para el éxito de cualquier negocio comercial. Los minimarkets, al manejar diariamente grandes cantidades de datos relacionados con productos, ventas, clientes e inventario, requieren herramientas que permitan organizar y controlar esta información de manera rápida y confiable.

El presente proyecto tiene como finalidad desarrollar una base de datos para el minimarket “La Tiendita de Don Pepe”, con el objetivo de optimizar la administración de sus operaciones diarias. Actualmente, gran parte de la información se registra de forma manual, lo que puede ocasionar errores, pérdida de datos y dificultades en el control del inventario y las ventas.

La implementación de un sistema gestor de base de datos permitirá almacenar, procesar y consultar información de manera eficiente, facilitando el registro de productos, clientes, proveedores y ventas en tiempo real. Asimismo, contribuirá al control automático del stock, la generación de reportes y la toma de decisiones basadas en información actualizada y confiable. 

De esta manera, el proyecto busca ofrecer una solución práctica que mejore la organización y productividad del negocio, demostrando la importancia de las bases de datos en la gestión moderna de establecimientos comerciales.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Motor

Motor recomendado: XAMPP con tablas InnoDB

Los scripts evitan funciones exclusivas para XAMPP Para JSON se usan `JSON_OBJECT`, `JSON_ARRAY`, `JSON_VALID`, `JSON_LENGTH`, `JSON_EXTRACT`, `JSON_UNQUOTE`, `JSON_SET` y `JSON_REMOVE`

## Orden de ejecucion

1. `01_creacion_base_datos.sql`
2. `02_insercion_datos.sql`
3. `03_crud_complejo.sql`
4. `04_reportes.sql`
5. `05_indices_explain.sql`
6. `06_transacciones.sql`
7. `07_json_hibrido.sql`
8. `08_pruebas.sql`

## Se realizo la peticion de la rubrica

- Integridad: claves primarias, foraneas, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`, `ON DELETE CASCADE`, `ON DELETE SET NULL` y `ON UPDATE CASCADE`.
- CRUD complejo: procedimientos `sp_registrar_venta`, `sp_actualizar_detalle_venta` y `sp_anular_venta`.
- Reportes: procedimientos con `JOIN`, `GROUP BY`, `HAVING`, `SUM`, `COUNT`, `AVG`, `MIN` y `MAX`.
- Exportacion: consulta `INTO OUTFILE` documentada en `04_reportes.sql`.
- Optimizacion: indices y planes `EXPLAIN` en `05_indices_explain.sql`.
- Transacciones: venta con `START TRANSACTION`, `COMMIT`, `ROLLBACK` y `SELECT ... FOR UPDATE`.
- JSON hibrido: columna `producto.atributos` para datos semiestructurados

## Modelo hibrido

Los datos principales permanecen en tablas relacionales: clientes, empleados, productos, ventas, detalles, categorias y proveedores. La columna `producto.atributos` guarda caracteristicas variables como presentacion, peso, etiquetas, origen o conservacion.

JSON complementa el modelo relacional porque se evita crear columnas vacias para atributos que no aplican a todos los productos, No reemplaza las relaciones, tan solo agrega flexibilidad para informacion semiestructurada

## Exportacion CSV

Antes de ejecutar la exportacion:

```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

Si MariaDB devuelve una ruta, usar esa carpeta en el `INTO OUTFILE` de `04_reportes.sql`. Si no tiene  lospermisos, se debe de ejecutar el reporte normal con:

```sql
CALL sp_reporte_productos_mas_vendidos('2026-06-01', '2026-07-31', 3);
```
