<?php
require __DIR__ . '/../config/conexion.php';
require __DIR__ . '/../includes/funciones.php';
requerir_admin();

$totalProductos = (int) $pdo->query('SELECT COUNT(*) FROM producto')->fetchColumn();
$totalClientes = (int) $pdo->query("SELECT COUNT(*) FROM cliente WHERE rol = 'cliente'")->fetchColumn();
$totalPedidos = (int) $pdo->query('SELECT COUNT(*) FROM venta')->fetchColumn();
$ingresos = (float) $pdo->query("SELECT COALESCE(SUM(total),0) FROM venta WHERE estado != 'ANULADA'")->fetchColumn();
$stockBajo = $pdo->query('SELECT id_producto, nombre_prdct, stock_actual, stock_minimo FROM producto WHERE stock_actual <= stock_minimo ORDER BY stock_actual ASC LIMIT 8')->fetchAll();
$ultimosPedidos = $pdo->query(
    "SELECT v.id_venta, v.fch_compra, v.total, v.estado, CONCAT(c.nombres, ' ', c.apellido_p) AS cliente
     FROM venta v INNER JOIN cliente c ON c.id_dni = v.id_cliente
     ORDER BY v.fch_compra DESC LIMIT 8")->fetchAll();

$tituloPagina = 'Resumen - Panel admin';
$paginaActiva = 'dashboard';
require __DIR__ . '/header.php';
?>

<div class="encabezado-admin"><h1>Resumen general</h1></div>

<div class="tarjetas-resumen">
    <div class="tarjeta-resumen"><div class="valor"><?= $totalProductos ?></div><div class="etiqueta">Productos</div></div>
    <div class="tarjeta-resumen"><div class="valor"><?= $totalClientes ?></div><div class="etiqueta">Clientes registrados</div></div>
    <div class="tarjeta-resumen"><div class="valor"><?= $totalPedidos ?></div><div class="etiqueta">Pedidos totales</div></div>
    <div class="tarjeta-resumen"><div class="valor"><?= precio($ingresos) ?></div><div class="etiqueta">Ingresos (no anulados)</div></div>
</div>

<div style="display:grid; grid-template-columns: 1.3fr 1fr; gap:20px;">
    <div>
        <h3>Ultimos pedidos</h3>
        <table class="tabla-admin">
            <thead><tr><th>#</th><th>Cliente</th><th>Fecha</th><th>Total</th><th>Estado</th></tr></thead>
            <tbody>
            <?php foreach ($ultimosPedidos as $p): ?>
                <tr>
                    <td><a href="pedido_ver.php?id=<?= (int) $p['id_venta'] ?>">#<?= (int) $p['id_venta'] ?></a></td>
                    <td><?= s($p['cliente']) ?></td>
                    <td><?= date('d/m/Y', strtotime($p['fch_compra'])) ?></td>
                    <td><?= precio((float) $p['total']) ?></td>
                    <td><?= s($p['estado']) ?></td>
                </tr>
            <?php endforeach; ?>
            <?php if (empty($ultimosPedidos)): ?><tr><td colspan="5" class="texto-centro">Sin pedidos aun</td></tr><?php endif; ?>
            </tbody>
        </table>
    </div>
    <div>
        <h3>Stock bajo ⚠️</h3>
        <table class="tabla-admin">
            <thead><tr><th>Producto</th><th>Stock</th><th>Minimo</th></tr></thead>
            <tbody>
            <?php foreach ($stockBajo as $p): ?>
                <tr>
                    <td><a href="productos.php?editar=<?= (int) $p['id_producto'] ?>"><?= s($p['nombre_prdct']) ?></a></td>
                    <td><?= (int) $p['stock_actual'] ?></td>
                    <td><?= (int) $p['stock_minimo'] ?></td>
                </tr>
            <?php endforeach; ?>
            <?php if (empty($stockBajo)): ?><tr><td colspan="3" class="texto-centro">Todo el stock esta en buen nivel</td></tr><?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require __DIR__ . '/footer.php'; ?>
