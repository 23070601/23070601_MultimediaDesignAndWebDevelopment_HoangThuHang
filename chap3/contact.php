<?php
$errors = [];
$success = false;

$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$phone = trim($_POST['phone'] ?? '');
$message = trim($_POST['message'] ?? '');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (empty($name)) {
        $errors['name'] = 'Please enter your full name.';
    } elseif (strlen($name) < 2) {
        $errors['name'] = 'Name must be at least 2 characters.';
    }

    if (empty($email)) {
        $errors['email'] = 'Please enter your email.';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors['email'] = 'Please enter a valid email address.';
    }

    if (empty($phone)) {
        $errors['phone'] = 'Please enter your phone number.';
    } elseif (!preg_match('/^[0-9\s\-\+()]{8,15}$/', $phone)) {
        $errors['phone'] = 'Phone number is invalid.';
    }

    if (empty($message)) {
        $errors['message'] = 'Please enter your message.';
    } elseif (strlen($message) < 10) {
        $errors['message'] = 'Message must be at least 10 characters.';
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
    <title>Contact Form</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Contact Form</h1>

        <?php if ($success): ?>
            <div class="success-message">
                ✅ Your message has been sent successfully!
            </div>
        <?php endif; ?>

        <form method="POST" action="contact.php" novalidate>
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
                <label for="phone">Phone Number *</label>
                <input type="text" id="phone" name="phone" value="<?= htmlspecialchars($phone) ?>" class="<?= isset($errors['phone']) ? 'error' : '' ?>">
                <?php if (isset($errors['phone'])): ?>
                    <div class="error-message"><?= htmlspecialchars($errors['phone']) ?></div>
                <?php endif; ?>
            </div>

            <div class="form-group">
                <label for="message">Message *</label>
                <textarea id="message" name="message" rows="5" class="<?= isset($errors['message']) ? 'error' : '' ?>"><?= htmlspecialchars($message) ?></textarea>
                <?php if (isset($errors['message'])): ?>
                    <div class="error-message"><?= htmlspecialchars($errors['message']) ?></div>
                <?php endif; ?>
            </div>

            <button type="submit">Send Message</button>
        </form>
    </div>
</body>
</html>
