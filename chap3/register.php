<?php
$errors = [];
$success = false;

$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';
$confirmPassword = $_POST['confirm_password'] ?? '';
$agree = isset($_POST['agree']);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (empty($name)) {
        $errors['name'] = 'Please enter full name';
    } elseif (strlen($name) < 2) {
        $errors['name'] = 'Name must be at least 2 characters';
    }

    if (empty($email)) {
        $errors['email'] = 'Please enter email';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors['email'] = 'Invalid email format';
    }

    if (empty($password)) {
        $errors['password'] = 'Please enter password';
    } elseif (strlen($password) < 6) {
        $errors['password'] = 'Password must be at least 6 characters';
    }

    if ($password !== $confirmPassword) {
        $errors['confirm_password'] = 'Passwords do not match';
    }

    if (!$agree) {
        $errors['agree'] = 'You must agree to terms';
    }

    if (empty($errors)) {
        $success = true;
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register Account</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>📝 Register Account</h1>

        <?php if ($success): ?>
            <div class="success-message">
                🎉 Registration successful! Welcome <?= htmlspecialchars($name) ?>
            </div>
            <p><a href="index.html">Back to register form</a></p>
        <?php else: ?>
            <form method="POST" action="register.php">
                <div class="form-group">
                    <label for="name">Full Name *</label>
                    <input type="text" id="name" name="name" value="<?= htmlspecialchars($name) ?>" class="<?= isset($errors['name']) ? 'error' : '' ?>">
                    <?php if (isset($errors['name'])): ?>
                        <div class="error-message"><?= htmlspecialchars($errors['name']) ?></div>
                    <?php endif; ?>
                </div>

                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" value="<?= htmlspecialchars($email) ?>" class="<?= isset($errors['email']) ? 'error' : '' ?>">
                    <?php if (isset($errors['email'])): ?>
                        <div class="error-message"><?= htmlspecialchars($errors['email']) ?></div>
                    <?php endif; ?>
                </div>

                <div class="form-group">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" class="<?= isset($errors['password']) ? 'error' : '' ?>">
                    <?php if (isset($errors['password'])): ?>
                        <div class="error-message"><?= htmlspecialchars($errors['password']) ?></div>
                    <?php endif; ?>
                </div>

                <div class="form-group">
                    <label for="confirm_password">Confirm Password *</label>
                    <input type="password" id="confirm_password" name="confirm_password" class="<?= isset($errors['confirm_password']) ? 'error' : '' ?>">
                    <?php if (isset($errors['confirm_password'])): ?>
                        <div class="error-message"><?= htmlspecialchars($errors['confirm_password']) ?></div>
                    <?php endif; ?>
                </div>

                <div class="form-group checkbox-group">
                    <input type="checkbox" name="agree" id="agree" <?= $agree ? 'checked' : '' ?>>
                    <label for="agree" style="font-weight: normal;">
                        I agree to terms of service
                    </label>
                </div>
                <?php if (isset($errors['agree'])): ?>
                    <div class="error-message"><?= htmlspecialchars($errors['agree']) ?></div>
                <?php endif; ?>

                <button type="submit">Register</button>
            </form>
        <?php endif; ?>
    </div>
</body>
</html>