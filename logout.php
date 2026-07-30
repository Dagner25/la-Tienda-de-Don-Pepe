<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

$buscar = trim($_GET['buscar'] ?? '');
$categoriasSel = array_filter(array_map('intval', $_GET['categoria'] ?? []));
$marcasSel = array_filter(array_map('intval', $_GET['marca'] ?? []));
$precioMin = isset($_GET['precio_min']) && $_GET['precio_min'] !== '' ? (float) $_GET['precio_min'] : null;
$precioMax = isset($_GET['precio_max']) && $_GET['precio_max'] !== '' ? (float) $_GET['precio_max'] : null;
$soloOfertas = isset($_GET['ofertas']);
$orden = $_GET['orden'] ?? 'relevancia';
$pagina = max(1, (int) ($_GET['pagina'] ?? 1));
$porPagina = 12;

$ordenesValidos = [
    'relevancia' => 'p.id_producto DESC',
    'precio_asc' => 'p.precio_venta ASC',
    'precio_desc' => 'p.precio_venta DESC',
    'nombre_az' => 'p.nombre_prdct ASC',
];
$ordenSql = $ordenesValidos[$orden] ?? $ordenesValidos['relevancia'];

$condiciones = [];
$parametros = [];

if ($buscar !== '') {
    $condiciones[] = '(p.nombre_prdct LIKE ? OR p.descripcion LIKE ?)';
    $parametros[] = "%$buscar%";
    $parametros[] = "%$buscar%";
}

if (!empty($categoriasSel)) {
    $condiciones[] = 'p.id_categoria IN (' . implode(',', array_fill(0, count($categoriasSel), '?')) . ')';
    array_push($parametros, ...$categoriasSel);
}

if (!empty($marcasSel)) {
    $condiciones[] = 'p.id_marca IN (' . implode(',', array_fill(0, count($marcasSel), '?')) . ')';
    array_push($parametros, ...$marcasSel);
}

if ($precioMin !== null) {
    $condiciones[] = 'p.precio_venta >= ?';
    $parametros[] = $precioMin;
}

if ($precioMax !== null) {
    $condiciones[] = 'p.precio_venta <= ?';
    $parametros[] = $precioMax;
}

if ($soloOfertas) {
    $condiciones[] = 'p.id_producto IN (
        SELECT pp.id_producto FROM producto_promocion pp
        INNER JOIN promocion pr ON pr.id_promocion = pp.id_promocion
        WHERE CURDATE() BETWEEN pr.fch_inicio AND pr.fch_fin
    )';
}

$whereSql = $condiciones ? ('WHERE ' . implode(' AND ', $condiciones)) : '';

/* ==========================================================
   CONTEO TOTAL PARA PAGINACION
   ========================================================== */
$stmtConteo = $pdo->prepare("SELECT COUNT(*) FROM producto p $whereSql");
$stmtConteo->execute($parametros);
$totalResultados = (int) $stmtConteo->fetchColumn();
$totalPaginas = max(1, (int) ceil($totalResultados / $porPagina));
$pagina = min($pagina, $totalPaginas);
$offset = ($pagina - 1) * $porPagina;

/* ==========================================================
   CONSULTA PRINCIPAL DE PRODUCTOS
   ========================================================== */
$sql = "SELECT p.id_producto, p.nombre_prdct, p.descripcion, p.precio_venta, p.stock_actual,
               p.imagen, c.nmbr_categoria, m.nombre_marca,
               EXISTS (
                   SELECT 1 FROM producto_promocion pp
                   INNER JOIN promocion pr ON pr.id_promocion = pp.id_promocion
                   WHERE pp.id_producto = p.id_producto
                     AND CURDATE() BETWEEN pr.fch_inicio AND pr.fch_fin
               ) AS en_oferta
        FROM producto p
        LEFT JOIN categoria c ON c.id_categoria = p.id_categoria
        LEFT JOIN marca m ON m.id_marca = p.id_marca
        $whereSql
        ORDER BY $ordenSql
        LIMIT $porPagina OFFSET $offset";

