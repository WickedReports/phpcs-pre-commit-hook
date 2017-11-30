### SETTINGS ###

# Path to the php.exe
$php_exe = "php";

# Path to the phpcs
$php_cs = "vendor\bin\phpcs.bat";

# Extensions of the PHP files
$php_ext = "php|phtml"

# Flag, if set to $true git will unstage all files with errors, set to $false to disable
$unstage_on_error = $false;

### FUNCTIONS ###


## PHP Lint
function php_syntax_check {
    param([string]$php_bin, [string]$extensions, [bool]$reset)

    $err_counter = 0;
    $file_counter = 0;

    write-host "PHP syntax check:" -foregroundcolor "white" -backgroundcolor "black"

    # loop through all commited files
    git diff-index --name-only --cached --diff-filter=AM HEAD -- | foreach {
        write-host $file
        # only match php files
        if ($_ -match ".*\.($extensions)$") {
            $file_counter++;
            $file = $matches[0];
            $errors = & $php_bin -l $file

            write-host $file ": "  -foregroundcolor "gray"  -backgroundcolor "black" -NoNewline
            if ($errors -match "No syntax errors detected in $file") {
                write-host "OK!" -foregroundcolor "green" -backgroundcolor "black"
            } else {
                write-host "ERROR! " $errors -foregroundcolor "red" -backgroundcolor "black"
                if ($reset) {
                    git reset -q HEAD $file
                    write-host "Unstaging ..." -foregroundcolor "magenta" -backgroundcolor "black"
                }
                $err_counter++
            }
        }
    }

    # output report
    write-host "Checked" $file_counter "File(s)" -foregroundcolor "gray" -backgroundcolor "black"
    if ($err_counter -gt 0) {
        write-host "Some File(s) have syntax errors. Please fix then commit" -foregroundcolor "red" -backgroundcolor "black"
        exit 1
    }
}

# PHP Code Sniffer Check
function php_cs_check {
    param([string]$php_cs, [string]$extensions, [bool]$reset)

    $err_counter = 0;
    $file_counter = 0;

    write-host "PHP codesniffer check:" -foregroundcolor "white" -backgroundcolor "black"

    # Loop through all commited files
    git diff-index --name-only --cached --diff-filter=AM HEAD -- | foreach {
        # only run lint if file extensions match
        if ($_ -match ".*\.($extensions)$") {
            $file_counter++;
            $file = $matches[0];

            write-host $file ": "  -foregroundcolor "gray"  -backgroundcolor "black" -NoNewline

            # skip test files
            if ($file -match "test\/") {
                write-host "SKIPPED! (test file)" -foregroundcolor "darkGreen" -backgroundcolor "black"
            } else {
                $errors = & $php_cs --standard=PSR2 -n --colors --report-width=120 $file

                # Outputs the error
                if ($LastExitCode) {
                    write-host "FAILED! (contains errors)"  -foregroundcolor "red" -backgroundcolor "black"
                    write-host
                    write-output $errors
                    write-host
                    write-host "Run"
                    write-host -foregroundcolor "green" ".\vendor\bin\phpcbf.bat --standard=PSR2 $file"
                    write-host "for automatic fix or fix it manually."
                    write-host

                    if ($reset) {
                        git reset -q HEAD $file
                        write-host "Unstaging ..." -foregroundcolor "magenta" -backgroundcolor "black"
                    }
                    $err_counter++
                } else {
                    write-host "PASSED!" -foregroundcolor "green" -backgroundcolor "black"
                }
            }
        }
    }

    # output report
    write-host "Checked" $file_counter "File(s)" -foregroundcolor "gray" -backgroundcolor "black"
    if ($err_counter -gt 0) {
        write-host "Some File(s) are not following proper codeing standards. Please fix then commit" -foregroundcolor "red" -backgroundcolor "black"
        exit 1
    }
}

### MAIN ###
php_syntax_check $php_exe "php|phtml" $unstage_on_error
write-host

php_cs_check $php_cs "php" $unstage_on_error
write-host