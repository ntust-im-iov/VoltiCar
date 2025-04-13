@echo off
echo 正在檢查 VoltiCar 開發環境...
echo =================================

setlocal enabledelayedexpansion

rem --- Java 檢查 ---
echo 檢查 Java 版本...
set JAVA_OK=false
for /f "tokens=2 delims=." %%a in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    for /f "tokens=1 delims=^"" %%b in ("%%a") do (
        if "%%b"=="11" (
            echo ✅ Java 版本檢查通過 (找到以 11 開頭的版本^).
            set JAVA_OK=true
        )
    )
)
if not !JAVA_OK! == true (
    echo ❌ Java 版本檢查失敗！
    echo    需求版本: Java 11
    echo    請執行 'java -version' 查看您的版本。
    echo    請安裝或切換至 Java 11。
)
echo.

rem --- Flutter 檢查 ---
echo 檢查 Flutter 版本...
set FLUTTER_OK=false
for /f "tokens=2" %%f in ('flutter --version ^| findstr /i "Flutter"') do (
    if "%%f"=="3.7.2" (
        echo ✅ Flutter 版本檢查通過 (找到 3.7.2^).
        set FLUTTER_OK=true
    )
)
if not !FLUTTER_OK! == true (
    echo ❌ Flutter 版本檢查失敗！
    echo    需求版本: Flutter 3.7.2
    echo    請執行 'flutter --version' 查看您的版本。
    echo    請確保已安裝 Flutter 3.7.2 並設定於 PATH 環境變數。
)
echo.

rem --- 總結 ---
echo =================================
if !JAVA_OK! == true if !FLUTTER_OK! == true (
    echo 🎉 環境檢查成功！您應該可以在本地建置此專案。
    echo    (注意：仍建議使用提供的 Dockerfile 以確保建置環境的絕對一致性^).
    exit /b 0
) else (
    echo ⚠️ 環境檢查失敗。請修正以上列出的問題。
    echo    或者，使用提供的 Dockerfile 在容器化環境中建置專案：
    echo    1. 建置映像檔: docker build -t volticar-builder .
    echo    2. 建置 APK:   docker run --rm -v "%%cd%%/build/app/outputs/flutter-apk:/app/build/app/outputs/flutter-apk" volticar-builder
    exit /b 1
)

endlocal