$stmt = $pdo->prepare($sql);
$stmt->execute($parametros);
$productos = $stmt->fetchAll();

$categorias = obtener_categorias($pdo);
$marcas = obtener_marcas($pdo);

$tituloPagina = $buscar !== '' ? "Resultados para \"$buscar\"" : 'La Tiendita de Don Pepe - Catalogo';
require __DIR__ . '/includes/header.php';

/** Reconstruye la query string manteniendo los filtros actuales, salvo los indicados. */
function construir_url(array $sobrescribir = []): string
{
    $params = array_merge($_GET, $sobrescribir);
    foreach ($sobrescribir as $clave => $valor) {
        if ($valor === null) {
            unset($params[$clave]);
        }
    }
    return 'index.php?' . http_build_query($params);
}
?>

<?php if ($buscar === '' && empty($categoriasSel) && empty($marcasSel)): ?>
<div class="hero" style="margin: 0 -20px 26px; border-radius: 0 0 16px 16px;">
    <div class="contenedor">
        <h1>Todo para tu casa, fresco y al mejor precio 🥬</h1>
        <p>Abarrotes, lacteos, bebidas, limpieza e higiene con entrega rapida.</p>
    </div>
</div>
<?php endif; ?>

<div class="layout-catalogo">
    <aside class="panel-filtros">
        <form method="get" action="index.php">
            <?php if ($buscar !== ''): ?>
                <input type="hidden" name="buscar" value="<?= s($buscar) ?>">
            <?php endif; ?>

            <h3>Categorias</h3>
            <?php foreach ($categorias as $cat): ?>
                <label>
                    <input type="checkbox" name="categoria[]" value="<?= (int) $cat['id_categoria'] ?>"
                        <?= in_array((int) $cat['id_categoria'], $categoriasSel, true) ? 'checked' : '' ?>>
                    <?= s($cat['nmbr_categoria']) ?>
                </label>
            <?php endforeach; ?>

            <h3>Marcas</h3>
            <?php foreach ($marcas as $marca): ?>
                <label>
                    <input type="checkbox" name="marca[]" value="<?= (int) $marca['id_marca'] ?>"
                        <?= in_array((int) $marca['id_marca'], $marcasSel, true) ? 'checked' : '' ?>>
                    <?= s($marca['nombre_marca']) ?>
                </label>
            <?php endforeach; ?>

            <h3>Precio (S/)</h3>
            <div class="fila-precio">
                <input type="number" name="precio_min" placeholder="Min" min="0" step="0.10" value="<?= s($_GET['precio_min'] ?? '') ?>">
                <span>-</span>
                <input type="number" name="precio_max" placeholder="Max" min="0" step="0.10" value="<?= s($_GET['precio_max'] ?? '') ?>">
            </div>

            <h3>Otros</h3>
            <label>
                <input type="checkbox" name="ofertas" value="1" <?= $soloOfertas ? 'checked' : '' ?>>
                Solo ofertas activas 🔥
            </label>

            <button type="submit" class="btn-filtrar">Aplicar filtros</button>
            <a href="index.php" class="link-limpiar">Limpiar filtros</a>
        </form>
    </aside>

    <section>
        <div class="barra-resultados">
            <strong><?= $totalResultados ?> producto<?= $totalResultados === 1 ? '' : 's' ?> encontrado<?= $totalResultados === 1 ? '' : 's' ?></strong>
            <form method="get" action="index.php" id="form-orden">
                <?php foreach ($_GET as $clave => $valor) : if ($clave === 'orden') continue; ?>
                    <?php if (is_array($valor)): foreach ($valor as $v): ?>
                        <input type="hidden" name="<?= s($clave) ?>[]" value="<?= s($v) ?>">
                    <?php endforeach; else: ?>
                        <input type="hidden" name="<?= s($clave) ?>" value="<?= s($valor) ?>">
                    <?php endif; endforeach; ?>
                <select name="orden" onchange="document.getElementById('form-orden').submit()">
                    <option value="relevancia" <?= $orden === 'relevancia' ? 'selected' : '' ?>>Relevancia</option>
                    <option value="precio_asc" <?= $orden === 'precio_asc' ? 'selected' : '' ?>>Precio: menor a mayor</option>
                    <option value="precio_desc" <?= $orden === 'precio_desc' ? 'selected' : '' ?>>Precio: mayor a menor</option>
                    <option value="nombre_az" <?= $orden === 'nombre_az' ? 'selected' : '' ?>>Nombre: A - Z</option>
                </select>
            </form>
        </div>

        <?php if (empty($productos)): ?>
            <div class="vacio-lista">
                <p>No encontramos productos con esos filtros.</p>
                <a href="index.php" class="btn btn-verde">Ver todo el catalogo</a>
            </div>
        <?php else: ?>
            <div class="rejilla-productos">
                <?php foreach ($productos as $p): ?>
                    <div class="tarjeta-producto">
                        <a href="producto.php?id=<?= (int) $p['id_producto'] ?>" class="miniatura">
                            <img src="<?= s(url_imagen_producto($p['imagen'])) ?>" alt="<?= s($p['nombre_prdct']) ?>" loading="lazy">
                        </a>
                        <div class="cuerpo">
                            <span class="categoria-tag"><?= s($p['nmbr_categoria'] ?? 'General') ?><?= $p['en_oferta'] ? ' · 🔥 Oferta' : '' ?></span>
                            <h4><a href="producto.php?id=<?= (int) $p['id_producto'] ?>"><?= s($p['nombre_prdct']) ?></a></h4>
                            <div class="desc"><?= s($p['descripcion']) ?></div>
                            <div class="precio-fila">
                                <span class="precio"><?= precio((float) $p['precio_venta']) ?></span>
                                <?php if ($p['stock_actual'] <= 0): ?>
                                    <span class="agotado">Agotado</span>
                                <?php elseif ($p['stock_actual'] <= 10): ?>
                                    <span class="stock-bajo">Quedan <?= (int) $p['stock_actual'] ?></span>
                                <?php endif; ?>
                            </div>
                            <form class="form-agregar-carrito" method="post" action="carrito_accion.php">
                                <input type="hidden" name="accion" value="agregar">
                                <input type="hidden" name="id_producto" value="<?= (int) $p['id_producto'] ?>">
                                <input type="hidden" name="cantidad" value="1">
                                <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
                                <button type="submit" class="btn btn-naranja btn-agregar" <?= $p['stock_actual'] <= 0 ? 'disabled' : '' ?>>
                                    <?= $p['stock_actual'] <= 0 ? 'Sin stock' : '🛒 Agregar' ?>
                                </button>
                            </form>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>

            <?php if ($totalPaginas > 1): ?>
                <div class="paginacion">
                    <?php if ($pagina > 1): ?><a href="<?= s(construir_url(['pagina' => $pagina - 1])) ?>">&laquo; Anterior</a><?php endif; ?>
                    <?php for ($i = 1; $i <= $totalPaginas; $i++): ?>
                        <?php if ($i === $pagina): ?>
                            <span class="activa"><?= $i ?></span>
                        <?php else: ?>
                            <a href="<?= s(construir_url(['pagina' => $i])) ?>"><?= $i ?></a>
                        <?php endif; ?>
                    <?php endfor; ?>
                    <?php if ($pagina < $totalPaginas): ?><a href="<?= s(construir_url(['pagina' => $pagina + 1])) ?>">Siguiente &raquo;</a><?php endif; ?>
                </div>
            <?php endif; ?>
        <?php endif; ?>
    </section>
</div>

<?php require __DIR__ . '/includes/footer.php'; ?>
