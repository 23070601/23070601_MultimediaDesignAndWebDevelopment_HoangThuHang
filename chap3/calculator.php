<?php
$errors = [];
$result = null;
$operator = $_POST['operator'] ?? '+';
$num1 = $_POST['num1'] ?? '';
$num2 = $_POST['num2'] ?? '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!is_numeric($num1)) {
        $errors['num1'] = 'Please enter a valid number for Number 1.';
    }

    if (!is_numeric($num2)) {
        $errors['num2'] = 'Please enter a valid number for Number 2.';
    }

    if ($operator === '/' && (float)$num2 === 0.0) {
        $errors['operator'] = 'Cannot divide by zero.';
    }

    if (empty($errors)) {
        $n1 = (float) $num1;
        $n2 = (float) $num2;

        switch ($operator) {
            case '+':
                $result = $n1 + $n2;
                break;
            case '-':
                $result = $n1 - $n2;
                break;
            case '*':
                $result = $n1 * $n2;
                break;
            case '/':
                $result = $n1 / $n2;
                break;
            default:
                $errors['operator'] = 'Invalid operation selected.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calculator</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Calculator</h1>

        <form method="POST" action="calculator.php">
            <div class="form-group">
                <label for="num1">Number 1</label>
                <input type="number" id="num1" name="num1" step="any" value="<?= htmlspecialchars($num1) ?>" class="<?= isset($errors['num1']) ? 'error' : '' ?>">
                <?php if (isset($errors['num1'])): ?>
                    <div class="error-message"><?= htmlspecialchars($errors['num1']) ?></div>
                <?php endif; ?>
            </div>

            <div class="form-group">
                <label for="operator">Operation</label>
                <select id="operator" name="operator">
                    <option value="+" <?= $operator === '+' ? 'selected' : '' ?>>Addition (+)</option>
                    <option value="-" <?= $operator === '-' ? 'selected' : '' ?>>Subtraction (-)</option>
                    <option value="*" <?= $operator === '*' ? 'selected' : '' ?>>Multiplication (*)</option>
                    <option value="/" <?= $operator === '/' ? 'selected' : '' ?>>Division (/)</option>
                </select>
                <?php if (isset($errors['operator'])): ?>
                    <div class="error-message"><?= htmlspecialchars($errors['operator']) ?></div>
                <?php endif; ?>
            </div>

            <div class="form-group">
                <label for="num2">Number 2</label>
                <input type="number" id="num2" name="num2" step="any" value="<?= htmlspecialchars($num2) ?>" class="<?= isset($errors['num2']) ? 'error' : '' ?>">
                <?php if (isset($errors['num2'])): ?>
                    <div class="error-message"><?= htmlspecialchars($errors['num2']) ?></div>
                <?php endif; ?>
            </div>

            <button type="submit">Calculate</button>
        </form>

        <?php if ($result !== null): ?>
            <div class="success-message">
                Result: <?= htmlspecialchars((string) $result) ?>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>
