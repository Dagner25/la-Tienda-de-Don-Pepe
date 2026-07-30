<?php
$tituloPagina = $tituloPagina ?? 'Panel admin - Don Pepe';
$paginaActiva = $paginaActiva ?? '';
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= s($tituloPagina) ?></title>
<link rel="stylesheet" href="../assets/css/estilo.css">
</head>
<body>
<div class="layout-admin">
    <aside class="admin-lateral">
        <div class="marca-admin">🛒 Don Pepe Admin</div>
        <a href="index.php" class="<?= $paginaActiva === 'dashboard' ? 'activa' : '' ?>">📊 Resumen</a>
        <a href="productos.php" class="<?= $paginaActiva === 'productos' ? 'activa' : '' ?>">📦 Productos</a>
        <a href="pedidos.php" class="<?= $paginaActiva === 'pedidos' ? 'activa' : '' ?>">🧾 Pedidos</a>
        <a href="../index.php">🌐 Ver tienda</a>
        <a href="../logout.php">🚪 Salir</a>
    </aside>
    <div class="admin-contenido">
        <?php if ($mensaje = $_SESSION['flash'] ?? null): ?>
            <div class="alerta alerta-<?= s($mensaje['tipo']) ?>"><?= s($mensaje['texto']) ?></div>
            <?php unset($_SESSION['flash']); ?>
        <?php endif; ?>
