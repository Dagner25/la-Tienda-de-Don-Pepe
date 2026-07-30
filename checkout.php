<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

$tituloPagina = 'Mi carrito - La Tiendita de Don Pepe';
$carrito = carrito_detalle($pdo);
require __DIR__ . '/includes/header.php';
?>

<h1 style="margin-top:24px;">Mi carrito</h1>

<?php if (empty($carrito['lineas'])): ?>
    <div class="carrito-vacio">
        <div class="emoji-grande">🛒</div>
        <p>Tu carrito esta vacio por ahora.</p>
        <a href="index.php" class="btn btn-verde">Ir al catalogo</a>
    </div>
<?php else: ?>
    <table class="tabla-carrito">
        <thead>
            <tr>
                <th>Producto</th>
                <th>Precio</th>
                <th>Cantidad</th>
                <th>Subtotal</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($carrito['lineas'] as $linea): ?>
            <tr>
                <td>
                    <div class="fila-producto-carrito">
                        <img src="<?= s(url_imagen_producto($linea['imagen'])) ?>" alt="">
                        <a href="producto.php?id=<?= (int) $linea['id_producto'] ?>"><?= s($linea['nombre']) ?></a>
                    </div>
                </td>
                <td><?= precio($linea['precio']) ?></td>
                <td>
                    <form class="form-actualizar-carrito" method="post" action="carrito_accion.php">
                        <input type="hidden" name="accion" value="actualizar">
                        <input type="hidden" name="id_producto" value="<?= (int) $linea['id_producto'] ?>">
                        <input type="hidden" name="volver" value="carrito.php">
                        <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
                        <div class="control-cantidad-carrito">
                            <button type="button" data-paso="-1" data-objetivo="#cant-<?= (int) $linea['id_producto'] ?>">−</button>
                            <input type="number" id="cant-<?= (int) $linea['id_producto'] ?>" name="cantidad" value="<?= (int) $linea['cantidad'] ?>" min="1" max="<?= (int) $linea['stock'] ?>">
                            <button type="button" data-paso="1" data-objetivo="#cant-<?= (int) $linea['id_producto'] ?>">+</button>
                        </div>
                    </form>
                </td>
                <td><strong><?= precio($linea['subtotal']) ?></strong></td>
                <td>
                    <form method="post" action="carrito_accion.php">
                        <input type="hidden" name="accion" value="quitar">
                        <input type="hidden" name="id_producto" value="<?= (int) $linea['id_producto'] ?>">
                        <input type="hidden" name="volver" value="carrito.php">
                        <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
                        <button type="submit" class="quitar-item" style="background:none;border:none;cursor:pointer;">Quitar</button>
                    </form>
                </td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>

    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px;">
        <a href="index.php" class="btn btn-fantasma">← Seguir comprando</a>
        <form method="post" action="carrito_accion.php" onsubmit="return confirm('¿Vaciar todo el carrito?');">
            <input type="hidden" name="accion" value="vaciar">
            <input type="hidden" name="volver" value="carrito.php">
            <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
            <button type="submit" class="btn btn-fantasma">Vaciar carrito</button>
        </form>
    </div>

    <div class="resumen-carrito">
        <div class="linea-total"><span>Subtotal</span><span><?= precio($carrito['total']) ?></span></div>
        <div class="linea-total"><span>Envio</span><span>Se calcula en el pago</span></div>
        <div class="linea-total grande"><span>Total</span><span><?= precio($carrito['total']) ?></span></div>
        <a href="checkout.php" id="btn-continuar-pagar" class="btn btn-naranja btn-bloque" style="margin-top:14px; padding:13px;">Continuar a pagar</a>
    </div>
<?php endif; ?>

<?php require __DIR__ . '/includes/footer.php'; ?>
