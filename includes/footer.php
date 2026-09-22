<?php
/**
 * Shared bottom-of-page layout. Closes <main> and the page started in header.php.
 */
?>
    </div>
</main>

<footer class="site-footer">
    <div class="wrap site-footer__inner">
        <p class="site-footer__who">
            <?= e(STUDENT_NAME) ?> · MSSV <?= e(STUDENT_ID) ?> · <?= e(COURSE_CODE) ?> <?= e(COURSE_TITLE) ?>
        </p>
        <p class="site-footer__meta">
            PHP <?= e(PHP_VERSION) ?> · &copy; <?= date('Y') ?> · trang render lúc <?= date('H:i:s') ?>
        </p>
    </div>
</footer>

</body>
</html>
