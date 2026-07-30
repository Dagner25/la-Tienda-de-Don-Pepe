<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

requerir_login();
$usuario = usuario_actual();
$idVenta = (int) ($_GET['id'] ?? 0);

$stmt = $pdo->prepare(
    'SELECT v.*, mp.metodo, e.direcc_entrega, e.estado AS estado_envio
     FROM venta v
     INNER JOIN metodo_pago mp ON mp.id_metodo = v.id_metodo
     LEFT JOIN envio e ON e.id_venta = v.id_venta
     WHERE v.id_venta = ? AND v.id_cliente = ?'
);
$stmt->execute([$idVenta, $usuario['id_dni']]);
$venta = $stmt->fetch();

if (!$venta) {
    flash('error', 'Ese pedido no existe o no te pertenece.');
    header('Location: mi_cuenta.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'anular') {
    if (!csrf_valido($_POST['csrf'] ?? null)) {
        flash('error', 'Tu sesion expiro, intenta nuevamente.');
    } elseif ($venta['estado'] === 'ANULADA') {
        flash('info', 'Ese pedido ya estaba anulado.');
    } else {
        try {
            $call = $pdo->prepare('CALL sp_anular_venta(?)');
            $call->execute([$idVenta]);
            $call->closeCursor();
            flash('exito', 'Tu pedido fue anulado y el stock se repuso correctamente.');
        } catch (PDOException $e) {
            flash('error', 'No se pudo anular el pedido.');
        }
    }
    header('Location: pedido_detalle.php?id=' . $idVenta);
    exit;
}

$stmtDetalle = $pdo->prepare(
    'SELECT dv.*, p.nombre_prdct, p.imagen FROM detalle_venta dv
     INNER JOIN producto p ON p.id_producto = dv.id_producto
     WHERE dv.id_venta = ?'
);
$stmtDetalle->execute([$idVenta]);
$lineas = $stmtDetalle->fetchAll();

$tituloPagina = 'Pedido #' . $idVenta . ' - La Tiendita de Don Pepe';
require __DIR__ . '/includes/header.php';

$mapaPill = ['REGISTRADA' => 'pill-registrada', 'PAGADA' => 'pill-pagada', 'ANULADA' => 'pill-anulada'];
$mapaPillEnvio = ['Pendiente' => 'pill-pendiente', 'Preparando' => 'pill-preparando', 'En camino' => 'pill-en-camino', 'Entregado' => 'pill-entregado', 'Cancelado' => 'pill-cancelado'];
?>

<div class="tarjeta-form ancha" style="margin-top:24px;">
    <div class="encabezado-admin" style="margin-bottom:6px;">
        <h2 class="mt-0">Pedido #<?= (int) $venta['id_venta'] ?></h2>
        <span class="pill <?= $mapaPill[$venta['estado']] ?? '' ?>"><?= s($venta['estado']) ?></span>
    </div>
    <p style="color:#7c8a76; font-size:14px;">
        Realizado el <?= date('d/m/Y H:i', strtotime($venta['fch_compra'])) ?> · Pago: <?= s($venta['metodo']) ?>
        <?php if ($venta['estado_envio']): ?> · Envio: <span class="pill <?= $mapaPillEnvio[$venta['estado_envio']] ?? '' ?>"><?= s($venta['estado_envio']) ?></span><?php endif; ?>
    </p>
    <?php if ($venta['direcc_entrega']): ?>
        <p style="font-size:14px;"><strong>Entrega en:</strong> <?= s($venta['direcc_entrega']) ?></p>
    <?php endif; ?>

    <table class="tabla-carrito" style="margin-top:16px;">
        <thead><tr><th>Producto</th><th>Cantidad</th><th>Precio</th><th>Subtotal</th></tr></thead>
        <tbody>
        <?php foreach ($lineas as $l): ?>
            <tr>
                <td>
                    <div class="fila-producto-carrito">
                        <img src="<?= s(url_imagen_producto($l['imagen'])) ?>" alt="">
                        <?= s($l['nombre_prdct']) ?>
                    </div>
                </td>
                <td><?= (int) $l['cantidad'] ?></td>
                <td><?= precio((float) $l['precio_unitario']) ?></td>
                <td><?= precio((float) $l['subtotal']) ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>

    <div class="resumen-carrito" style="max-width:none; margin-top:16px; box-shadow:none;">
        <div class="linea-total grande"><span>Total</span><span><?= precio((float) $venta['total']) ?></span></div>
    </div>

    <div style="display:flex; gap:10px; margin-top:20px;">
        <a href="mi_cuenta.php" class="btn btn-fantasma">← Volver a mis pedidos</a>
        <?php if ($venta['estado'] !== 'ANULADA'): ?>
            <form method="post" action="pedido_detalle.php?id=<?= (int) $idVenta ?>" onsubmit="return confirm('¿Seguro que deseas anular este pedido? El stock se repondra.');">
                <input type="hidden" name="accion" value="anular">
                <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
                <button type="submit" class="btn btn-peligro">Anular pedido</button>
            </form>
        <?php endif; ?>
    </div>
</div>

<?php require __DIR__ . '/includes/footer.php'; ?>
