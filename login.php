<?php

require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

$carrito = carrito_detalle($pdo);

if (empty($carrito['lineas'])) {
    flash('info', 'Tu carrito esta vacio, no hay nada que exportar.');
    header('Location: carrito.php');
    exit;
}

$usuario = usuario_actual();
$nombreCliente = $usuario ? ($usuario['nombres'] . ' ' . $usuario['apellido']) : 'Invitado';
$fecha = date('d/m/Y H:i');
$nombreArchivo = 'resumen_carrito_' . date('Y-m-d_His') . '.xls';

header('Content-Type: application/vnd.ms-excel; charset=UTF-8');
header('Content-Disposition: attachment; filename="' . $nombreArchivo . '"');
header('Pragma: no-cache');
header('Expires: 0');

echo "\xEF\xBB\xBF";
?>
<table border="1">
    <tr>
        <td colspan="4" style="font-size:14pt; font-weight:bold;">La Tiendita de Don Pepe - Resumen de carrito</td>
    </tr>
    <tr>
        <td colspan="4">Cliente: <?= s($nombreCliente) ?> &nbsp;&nbsp; Fecha: <?= s($fecha) ?></td>
    </tr>
    <tr><td colspan="4"></td></tr>
    <tr style="background:#2f6f3e; color:#ffffff; font-weight:bold;">
        <td>Producto</td>
        <td>Precio unitario (S/)</td>
        <td>Cantidad</td>
        <td>Subtotal (S/)</td>
    </tr>
    <?php foreach ($carrito['lineas'] as $linea): ?>
    <tr>
        <td><?= s($linea['nombre']) ?></td>
        <td style="mso-number-format:'0.00';"><?= number_format($linea['precio'], 2, '.', '') ?></td>
        <td><?= (int) $linea['cantidad'] ?></td>
        <td style="mso-number-format:'0.00';"><?= number_format($linea['subtotal'], 2, '.', '') ?></td>
    </tr>
    <?php endforeach; ?>
    <tr><td colspan="4"></td></tr>
    <tr style="font-weight:bold; background:#eef5ea;">
        <td colspan="3" align="right">TOTAL</td>
        <td style="mso-number-format:'0.00';"><?= number_format($carrito['total'], 2, '.', '') ?></td>
    </tr>
</table>
