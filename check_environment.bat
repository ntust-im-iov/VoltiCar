@echo off
chcp 65001 > nul
echo 正在檢查 VoltiCar 開發環境
echo =================================

set JAVA_OK=false
set FLUTTER_OK=false
set TEMP_JAVA_VERSION_FILE=%TEMP%\java_version_check.tmp

rem --- Java 檢查 ---
echo(
echo 檢查 Java 版本
where java > nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] 找不到 'java' 命令。請確認 Java 已安裝並設定於 PATH 環境變數
    goto FlutterCheck
)

rem 執行 java -version 並檢查輸出
java -version > "%TEMP_JAVA_VERSION_FILE%" 2>&1
if not exist "%TEMP_JAVA_VERSION_FILE%" (
    echo [FAIL] 無法執行 'java -version' 或無法建立暫存檔
    echo    請確認 Java 已安裝並設定於 PATH 環境變數，且您有權限寫入 %TEMP% 目錄
    goto FlutterCheck
)

findstr "23." "%TEMP_JAVA_VERSION_FILE%" > nul
if %errorlevel% equ 0 (
    echo [OK] Java 版本檢查通過 (找到包含 "23" 的版本)
    set JAVA_OK=true
    goto JavaCheckDone
)
rem This part only runs if findstr failed (errorlevel NEQ 0)
echo [FAIL] Java 版本檢查失敗！ 未在版本資訊中找到 "23"
echo    偵測到的版本資訊 (來自 %TEMP_JAVA_VERSION_FILE%)
type "%TEMP_JAVA_VERSION_FILE%"
echo(
echo    需求版本 Java 23 (需要包含 "23" 的版本字串)
echo    請執行 'java -version' 查看您的版本
echo    請安裝或切換至 Java 23

:JavaCheckDone
del "%TEMP_JAVA_VERSION_FILE%" > nul 2>&1

:FlutterCheck
rem --- Flutter 檢查 ---
echo(
echo 檢查 Flutter 版本
where flutter > nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] 找不到 'flutter' 命令。請確認 Flutter 已安裝並設定於 PATH 環境變數
    goto Summary
)

flutter --version | findstr /C:"Flutter 3.29.2" > nul
if %errorlevel% equ 0 (
    echo [OK] Flutter 版本檢查通過 (找到 3.29.2)
    set FLUTTER_OK=true
    goto FlutterCheckDone
)
rem This part only runs if findstr failed (errorlevel NEQ 0)
echo [FAIL] Flutter 版本檢查失敗！ 未找到版本 3.29.2
echo    請執行 'flutter --version' 查看您的版本
echo    需求版本 Flutter 3.29.2
echo    請確保已安裝 Flutter 3.29.2 並設定於 PATH 環境變數

:FlutterCheckDone
rem Flow continues to Summary

:Summary
rem --- 總結 ---
echo(
echo =================================
if "%JAVA_OK%" == "true" if "%FLUTTER_OK%" == "true" (
    echo [成功] 環境檢查成功！您應該可以在本地建置此專案
    echo    (注意 仍建議使用提供的 Dockerfile 以確保建置環境的絕對一致性)
    exit /b 0
) else (
    echo [失敗] 環境檢查失敗。請修正以上列出的問題
    echo    或者，使用提供的 Dockerfile 在容器化環境中建置專案
    echo    1 建置映像檔 docker build -t volticar-builder .
    echo    2 建置 APK   docker run --rm -v "%cd%/build/app/outputs/flutter-apk:/app/build/app/outputs/flutter-apk" volticar-builder
    exit /b 1
)
