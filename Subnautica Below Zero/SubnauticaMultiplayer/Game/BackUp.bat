@echo off
setlocal EnableDelayedExpansion

:: ==========================================
:: НАСТРОЙКИ
:: ==========================================
set "SOURCE=C:\Users\TeMeR\AppData\Roaming\.botbenson\Subnautica Below Zero\Game\Saves"
set "BACKUP_ROOT=C:\Users\TeMeR\AppData\Roaming\.botbenson\Subnautica Below Zero\Game\Backup"
set "INTERVAL_SEC=120"
set "MAX_BACKUPS=100"
:: ==========================================

echo ========================================
echo  Бэкап сохранений Subnautica Below Zero
echo ========================================
echo Источник: %SOURCE%
echo Папка бэкапов: %BACKUP_ROOT%
echo Интервал: %INTERVAL_SEC% сек. (2 минуты)
echo Хранить бэкапов: %MAX_BACKUPS%
echo.
echo Для остановки закройте окно или нажмите Ctrl+C
echo ========================================
echo.

:: Создаём корневую папку, если её нет
if not exist "%BACKUP_ROOT%" mkdir "%BACKUP_ROOT%"

:LOOP
:: Формируем метку времени: ГГГГ-ММ-ДД_ЧЧ-ММ-СС
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "DATETIME=%%I"
set "TIMESTAMP=%DATETIME:~0,4%-%DATETIME:~4,2%-%DATETIME:~6,2%_%DATETIME:~8,2%-%DATETIME:~10,2%-%DATETIME:~12,2%"

set "BACKUP_DIR=%BACKUP_ROOT%\%TIMESTAMP%"

echo [%TIMESTAMP%] Создание бэкапа сохранений...
mkdir "%BACKUP_DIR%" 2>nul

:: Копируем папку Saves со всем содержимым
xcopy "%SOURCE%" "%BACKUP_DIR%\" /E /I /H /R /Y /C /D

if %errorlevel% equ 0 (
    echo [%TIMESTAMP%] Бэкап создан: %BACKUP_DIR%
    
    :: Очистка старых бэкапов (оставляем только последние %MAX_BACKUPS%)
    echo Очистка старых бэкапов...
    for /f "skip=%MAX_BACKUPS% delims=" %%D in ('dir "%BACKUP_ROOT%" /ad /b /o-n 2^>nul') do (
        rd /s /q "%BACKUP_ROOT%\%%D" 2>nul
        echo   Удалён старый бэкап: %%D
    )
) else (
    echo [%TIMESTAMP%] ОШИБКА при создании бэкапа!
    echo Проверьте, существует ли папка: %SOURCE%
)

:: Подсчёт количества бэкапов
set "COUNT=0"
for /f %%D in ('dir "%BACKUP_ROOT%" /ad /b 2^>nul') do set /a COUNT+=1
echo Всего бэкапов сейчас: %COUNT% (максимум %MAX_BACKUPS%)

echo ----------------------------------------
echo Ждём %INTERVAL_SEC% секунд до следующего бэкапа...
echo (Нажмите Ctrl+C для остановки)
echo.

:: Ждём 120 секунд
timeout /t %INTERVAL_SEC% /nobreak >nul

goto LOOP