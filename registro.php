<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

$idProducto = (int) ($_GET['id'] ?? 0);

$stmt = $pdo->prepare(
    "SELECT p.*, c.nmbr_categoria, m.nombre_marca
     FROM producto p
     LEFT JOIN categoria c ON c.id_categoria = p.id_categoria
     LEFT JOIN marca m ON m.id_marca = p.id_marca
     WHERE p.id_producto = ?"
);
$stmt->execute([$idProducto]);
$producto = $stmt->fetch();

if (!$producto) {
    http_response_code(404);
    $tituloPagina = 'Producto no encontrado';
    require __DIR__ . '/includes/header.php';
    echo '<div class="vacio-lista"><p>Ese producto no existe o fue retirado del catalogo.</p><a href="index.php" class="btn btn-verde">Volver al catalogo</a></div>';
    require __DIR__ . '/includes/footer.php';
    exit;
}

$atributos = $producto['atributos'] ? json_decode($producto['atributos'], true) : [];

// Oferta activa
$stmtOferta = $pdo->prepare(
    "SELECT pr.porcentaje FROM producto_promocion pp
     INNER JOIN promocion pr ON pr.id_promocion = pp.id_promocion
     WHERE pp.id_producto = ? AND CURDATE() BETWEEN pr.fch_inicio AND pr.fch_fin
     ORDER BY pr.porcentaje DESC LIMIT 1"
);
$stmtOferta->execute([$idProducto]);
$oferta = $stmtOferta->fetchColumn();

// Reseñas del producto
$stmtResenas = $pdo->prepare(
    'SELECT id_resena, puntuacion, comentario FROM valoracion_resena_de_fabrica WHERE id_producto = ? ORDER BY id_resena DESC'
);
$stmtResenas->execute([$idProducto]);
$resenas = $stmtResenas->fetchAll();
$promedioResenas = $resenas ? round(array_sum(array_column($resenas, 'puntuacion')) / count($resenas), 1) : null;

// Procesar nueva reseña
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['accion']) && $_POST['accion'] === 'resena') {
    requerir_login();
    if (!csrf_valido($_POST['csrf'] ?? null)) {
        flash('error', 'Token de seguridad invalido, intenta nuevamente.');
    } else {
        $puntuacion = max(1, min(5, (int) ($_POST['puntuacion'] ?? 5)));
        $comentario = trim($_POST['comentario'] ?? '');
        if ($comentario === '') {
            flash('error', 'Escribe un comentario para tu reseña.');
        } else {
            $ins = $pdo->prepare('INSERT INTO valoracion_resena_de_fabrica (puntuacion, comentario, id_producto) VALUES (?, ?, ?)');
            $ins->execute([$puntuacion, $comentario, $idProducto]);
            flash('exito', 'Gracias por tu reseña.');
        }
    }
    header('Location: producto.php?id=' . $idProducto . '#resenas');
    exit;
}

// Productos relacionados (misma categoria)
$relacionados = [];
if ($producto['id_categoria']) {
    $stmtRel = $pdo->prepare(
        'SELECT id_producto, nombre_prdct, precio_venta, imagen FROM producto
         WHERE id_categoria = ? AND id_producto != ? ORDER BY RAND() LIMIT 4'
    );
    $stmtRel->execute([$producto['id_categoria'], $idProducto]);
    $relacionados = $stmtRel->fetchAll();
}

$tituloPagina = $producto['nombre_prdct'];
require __DIR__ . '/includes/header.php';

$precioFinal = $oferta ? round($producto['precio_venta'] * (1 - $oferta / 100), 2) : (float) $producto['precio_venta'];
?>

<div class="breadcrumb">
    <a href="index.php">Catalogo</a> ›
    <?php if ($producto['nmbr_categoria']): ?>
        <a href="index.php?categoria[]=<?= (int) $producto['id_categoria'] ?>"><?= s($producto['nmbr_categoria']) ?></a> ›
    <?php endif; ?>
    <?= s($producto['nombre_prdct']) ?>
</div>

