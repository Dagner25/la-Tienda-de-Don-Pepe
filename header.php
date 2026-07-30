<?php


if (session_status() === PHP_SESSION_NONE) {
    session_start();
}


function usuario_actual(): ?array
{
    return $_SESSION['usuario'] ?? null;
}

function esta_logueado(): bool
{
    return isset($_SESSION['usuario']);
}

function es_admin(): bool
{
    return esta_logueado() && $_SESSION['usuario']['rol'] === 'admin';
}

function requerir_login(): void
{
    if (!esta_logueado()) {
        $_SESSION['redirigir_despues_login'] = $_SERVER['REQUEST_URI'];
        header('Location: login.php');
        exit;
    }
}

function requerir_admin(): void
{
    requerir_login();
    if (!es_admin()) {
        header('Location: ../index.php');
        exit;
    }
}

function token_csrf(): string
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function csrf_valido(?string $token): bool
{
    return !empty($token) && !empty($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

function carrito_items(): array
{
    return $_SESSION['carrito'] ?? [];
}

function carrito_cantidad_total(): int
{
    return array_sum(carrito_items());
}

function carrito_agregar(int $idProducto, int $cantidad): void
{
    if ($cantidad < 1) {
        $cantidad = 1;
    }
    if (!isset($_SESSION['carrito'])) {
        $_SESSION['carrito'] = [];
    }
    $actual = $_SESSION['carrito'][$idProducto] ?? 0;
    $_SESSION['carrito'][$idProducto] = $actual + $cantidad;
}

function carrito_actualizar(int $idProducto, int $cantidad): void
{
    if ($cantidad <= 0) {
        carrito_quitar($idProducto);
        return;
    }
    $_SESSION['carrito'][$idProducto] = $cantidad;
}

function carrito_quitar(int $idProducto): void
{
    unset($_SESSION['carrito'][$idProducto]);
}

function carrito_vaciar(): void
{
    $_SESSION['carrito'] = [];
}

function carrito_detalle(PDO $pdo): array
{
    $items = carrito_items();
    if (empty($items)) {
        return ['lineas' => [], 'total' => 0.0];
    }

    $ids = array_map('intval', array_keys($items));
    $placeholders = implode(',', array_fill(0, count($ids), '?'));

    $sql = "SELECT id_producto, nombre_prdct, precio_venta, stock_actual, imagen
            FROM producto WHERE id_producto IN ($placeholders)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($ids);
    $productos = $stmt->fetchAll();

    $lineas = [];
    $total = 0.0;

    foreach ($productos as $p) {
        $cantidad = min((int) $items[$p['id_producto']], (int) $p['stock_actual']);
        if ($cantidad < 1) {
            continue;
        }
        $subtotal = round($cantidad * (float) $p['precio_venta'], 2);
        $total += $subtotal;
        $lineas[] = [
            'id_producto'   => (int) $p['id_producto'],
            'nombre'        => $p['nombre_prdct'],
            'precio'        => (float) $p['precio_venta'],
            'cantidad'      => $cantidad,
            'stock'         => (int) $p['stock_actual'],
            'imagen'        => $p['imagen'],
            'subtotal'      => $subtotal,
        ];
    }

    return ['lineas' => $lineas, 'total' => round($total, 2)];
}

function flash(string $tipo, string $texto): void
{
    $_SESSION['flash'] = ['tipo' => $tipo, 'texto' => $texto];
}


function obtener_categorias(PDO $pdo): array
{
    return $pdo->query('SELECT id_categoria, nmbr_categoria FROM categoria ORDER BY nmbr_categoria')->fetchAll();
}

function obtener_marcas(PDO $pdo): array
{
    return $pdo->query('SELECT id_marca, nombre_marca FROM marca ORDER BY nombre_marca')->fetchAll();
}

function obtener_metodos_pago(PDO $pdo): array
{
    return $pdo->query('SELECT id_metodo, metodo FROM metodo_pago ORDER BY id_metodo')->fetchAll();
}


function s(?string $valor): string
{
    return htmlspecialchars($valor ?? '', ENT_QUOTES, 'UTF-8');
}

function precio(float $valor): string
{
    return 'S/ ' . number_format($valor, 2);
}

function url_imagen_producto(?string $imagen, string $prefix = ''): string
{
    $imagen = $imagen ?: 'producto.svg';
    $ruta = __DIR__ . '/../assets/img/' . $imagen;
    if (!is_file($ruta)) {
        $imagen = 'producto.svg';
    }
    return $prefix . 'assets/img/' . $imagen;
}
