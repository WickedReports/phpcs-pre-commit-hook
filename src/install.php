<?php

if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    system('cmd /c vendor/wickedreports/phpcs-git-pre-commit/src/setup.bat');
}
else {
    system('sh vendor/wickedreports/phpcs-git-pre-commit/src/setup.sh');
}