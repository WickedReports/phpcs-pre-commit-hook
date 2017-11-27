@echo off

if exist .git/hooks/pre-commit (
    rem file exists
) else (
    rem file doesn't exist
)

#xcopy /s vendor/smgladkovskiy/phpcs-git-pre-commit/src/pre-commit.win .git/hooks/pre-commit
#xcopy /s vendor/smgladkovskiy/phpcs-git-pre-commit/src/pre-commit.ps1 .git/hooks/pre-commit.ps1
