<?php

declare(strict_types=1);

/*
|--------------------------------------------------------------------------
| Project root
|--------------------------------------------------------------------------
| Every include/require path in this project is anchored on ROOT_DIR, so the
| pages keep working no matter how deep they live inside exercises/.
*/
define('ROOT_DIR', __DIR__);

/*
|--------------------------------------------------------------------------
| Student + course metadata (single source of truth)
|--------------------------------------------------------------------------
| Edit once here, every page and the footer pick it up automatically.
| TODO: STUDENT_NAME still needs your FULL legal name as written on the roster.
*/
define('STUDENT_NAME', 'Hằng');      // <-- TODO: doi thanh ho ten day du
define('STUDENT_ID', '23070601');
define('COURSE_CODE', 'INS3064');
define('COURSE_TITLE', 'Web Development');

/*
|--------------------------------------------------------------------------
| Exercise registry
|--------------------------------------------------------------------------
| Drives BOTH the dashboard on index.php and the navigation bar in the header.
| Adding an exercise = copy exercises/_template, then add one entry below.
*/
define('EXERCISES', [
    [
        'slug'  => 'exercise-01',
        'title' => 'Hello World',
        'topic' => 'PHP co ban: echo, xau ky tu, lenh xuong dong',
    ],
    [
        'slug'  => 'exercise-02',
        'title' => 'Student Profile',
        'topic' => 'Bien PHP, chen PHP vao HTML, superglobal $_SERVER',
    ],
]);
