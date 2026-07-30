<?php
require __DIR__ . '/includes/funciones.php';

$_SESSION = [];
session_destroy();
session_start();
flash('info', 'Cerraste sesion correctamente.');
header('Location: index.php');
exit;
