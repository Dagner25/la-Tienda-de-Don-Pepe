<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

requerir_login();
$usuario = usuario_actual();
$vista = $_GET['vista'] ?? 'pedidos';

// Actualizar datos personales
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'actualizar_perfil') {
    if (!csrf_valido($_POST['csrf'] ?? null)) {
        flash('error', 'Tu sesion expiro, intenta nuevamente.');
    } else {
        $telefono = trim($_POST['telefono'] ?? '');
        $correo = trim($_POST['correo'] ?? '');
        $direccion = trim($_POST['direccion'] ?? '');
        $provincia = trim($_POST['provincia'] ?? '');
        $distrito = trim($_POST['distrito'] ?? '');

        if (!filter_var($correo, FILTER_VALIDATE_EMAIL) || !preg_match('/^\d{6,9}$/', $telefono) || $direccion === '') {
            flash('error', 'Revisa que el correo, telefono y direccion sean validos.');
        } else {
            $upd = $pdo->prepare(
                'UPDATE cliente SET telefono = ?, correo = ?, direccion = ?, provincia = ?, distrito = ? WHERE id_dni = ?'
            );
            $upd->execute([$telefono, $correo, $direccion, $provincia, $distrito, $usuario['id_dni']]);
            flash('exito', 'Tus datos se actualizaron correctamente.');
        }
    }
    header('Location: mi_cuenta.php?vista=datos');
    exit;
}

$stmt = $pdo->prepare('SELECT * FROM cliente WHERE id_dni = ?');
$stmt->execute([$usuario['id_dni']]);
$cliente = $stmt->fetch();

$stmtVip = $pdo->prepare('SELECT nivel_cliente, tasa_descuento_vip FROM cliente_vip WHERE id_dni = ?');
$stmtVip->execute([$usuario['id_dni']]);
$vip = $stmtVip->fetch();

$stmtPedidos = $pdo->prepare(
    'SELECT v.id_venta, v.fch_compra, v.total, v.estado, mp.metodo,
            (SELECT COUNT(*) FROM detalle_venta dv WHERE dv.id_venta = v.id_venta) AS items
     FROM venta v
     INNER JOIN metodo_pago mp ON mp.id_metodo = v.id_metodo
     WHERE v.id_cliente = ?
     ORDER BY v.fch_compra DESC'
);
$stmtPedidos->execute([$usuario['id_dni']]);
$pedidos = $stmtPedidos->fetchAll();

$tituloPagina = 'Mi cuenta - La Tiendita de Don Pepe';
require __DIR__ . '/includes/header.php';

function pill_estado_venta(string $estado): string
{
    $mapa = ['REGISTRADA' => 'pill-registrada', 'PAGADA' => 'pill-pagada', 'ANULADA' => 'pill-anulada'];
    $clase = $mapa[$estado] ?? 'pill-registrada';
    return "<span class=\"pill $clase\">" . s($estado) . '</span>';
}
?>

<h1 style="margin-top:24px;">Mi cuenta</h1>

<div class="pestañas-cuenta">
    <a href="mi_cuenta.php?vista=pedidos" class="<?= $vista === 'pedidos' ? 'activa' : '' ?>">Mis pedidos</a>
    <a href="mi_cuenta.php?vista=datos" class="<?= $vista === 'datos' ? 'activa' : '' ?>">Mis datos</a>
</div>

<?php if ($vista === 'datos'): ?>

    <div class="tarjeta-form ancha" style="margin:0 0 30px;">
        <h2 class="mt-0">Datos personales</h2>
        <p style="color:#7c8a76; font-size:14px;">
            <?= s($cliente['nombres'] . ' ' . $cliente['apellido_p'] . ' ' . $cliente['apellido_m']) ?> · DNI <?= s($cliente['id_dni']) ?>
            <?php if ($vip): ?> · <span class="pill pill-pagada">Cliente <?= s($vip['nivel_cliente']) ?> (<?= (float) $vip['tasa_descuento_vip'] ?>% dscto.)</span><?php endif; ?>
        </p>
        <form method="post" action="mi_cuenta.php">
            <input type="hidden" name="accion" value="actualizar_perfil">
            <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
            <div class="fila-2">
                <div class="campo">
                    <label>Telefono</label>
                    <input type="text" name="telefono" value="<?= s($cliente['telefono']) ?>" required>
                </div>
                <div class="campo">
                    <label>Correo</label>
                    <input type="email" name="correo" value="<?= s($cliente['correo']) ?>" required>
                </div>
            </div>
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
            <button type="submit" class="btn btn-verde">Guardar cambios</button>
        </form>
    </div>

<?php else: ?>

    <?php if (empty($pedidos)): ?>
        <div class="vacio-lista">
            <p>Aun no tienes pedidos registrados.</p>
            <a href="index.php" class="btn btn-verde">Ir de compras</a>
        </div>
    <?php else: ?>
        <table class="tabla-pedidos">
            <thead>
                <tr><th>Pedido</th><th>Fecha</th><th>Productos</th><th>Metodo</th><th>Total</th><th>Estado</th><th></th></tr>
            </thead>
            <tbody>
            <?php foreach ($pedidos as $p): ?>
                <tr>
                    <td>#<?= (int) $p['id_venta'] ?></td>
                    <td><?= date('d/m/Y', strtotime($p['fch_compra'])) ?></td>
                    <td><?= (int) $p['items'] ?> producto(s)</td>
                    <td><?= s($p['metodo']) ?></td>
                    <td><?= precio((float) $p['total']) ?></td>
                    <td><?= pill_estado_venta($p['estado']) ?></td>
                    <td><a href="pedido_detalle.php?id=<?= (int) $p['id_venta'] ?>" class="btn btn-fantasma" style="padding:6px 12px; font-size:13px;">Ver</a></td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>

<?php endif; ?>

<?php require __DIR__ . '/includes/footer.php'; ?>
