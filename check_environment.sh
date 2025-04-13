#!/bin/bash

echo "正在檢查 VoltiCar 開發環境..."
echo "================================="

# --- Java 檢查 ---
echo "檢查 Java 版本..."
JAVA_VERSION_OUTPUT=$(java -version 2>&1) # 將 stderr 重定向到 stdout
REQUIRED_JAVA_MAJOR="11"
JAVA_OK=false

if [[ $JAVA_VERSION_OUTPUT == *"version \"$REQUIRED_JAVA_MAJOR."* ]]; then
    echo "✅ Java 版本檢查通過 (找到以 $REQUIRED_JAVA_MAJOR 開頭的版本)。"
    JAVA_OK=true
else
    echo "❌ Java 版本檢查失敗！"
    echo "   需求版本: Java $REQUIRED_JAVA_MAJOR"
    echo "   偵測到的輸出:"
    echo "$JAVA_VERSION_OUTPUT"
    echo "   請安裝或切換至 Java $REQUIRED_JAVA_MAJOR。"
fi
echo ""

# --- Flutter 檢查 ---
echo "檢查 Flutter 版本..."
FLUTTER_VERSION_OUTPUT=$(flutter --version)
REQUIRED_FLUTTER_VERSION="3.7.2"
FLUTTER_OK=false

if [[ $FLUTTER_VERSION_OUTPUT == *"Flutter $REQUIRED_FLUTTER_VERSION"* ]]; then
    echo "✅ Flutter 版本檢查通過 (找到 $REQUIRED_FLUTTER_VERSION)。"
    FLUTTER_OK=true
else
    echo "❌ Flutter 版本檢查失敗！"
    echo "   需求版本: Flutter $REQUIRED_FLUTTER_VERSION"
    echo "   偵測到的輸出:"
    echo "$FLUTTER_VERSION_OUTPUT"
    echo "   請確保已安裝 Flutter $REQUIRED_FLUTTER_VERSION 並設定於 PATH 環境變數。"
fi
echo ""

# --- 總結 ---
echo "================================="
if $JAVA_OK && $FLUTTER_OK; then
    echo "🎉 環境檢查成功！您應該可以在本地建置此專案。"
    echo "   (注意：仍建議使用提供的 Dockerfile 以確保建置環境的絕對一致性)。"
    exit 0
else
    echo "⚠️ 環境檢查失敗。請修正以上列出的問題。"
    echo "   或者，使用提供的 Dockerfile 在容器化環境中建置專案："
    echo "   1. 建置映像檔: docker build -t volticar-builder ."
    echo "   2. 建置 APK:   docker run --rm -v \"\$(pwd)/build/app/outputs/flutter-apk:/app/build/app/outputs/flutter-apk\" volticar-builder"
    exit 1
fi
