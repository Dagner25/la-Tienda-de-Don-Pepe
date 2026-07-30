<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

if (esta_logueado()) {
    header('Location: index.php');
    exit;
}

$errores = [];
$datos = [
    'id_dni' => '', 'nombres' => '', 'apellido_p' => '', 'apellido_m' => '',
    'region' => 'Arequipa', 'direccion' => '', 'provincia' => '', 'distrito' => '',
    'fch_nacimiento' => '', 'telefono' => '', 'correo' => '',
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!csrf_valido($_POST['csrf'] ?? null)) {
        $errores[] = 'Tu sesion expiro, recarga la pagina e intenta nuevamente.';
    }

    foreach ($datos as $campo => $valorPorDefecto) {
        $datos[$campo] = trim($_POST[$campo] ?? '');
    }
    $password = $_POST['password'] ?? '';
    $password2 = $_POST['password2'] ?? '';

    if (!preg_match('/^\d{8}$/', $datos['id_dni'])) {
        $errores[] = 'El DNI debe tener exactamente 8 digitos.';
    }
    if ($datos['nombres'] === '' || $datos['apellido_p'] === '') {
        $errores[] = 'Ingresa tus nombres y apellido paterno.';
    }
    if ($datos['direccion'] === '' || $datos['provincia'] === '' || $datos['distrito'] === '') {
        $errores[] = 'Completa direccion, provincia y distrito para poder enviarte tus pedidos.';
    }
    if (!preg_match('/^\d{6,9}$/', $datos['telefono'])) {
        $errores[] = 'Ingresa un telefono valido (solo numeros).';
    }
    if (!filter_var($datos['correo'], FILTER_VALIDATE_EMAIL)) {
        $errores[] = 'Ingresa un correo electronico valido.';
    }
    if (strlen($password) < 6) {
        $errores[] = 'La contraseña debe tener al menos 6 caracteres.';
    }
    if ($password !== $password2) {
        $errores[] = 'Las contraseñas no coinciden.';
    }

    if (empty($errores)) {
        $stmt = $pdo->prepare('SELECT id_dni FROM cliente WHERE id_dni = ? OR correo = ? OR telefono = ?');
        $stmt->execute([$datos['id_dni'], $datos['correo'], $datos['telefono']]);
        if ($stmt->fetch()) {
            $errores[] = 'Ya existe una cuenta registrada con ese DNI, correo o telefono.';
        }
    }

    if (empty($errores)) {
        try {
            $pdo->beginTransaction();

            $ins = $pdo->prepare(
                'INSERT INTO cliente (id_dni, nombres, apellido_p, apellido_m, region, direccion, provincia, distrito, fch_nacimiento, telefono, correo, password_hash, rol)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "cliente")'
            );
            $ins->execute([
                $datos['id_dni'], $datos['nombres'], $datos['apellido_p'], $datos['apellido_m'] ?: null,
                $datos['region'] ?: 'Arequipa', $datos['direccion'], $datos['provincia'], $datos['distrito'],
                $datos['fch_nacimiento'] ?: null, $datos['telefono'], $datos['correo'],
                password_hash($password, PASSWORD_BCRYPT),
            ]);

            $insComun = $pdo->prepare('INSERT INTO cliente_comun (id_dni, lim_descuento_acumulado, tasa_descuento) VALUES (?, 0, 0)');
            $insComun->execute([$datos['id_dni']]);

            $pdo->commit();

            $_SESSION['usuario'] = [
                'id_dni'   => $datos['id_dni'],
                'nombres'  => $datos['nombres'],
                'apellido' => $datos['apellido_p'],
                'correo'   => $datos['correo'],
                'rol'      => 'cliente',
            ];
            session_regenerate_id(true);
            flash('exito', '¡Cuenta creada! Bienvenido a La Tiendita de Don Pepe.');
            header('Location: index.php');
            exit;
        } catch (Throwable $e) {
            $pdo->rollBack();
            $errores[] = 'No se pudo crear la cuenta. Intenta nuevamente.';
        }
    }
}

$tituloPagina = 'Crear cuenta - La Tiendita de Don Pepe';
require __DIR__ . '/includes/header.php';
?>

<div class="tarjeta-form ancha">
    <h2>Crea tu cuenta</h2>

    <?php foreach ($errores as $e): ?>
        <div class="alerta alerta-error"><?= s($e) ?></div>
    <?php endforeach; ?>

    <form method="post" action="registro.php">
        <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">

        <div class="fila-2">
            <div class="campo">
                <label>DNI (8 digitos)</label>
                <input type="text" name="id_dni" maxlength="8" value="<?= s($datos['id_dni']) ?>" required>
            </div>
            <div class="campo">
                <label>Telefono</label>
                <input type="text" name="telefono" maxlength="9" value="<?= s($datos['telefono']) ?>" required>
            </div>
        </div>

        <div class="fila-2">
            <div class="campo">
                <label>Nombres</label>
                <input type="text" name="nombres" value="<?= s($datos['nombres']) ?>" required>
            </div>
            <div class="campo">
                <label>Apellido paterno</label>
                <input type="text" name="apellido_p" value="<?= s($datos['apellido_p']) ?>" required>
            </div>
        </div>

        <div class="fila-2">
            <div class="campo">
                <label>Apellido materno</label>
                <input type="text" name="apellido_m" value="<?= s($datos['apellido_m']) ?>">
            </div>
            <div class="campo">
                <label>Fecha de nacimiento</label>
                <input type="date" name="fch_nacimiento" value="<?= s($datos['fch_nacimiento']) ?>">
            </div>
        </div>

        <div class="campo">
            <label>Correo electronico</label>
            <input type="email" name="correo" value="<?= s($datos['correo']) ?>" required>
        </div>

        <div class="campo">
            <label>Direccion de envio</label>
            <input type="text" name="direccion" value="<?= s($datos['direccion']) ?>" required>
        </div>

        <div class="fila-2">
            <div class="campo">
                <label>Region</label>
                <input type="text" name="region" value="<?= s($datos['region']) ?>">
            </div>
            <div class="campo">
                <label>Provincia</label>
                <input type="text" name="provincia" value="<?= s($datos['provincia']) ?>" required>
            </div>
        </div>

        <div class="campo">
            <label>Distrito</label>
            <input type="text" name="distrito" value="<?= s($datos['distrito']) ?>" required>
        </div>

        <div class="fila-2">
            <div class="campo">
                <label>Contraseña</label>
                <input type="password" name="password" required>
            </div>
            <div class="campo">
                <label>Confirmar contraseña</label>
                <input type="password" name="password2" required>
            </div>
        </div>

        <button type="submit" class="btn btn-naranja btn-bloque">Crear cuenta</button>
    </form>

    <p class="ayuda-form">¿Ya tienes cuenta? <a href="login.php">Inicia sesion</a></p>
</div>

<?php require __DIR__ . '/includes/footer.php'; ?>
