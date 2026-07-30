<?php
$tituloPagina = $tituloPagina ?? 'La Tiendita de Don Pepe';
$usuario = usuario_actual();
$totalCarrito = carrito_cantidad_total();
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= s($tituloPagina) ?></title>
<link rel="stylesheet" href="assets/css/estilo.css">
</head>
<body>

<div class="franja-superior">
    <div class="contenedor">
        <span>🚚 Envios en Arequipa y todo el Peru</span>
        <span>Atencion: Lun a Dom 8:00 - 21:00</span>
    </div>
</div>

<header class="principal">
    <div class="contenedor barra-nav">
        <a href="index.php" class="logo">
            <span class="emoji">🛒</span>
            <span>La Tiendita de<br><small style="font-size:11px; font-weight:800;">Don Pepe</small></span>
        </a>

        <form class="buscador" action="index.php" method="get">
            <input type="text" name="buscar" placeholder="Busca arroz, leche, detergente..." value="<?= s($_GET['buscar'] ?? '') ?>">
            <button type="submit">Buscar</button>
        </form>

        <div class="nav-acciones">
            <?php if ($usuario): ?>
                <?php if ($usuario['rol'] === 'admin'): ?>
                    <a href="admin/index.php">Panel admin</a>
                <?php endif; ?>
                <a href="mi_cuenta.php">Hola, <?= s(explode(' ', $usuario['nombres'])[0]) ?></a>
                <a href="logout.php">Salir</a>
            <?php else: ?>
                <a href="login.php">Ingresar</a>
                <a href="registro.php">Crear cuenta</a>
            <?php endif; ?>
            <a href="carrito.php" class="icono-carrito">
                🛍️ Carrito
                <?php if ($totalCarrito > 0): ?>
                    <span class="badge-carrito"><?= (int) $totalCarrito ?></span>
                <?php endif; ?>
            </a>
        </div>
    </div>
</header>

<main>
<div class="contenedor">
<?php if ($mensaje = $_SESSION['flash'] ?? null): ?>
    <div class="alerta alerta-<?= s($mensaje['tipo']) ?>"><?= s($mensaje['texto']) ?></div>
    <?php unset($_SESSION['flash']); ?>
<?php endif; ?>
