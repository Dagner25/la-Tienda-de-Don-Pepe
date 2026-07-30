<?php
require __DIR__ . '/config/conexion.php';
require __DIR__ . '/includes/funciones.php';

if (esta_logueado()) {
    header('Location: index.php');
    exit;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!csrf_valido($_POST['csrf'] ?? null)) {
        $error = 'Tu sesion expiro, intenta nuevamente.';
    } else {
        $identificador = trim($_POST['identificador'] ?? '');
        $password = $_POST['password'] ?? '';

        if ($identificador === '' || $password === '') {
            $error = 'Completa tu DNI o correo y tu contraseña.';
        } else {
            $stmt = $pdo->prepare(
                'SELECT id_dni, nombres, apellido_p, correo, password_hash, rol, activo
                 FROM cliente WHERE id_dni = ? OR correo = ? LIMIT 1'
            );
            $stmt->execute([$identificador, $identificador]);
            $cliente = $stmt->fetch();

            if (!$cliente || !$cliente['password_hash'] || !password_verify($password, $cliente['password_hash'])) {
                $error = 'Credenciales incorrectas. Verifica tu DNI/correo y contraseña.';
            } elseif ((int) $cliente['activo'] !== 1) {
                $error = 'Tu cuenta esta inactiva. Comunicate con la tienda.';
            } else {
                $_SESSION['usuario'] = [
                    'id_dni'   => $cliente['id_dni'],
                    'nombres'  => $cliente['nombres'],
                    'apellido' => $cliente['apellido_p'],
                    'correo'   => $cliente['correo'],
                    'rol'      => $cliente['rol'],
                ];
                session_regenerate_id(true);

                $destino = $_SESSION['redirigir_despues_login'] ?? ($cliente['rol'] === 'admin' ? 'admin/index.php' : 'index.php');
                unset($_SESSION['redirigir_despues_login']);
                flash('exito', 'Bienvenido de nuevo, ' . $cliente['nombres'] . '.');
                header('Location: ' . $destino);
                exit;
            }
        }
    }
}

$tituloPagina = 'Ingresar - La Tiendita de Don Pepe';
require __DIR__ . '/includes/header.php';
?>

<div class="tarjeta-form">
    <h2>Ingresa a tu cuenta</h2>

    <?php if ($error): ?>
        <div class="alerta alerta-error"><?= s($error) ?></div>
    <?php endif; ?>

    <form method="post" action="login.php">
        <input type="hidden" name="csrf" value="<?= s(token_csrf()) ?>">
        <div class="campo">
            <label>DNI o correo electronico</label>
            <input type="text" name="identificador" value="<?= s($_POST['identificador'] ?? '') ?>" required autofocus>
        </div>
        <div class="campo">
            <label>Contraseña</label>
            <input type="password" name="password" required>
        </div>
        <button type="submit" class="btn btn-naranja btn-bloque">Ingresar</button>
    </form>

    <p class="ayuda-form">¿Aun no tienes cuenta? <a href="registro.php">Registrate aqui</a></p>

    <div class="demo-cuentas">
        <strong>Cuentas de prueba</strong> (contraseña: <code>123456</code>)<br>
        Cliente: DNI <code>12345678</code> · Admin: DNI <code>00000000</code>
    </div>
</div>

<?php require __DIR__ . '/includes/footer.php'; ?>
