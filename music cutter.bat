@echo off
setlocal enabledelayedexpansion
color 0e
title Super Search Lossless Cutter

:: ==========================================
:: 1. PROTOKOL SMART CHECK FFMPEG (4 LAPIS)
:: ==========================================

:: Lapis 1: Folder yang sama dengan script
set "ffmpeg_path=%~dp0ffmpeg.exe"
if exist "!ffmpeg_path!" goto start

:: Lapis 2: System PATH (Global Windows)
ffmpeg -version >nul 2>&1
if !errorlevel! equ 0 (
    set "ffmpeg_path=ffmpeg"
    goto start
)

:: Lapis 3: Custom Path Pribadi (Hardcoded)
set "my_pc=D:\Download\ffmpeg-2026-03-22-git-9c63742425-essentials_build\ffmpeg-2026-03-22-git-9c63742425-essentials_build\bin\ffmpeg.exe"
if exist "%my_pc%" (
    set "ffmpeg_path=%my_pc%"
    goto start
)

:: Lapis 4: Smart Search di D:\Download (Lentur/Tidak Kaku)
echo  [i] Mencari FFmpeg di folder Download...
for /f "delims=" %%i in ('dir /s /b "D:\Download\ffmpeg.exe" 2^>nul') do (
    set "ffmpeg_path=%%i"
    if exist "!ffmpeg_path!" (
        echo  [v] Ditemukan di: %%i
        timeout /t 1 >nul
        goto start
    )
)

:: ==========================================
:: 2. LOGIKA AUTO-DOWNLOAD (VISUAL LOADING)
:: ==========================================
cls
echo ==========================================================
echo   [!] FFMPEG TIDAK DITEMUKAN DI SISTEM
echo ==========================================================
echo  Program tidak menemukan ffmpeg.exe di lokal maupun D:\Download.
echo  File akan diunduh secara otomatis dari GitHub.
echo ----------------------------------------------------------
set /p dl=" [?] Mulai proses unduh sekarang? (y/n): "
if /i "!dl!" neq "y" exit

echo.
echo  [i] Menghubungkan ke GitHub...
echo  [i] Mengunduh arsip FFmpeg...
echo      (Progres pengunduhan muncul di bagian atas jendela ini)
echo.

:: Menggunakan PowerShell dengan Progress Bar ($ProgressPreference = 'Continue')
powershell -Command ^
    "$ProgressPreference = 'Continue'; " ^
    "Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile 'ffmpeg.zip'"

echo.
echo  [i] Selesai! Mengekstrak file ZIP...
powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_ext' -Force"

:: Mencari folder hasil ekstrak secara dinamis
for /f "delims=" %%d in ('dir /b "ffmpeg_ext\ffmpeg-master*"') do set "extracted_folder=%%d"

echo  [i] Memindahkan ffmpeg.exe ke folder utama...
copy "ffmpeg_ext\!extracted_folder!\bin\ffmpeg.exe" "%~dp0ffmpeg.exe" >nul

echo  [i] Membersihkan file sementara...
rmdir /s /q "ffmpeg_ext"
del "ffmpeg.zip"

echo ----------------------------------------------------------
echo  [v] FFmpeg berhasil diinstal di lokasi script ini!
echo ----------------------------------------------------------
pause
set "ffmpeg_path=%~dp0ffmpeg.exe"


:: ==========================================
:: 3. PROGRAM UTAMA DIMULAI
:: ==========================================
:start
cls
echo ==========================================================
echo               SUPER SEARCH LOSSLESS AUDIO CUTTER
echo               by : abriel wiradika utama
echo ==========================================================
echo   Lokasi Scan: %cd% (Termasuk Subfolder)
echo   Status     : FFmpeg Ready 
echo ==========================================================
echo.

set /p name=" [?] Masukkan Kata Kunci / Nama Lagu: "

:: Proses Pencarian
echo  [i] Mencari file... silakan tunggu...
set count=0
for /f "delims=" %%f in ('dir /s /b "*%name%*.*" 2^>nul') do (
    if /i not "%%~xf"==".bat" (
        if /i not "%%~nxf"=="ffmpeg.exe" (
            set /a count+=1
            set "file_!count!=%%f"
            echo  [!count!] %%f
        )
    )
)

if %count% equ 0 (
    echo.
    echo  [x] GAGAL: File mengandung kata "%name%" tidak ditemukan.
    pause
    goto start
)

:: Logika Pilih File
echo.
if %count% gtr 1 (
    set /p choice=" [?] Ditemukan %count% file. Pilih nomor (1-%count%): "
) else (
    set choice=1
)

set "final_path=!file_%choice%!"

if "!final_path!"=="" (
    echo  [x] Pilihan tidak valid!
    pause
    goto start
)

:: Input Waktu Potong
cls
echo ==========================================================
echo   FILE TERPILIH: 
echo   !final_path!
echo ==========================================================
echo.
echo   PETUNJUK FORMAT WAKTU:
echo   Gunakan format [Menit:Detik] atau [Jam:Menit:Detik]
echo   Contoh: 01:30 (Mulai di menit 1 detik 30)
echo   Contoh: 00:45 (Mulai di detik 45)
echo ----------------------------------------------------------
echo.

set /p start_t=" [>] POTONG MULAI DARI (Contoh 00:30): "
set /p end_t=" [>] POTONG SAMPAI PADA (Contoh 02:15): "

echo.
echo  [i] Sedang memproses... mohon tunggu sebentar...

:: Eksekusi Pemotongan
for %%A in ("!final_path!") do (
    set "f_dir=%%~dpA"
    set "f_name=%%~nxA"
)
"!ffmpeg_path!" -i "!final_path!" -ss !start_t! -to !end_t! -c copy "!f_dir!CUT_!f_name!"

echo ----------------------------------------------------------
if %errorlevel% equ 0 (
    echo  [v] BERHASIL! File disimpan di folder aslinya.
) else (
    echo  [x] Terjadi kesalahan teknis. Periksa format waktu.
)
echo ----------------------------------------------------------

echo.
set /p lagi=" [?] Potong lagu lain? (y/n): "
if /i "%lagi%"=="y" goto start
exit