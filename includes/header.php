<?php

/**
 * Shared top-of-page layout.
 *
 * Set before including:
 *   $page_title  (string) text shown in <title> and the page <h1>
 *   $active_slug (string) exercise slug to highlight in the nav, '' for the home page
 */
$page_title  = $page_title ?? COURSE_CODE . ' Homework';
$active_slug = $active_slug ?? '';
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="<?= e(COURSE_CODE) ?> Web Development homework — <?= e(STUDENT_NAME) ?>">
    <title><?= e($page_title) ?> · <?= e(COURSE_CODE) ?></title>
    <link rel="stylesheet" href="<?= e(url('assets/css/style.css')) ?>">
    <script src="<?= e(url('assets/js/main.js')) ?>" defer></script>
</head>
<body>

<header class="site-header">
    <div class="wrap site-header__inner">
        <a class="brand" href="<?= e(url('index.php')) ?>">
            <span class="brand__code"><?= e(COURSE_CODE) ?></span>
            <span class="brand__label">Web Dev · Homework</span>
        </a>

        <button class="nav-toggle" type="button" aria-expanded="false" aria-controls="primary-nav">
            <span class="nav-toggle__bars" aria-hidden="true"></span>
            <span class="nav-toggle__text">Menu</span>
        </button>

        <nav id="primary-nav" class="primary-nav">
            <a class="primary-nav__link<?= $active_slug === '' ? ' is-active' : '' ?>"
               href="<?= e(url('index.php')) ?>">Tổng quan</a>
            <?php foreach (EXERCISES as $index => $exercise): ?>
                <a class="primary-nav__link<?= $active_slug === $exercise['slug'] ? ' is-active' : '' ?>"
                   href="<?= e(url('exercises/' . $exercise['slug'] . '/index.php')) ?>">
                    <span class="primary-nav__num"><?= e(str_pad((string) ($index + 1), 2, '0', STR_PAD_LEFT)) ?></span>
                    <?= e($exercise['title']) ?>
                </a>
            <?php endforeach; ?>
        </nav>
    </div>
</header>

<main class="site-main">
    <div class="wrap">
