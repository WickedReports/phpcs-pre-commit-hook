<?php

namespace App;

class Installer
{
    public static function postInstall()
    {
        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
            system('cmd /c vendor\wickedreports\phpcs-pre-commit-hook\src\setup.bat');
        }
        else {
            system('sh vendor/wickedreports/phpcs-pre-commit-hook/src/setup.sh');
        }
    }
}