<div class="detalle-producto">
    <div class="imagen-grande">
        <img src="<?= s(url_imagen_producto($producto['imagen'])) ?>" alt="<?= s($producto['nombre_prdct']) ?>">
    </div>
    <div>
        <span class="categoria-tag"><?= s($producto['nmbr_categoria'] ?? 'General') ?><?= $producto['nombre_marca'] ? ' · ' . s($producto['nombre_marca']) : '' ?></span>
        <h1><?= s($producto['nombre_prdct']) ?></h1>

        <?php if ($promedioResenas !== null): ?>
            <div class="estrellas">
                <?= str_repeat('★', round($promedioResenas)) . str_repeat('☆', 5 - round($promedioResenas)) ?>
                <?= $promedioResenas ?>/5 (<?= count($resenas) ?> reseña<?= count($resenas) === 1 ? '' : 's' ?>)
            </div>
        <?php endif; ?>

        <?php if ($oferta): ?>
            <div class="precio-grande">
                <?= precio($precioFinal) ?>
                <span style="font-size:16px; color:#a3262c; text-decoration:line-through; font-weight:400;"><?= precio((float) $producto['precio_venta']) ?></span>
                <span class="pill pill-pendiente">-<?= (int) $oferta ?>%</span>
            </div>
        <?php else: ?>
            <div class="precio-grande"><?= precio((float) $producto['precio_venta']) ?></div>
        <?php endif; ?>

        <p><?= s($producto['descripcion']) ?></p>

        <?php if ($producto['stock_actual'] <= 0): ?>
            <p class="agotado" style="font-size:14px;">Este producto no tiene stock disponible por ahora.</p>
        <?php else: ?>
            <?php if ($producto['stock_actual'] <= 10): ?>
                <p class="stock-bajo" style="font-size:13px;">¡Solo quedan <?= (int) $producto['stock_actual'] ?> unidades!</p>
            <?php endif; ?>
            <form class="form-agregar-carrito" method="post" action="carrito_accion.php">
                <input type="hidden" name="accion" value="agregar">
                <input type="hidden" name="id_producto" value="<?= (int) $producto['id_producto'] ?>">
                <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
                <div class="selector-cantidad">
                    <button type="button" data-paso="-1" data-objetivo="#cantidad-input">−</button>
                    <input type="number" id="cantidad-input" name="cantidad" value="1" min="1" max="<?= (int) $producto['stock_actual'] ?>">
                    <button type="button" data-paso="1" data-objetivo="#cantidad-input">+</button>
                </div>
                <button type="submit" class="btn btn-naranja" style="padding:12px 26px; font-size:15px;">🛒 Agregar al carrito</button>
            </form>
        <?php endif; ?>

        <?php if (!empty($atributos)): ?>
        <div class="ficha-atributos">
            <table>
                <?php foreach ($atributos as $clave => $valor): ?>
                    <?php if (is_array($valor)) { $valor = implode(', ', array_map(fn($v) => is_array($v) ? json_encode($v) : $v, $valor)); } ?>
                    <?php if (is_bool($valor)) { $valor = $valor ? 'Si' : 'No'; } ?>
                    <tr>
                        <td><?= s(ucfirst(str_replace('_', ' ', (string) $clave))) ?></td>
                        <td><?= s((string) $valor) ?></td>
                    </tr>
                <?php endforeach; ?>
            </table>
        </div>
        <?php endif; ?>
    </div>
</div>

<div class="tarjeta-form ancha" id="resenas" style="margin-top:0;">
    <h2>Reseñas de clientes</h2>

    <?php if (esta_logueado()): ?>
        <form method="post" action="producto.php?id=<?= (int) $idProducto ?>#resenas" class="form-resena" style="margin-bottom:24px;">
            <input type="hidden" name="accion" value="resena">
            <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
            <div class="campo">
                <label>Tu calificacion</label>
                <select name="puntuacion">
                    <option value="5">★★★★★ Excelente</option>
                    <option value="4">★★★★☆ Muy bueno</option>
                    <option value="3">★★★☆☆ Regular</option>
                    <option value="2">★★☆☆☆ Malo</option>
                    <option value="1">★☆☆☆☆ Muy malo</option>
                </select>
            </div>
            <div class="campo">
                <label>Comentario</label>
                <textarea name="comentario" placeholder="¿Que te parecio este producto?" required></textarea>
            </div>
            <button type="submit" class="btn btn-verde">Publicar reseña</button>
        </form>
    <?php else: ?>
        <p class="ayuda-form" style="margin-bottom:20px;"><a href="login.php">Inicia sesion</a> para dejar tu reseña.</p>
    <?php endif; ?>

    <div class="resenas">
        <?php if (empty($resenas)): ?>
            <p style="color:#8a8a8a;">Aun no hay reseñas para este producto. ¡Se el primero en opinar!</p>
        <?php endif; ?>
        <?php foreach ($resenas as $r): ?>
            <div class="resena">
                <div class="estrellas"><?= str_repeat('★', (int) $r['puntuacion']) . str_repeat('☆', 5 - (int) $r['puntuacion']) ?></div>
                <p style="margin:6px 0 0;"><?= nl2br(s($r['comentario'])) ?></p>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<?php if (!empty($relacionados)): ?>
<h3 style="margin-top:36px;">Tambien te puede interesar</h3>
<div class="rejilla-productos" style="margin-bottom:40px;">
    <?php foreach ($relacionados as $rp): ?>
        <div class="tarjeta-producto">
            <a href="producto.php?id=<?= (int) $rp['id_producto'] ?>" class="miniatura">
                <img src="<?= s(url_imagen_producto($rp['imagen'])) ?>" alt="<?= s($rp['nombre_prdct']) ?>" loading="lazy">
            </a>
            <div class="cuerpo">
                <h4><a href="producto.php?id=<?= (int) $rp['id_producto'] ?>"><?= s($rp['nombre_prdct']) ?></a></h4>
                <div class="precio-fila"><span class="precio"><?= precio((float) $rp['precio_venta']) ?></span></div>
            </div>
        </div>
    <?php endforeach; ?>
</div>
<?php endif; ?>

<?php require __DIR__ . '/includes/footer.php'; ?>
