<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

requerir_login();

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !csrf_valido($_POST['csrf'] ?? null)) {
    header('Location: checkout.php');
    exit;
}

$carrito = carrito_detalle($pdo);
if (empty($carrito['lineas'])) {
    flash('error', 'Tu carrito esta vacio.');
    header('Location: carrito.php');
    exit;
}

$usuario = usuario_actual();
$idMetodo = (int) ($_POST['id_metodo'] ?? 0);
$direccion = trim($_POST['direccion'] ?? '');
$provincia = trim($_POST['provincia'] ?? '');
$distrito = trim($_POST['distrito'] ?? '');

if ($idMetodo <= 0 || $direccion === '' || $provincia === '' || $distrito === '') {
    flash('error', 'Completa la direccion y el metodo de pago.');
    header('Location: checkout.php');
    exit;
}

$detalles = array_map(function ($linea) {
    return ['id_producto' => $linea['id_producto'], 'cantidad' => $linea['cantidad']];
}, $carrito['lineas']);

$json = json_encode($detalles, JSON_UNESCAPED_UNICODE);

try {
    $stmt = $pdo->prepare('CALL sp_registrar_venta(?, ?, ?, ?)');
    $stmt->execute([$usuario['id_dni'], null, $idMetodo, $json]);
    $resultado = $stmt->fetch();
    $stmt->closeCursor();

    $idVenta = (int) $resultado['id_venta_registrada'];

    $insEnvio = $pdo->prepare(
        'INSERT INTO envio (direcc_entrega, estado, id_venta) VALUES (?, "Pendiente", ?)'
    );
    $insEnvio->execute([trim("$direccion, $distrito, $provincia"), $idVenta]);

    carrito_vaciar();
    flash('exito', '¡Pedido registrado con exito! Tu numero de pedido es #' . $idVenta . '.');
    header('Location: pedido_confirmado.php?id=' . $idVenta);
    exit;

} catch (PDOException $e) {
    // Mensajes controlados desde el SIGNAL SQLSTATE '45000' del procedimiento.
    $mensaje = $e->getMessage();
    if (strpos($mensaje, '45000') !== false && preg_match('/45000\s+(.*?)(?:\'|$)/', $mensaje, $m)) {
        $mensajeLimpio = $m[1];
    } else {
        $mensajeLimpio = 'No se pudo registrar tu pedido. Verifica el stock disponible e intenta nuevamente.';
    }
    flash('error', $mensajeLimpio);
    header('Location: checkout.php');
    exit;
}
