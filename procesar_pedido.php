<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

requerir_login();

$idVenta = (int) ($_GET['id'] ?? 0);
$usuario = usuario_actual();

$stmt = $pdo->prepare('SELECT * FROM venta WHERE id_venta = ? AND id_cliente = ?');
$stmt->execute([$idVenta, $usuario['id_dni']]);
$venta = $stmt->fetch();

if (!$venta) {
    header('Location: mi_cuenta.php');
    exit;
}

$tituloPagina = 'Pedido confirmado - La Tiendita de Don Pepe';
require __DIR__ . '/includes/header.php';
?>

<div class="tarjeta-form ancha texto-centro">
    <div style="font-size:60px;">✅</div>
    <h2>¡Gracias por tu compra!</h2>
    <p>Tu pedido <strong>#<?= (int) $venta['id_venta'] ?></strong> fue registrado correctamente por un total de <strong><?= precio((float) $venta['total']) ?></strong>.</p>
    <p style="color:#7c8a76;">Te avisaremos por correo cuando tu pedido este en camino.</p>
    <div style="display:flex; gap:12px; justify-content:center; margin-top:20px;">
        <a href="pedido_detalle.php?id=<?= (int) $venta['id_venta'] ?>" class="btn btn-verde">Ver detalle del pedido</a>
        <a href="index.php" class="btn btn-fantasma">Seguir comprando</a>
    </div>
</div>

<?php require __DIR__ . '/includes/footer.php'; ?>
