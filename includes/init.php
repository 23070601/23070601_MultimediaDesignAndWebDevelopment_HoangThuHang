<?php

declare(strict_types=1);

/*
|--------------------------------------------------------------------------
| Bootstrap
|--------------------------------------------------------------------------
| require this ONE file at the top of every page:
|
|   require_once dirname(__DIR__, 2) . '/includes/init.php';   // 2 levels deep
|
| It loads config.php and registers the tiny helper layer used by the views.
*/

require_once dirname(__DIR__) . '/config.php';

/**
 * HTML-escape a value. Use this for EVERYTHING that comes from a variable so
 * a stray "<" or a quote can never break the page or become an XSS hole.
 */
function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/**
 * URL path of the project root, e.g. "" when served from the document root or
 * "/homework" when the folder is dropped inside htdocs/. Cached per request.
 */
function app_base(): string
{
    static $base = null;

    if ($base !== null) {
        return $base;
    }

    $root      = realpath(ROOT_DIR) ?: ROOT_DIR;
    $scriptUrl = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '/index.php');
    $dir       = dirname($scriptUrl);

    // How many folders down from the project root is the script being run?
    $fileDir = realpath(dirname($_SERVER['SCRIPT_FILENAME'] ?? $scriptUrl)) ?: $root;
    $rel     = trim(str_replace($root, '', $fileDir), '/');
    $depth   = $rel === '' ? 0 : count(explode('/', $rel));

    // Strip that many segments off the URL directory to land on the root.
    for ($i = 0; $i < $depth && $dir !== '/' && $dir !== '.'; $i++) {
        $dir = dirname($dir);
    }

    $dir = rtrim($dir, '/');

    return $base = ($dir === '/' ? '' : $dir);
}

/**
 * Build an app-root-relative URL: url('assets/css/style.css').
 */
function url(string $path = ''): string
{
    return app_base() . '/' . ltrim($path, '/');
}

/**
 * Absolute filesystem path to a file inside the project: root_path('config.php').
 */
function root_path(string $path = ''): string
{
    return ROOT_DIR . ($path === '' ? '' : DIRECTORY_SEPARATOR . ltrim($path, '/'));
}
