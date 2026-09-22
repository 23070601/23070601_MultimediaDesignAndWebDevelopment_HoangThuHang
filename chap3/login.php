<?php
session_start();

$attempts = $_SESSION['failed_login_attempts'] ?? 0;
$loginMessage = '';
$loginError = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if ($username === 'admin' && $password === '123456') {
        $_SESSION['failed_login_attempts'] = 0;
        $attempts = 0;
        $loginMessage = '✅ Login successful! Welcome, admin.';
        $loginError = false;
    } else {
        $attempts++;
        $_SESSION['failed_login_attempts'] = $attempts;
        $loginMessage = '❌ Login failed. Please check your username and password.';
        $loginError = true;
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Form</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Login Form</h1>

        <?php if ($loginMessage !== ''): ?>
            <div class="<?= $loginError ? 'error-message-box' : 'success-message' ?>">
                <?= htmlspecialchars($loginMessage) ?>
            </div>
        <?php endif; ?>

        <p>Failed login attempts: <strong><?= (int) $attempts ?></strong></p>

        <form method="POST" action="login.php">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" value="">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password">
            </div>

            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
