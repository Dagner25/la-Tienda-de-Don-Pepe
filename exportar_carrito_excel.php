<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

$esAjax = ($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') === 'XMLHttpRequest';

function responder(bool $ok, string $mensaje, bool $esAjax, string $volver = 'index.php')
{
    global $pdo;
    if ($esAjax) {
        header('Content-Type: application/json');
        echo json_encode([
            'ok' => $ok,
            'mensaje' => $mensaje,
            'total_items' => carrito_cantidad_total(),
        ]);
        exit;
    }
    flash($ok ? 'exito' : 'error', $mensaje);
    header('Location: ' . $volver);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.php');
    exit;
}

$volverA = $_POST['volver'] ?? 'index.php';
$accion = $_POST['accion'] ?? '';

if (!csrf_valido($_POST['csrf'] ?? null)) {
    responder(false, 'Tu sesion expiro, recarga la pagina e intenta de nuevo.', $esAjax, $volverA);
}

$idProducto = (int) ($_POST['id_producto'] ?? 0);

if ($accion === 'agregar') {
    $cantidad = max(1, (int) ($_POST['cantidad'] ?? 1));

    $stmt = $pdo->prepare('SELECT stock_actual, nombre_prdct FROM producto WHERE id_producto = ?');
    $stmt->execute([$idProducto]);
    $producto = $stmt->fetch();

    if (!$producto) {
        responder(false, 'El producto ya no existe.', $esAjax, $volverA);
    }
    if ((int) $producto['stock_actual'] <= 0) {
        responder(false, 'Ese producto esta agotado.', $esAjax, $volverA);
    }

    $enCarrito = carrito_items()[$idProducto] ?? 0;
    $cantidad = min($cantidad, max(0, (int) $producto['stock_actual'] - $enCarrito));

    if ($cantidad <= 0) {
        responder(false, 'Ya tienes en el carrito todo el stock disponible de "' . $producto['nombre_prdct'] . '".', $esAjax, $volverA);
    }

    carrito_agregar($idProducto, $cantidad);
    responder(true, $producto['nombre_prdct'] . ' se agrego al carrito.', $esAjax, $volverA);

} elseif ($accion === 'actualizar') {
    $cantidad = max(0, (int) ($_POST['cantidad'] ?? 1));

    $stmt = $pdo->prepare('SELECT stock_actual FROM producto WHERE id_producto = ?');
    $stmt->execute([$idProducto]);
    $stock = (int) $stmt->fetchColumn();
    $cantidad = min($cantidad, $stock);

    carrito_actualizar($idProducto, $cantidad);
    responder(true, 'Carrito actualizado.', $esAjax, $volverA);

} elseif ($accion === 'quitar') {
    carrito_quitar($idProducto);
    responder(true, 'Producto quitado del carrito.', $esAjax, $volverA);

} elseif ($accion === 'vaciar') {
    carrito_vaciar();
    responder(true, 'Carrito vaciado.', $esAjax, $volverA);

} else {
    responder(false, 'Accion no reconocida.', $esAjax, $volverA);
}
