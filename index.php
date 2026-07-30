<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

requerir_login();

$carrito = carrito_detalle($pdo);
if (empty($carrito['lineas'])) {
    flash('info', 'Tu carrito esta vacio, agrega productos antes de pagar.');
    header('Location: carrito.php');
    exit;
}

$usuario = usuario_actual();
$stmt = $pdo->prepare('SELECT * FROM cliente WHERE id_dni = ?');
$stmt->execute([$usuario['id_dni']]);
$cliente = $stmt->fetch();

$metodosPago = obtener_metodos_pago($pdo);

$tituloPagina = 'Finalizar compra - La Tiendita de Don Pepe';
require __DIR__ . '/includes/header.php';
?>

<h1 style="margin-top:24px;">Finalizar compra</h1>

<div class="pasos-checkout">
    <div class="paso activo">1. Envio y pago</div>
    <div class="paso">2. Confirmacion</div>
</div>

<form method="post" action="procesar_pedido.php" class="tarjeta-form ancha" style="margin:0 0 30px;">
    <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">

    <h2 class="mt-0">Direccion de entrega</h2>
    <div class="campo">
        <label>Direccion</label>
        <input type="text" name="direccion" value="<?= s($cliente['direccion']) ?>" required>
    </div>
    <div class="fila-2">
        <div class="campo">
            <label>Provincia</label>
            <input type="text" name="provincia" value="<?= s($cliente['provincia']) ?>" required>
        </div>
        <div class="campo">
            <label>Distrito</label>
            <input type="text" name="distrito" value="<?= s($cliente['distrito']) ?>" required>
        </div>
    </div>

    <h2>Metodo de pago</h2>
    <div class="opciones-pago">
        <?php foreach ($metodosPago as $i => $m): ?>
            <label>
                <input type="radio" name="id_metodo" value="<?= (int) $m['id_metodo'] ?>" <?= $i === 0 ? 'checked' : '' ?>>
                <span><?= s($m['metodo']) ?></span>
            </label>
        <?php endforeach; ?>
    </div>

    <h2>Resumen del pedido</h2>
    <table class="tabla-carrito" style="margin-bottom:16px;">
        <tbody>
        <?php foreach ($carrito['lineas'] as $linea): ?>
            <tr>
                <td><?= s($linea['nombre']) ?> × <?= (int) $linea['cantidad'] ?></td>
                <td style="text-align:right;"><?= precio($linea['subtotal']) ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
    <div class="resumen-carrito" style="max-width:none; margin:0; box-shadow:none;">
        <div class="linea-total grande"><span>Total a pagar</span><span><?= precio($carrito['total']) ?></span></div>
    </div>

    <button type="submit" class="btn btn-naranja btn-bloque" style="margin-top:20px; padding:14px;">Confirmar y pagar</button>
</form>

<?php require __DIR__ . '/includes/footer.php'; ?>
