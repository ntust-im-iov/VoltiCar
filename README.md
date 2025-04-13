# VoltiCar

## 專案簡介

VoltiCar 是一個專注於電動車充電站管理的 Flutter 應用程式。這個應用程式幫助用戶輕鬆找到附近的充電站，並提供即時的充電站狀態資訊。本專案旨在解決電動車用戶在尋找充電站時遇到的困擾，提供一個直觀且實用的解決方案。

## 目前功能

### 已完成功能
- 基本的地圖顯示功能
- 充電站位置標記
- 簡單的用戶介面

### 開發中功能
- 充電站詳細資訊顯示
- 路線規劃
- 充電站狀態即時更新

## 技術架構

### 前端
- Flutter/Dart
- Google Maps API
- Provider 狀態管理

### 後端
- Firebase
  - Authentication
  - Firestore
  - Cloud Functions

## 待改進項目

### 高優先級
- [ ] 完善充電站資料庫
- [ ] 優化地圖載入效能
- [ ] 實現用戶認證系統

### 中優先級
- [ ] 加入充電站評分系統
- [ ] 優化 UI/UX 設計
- [ ] 實現離線功能

### 低優先級
- [ ] 多語言支援
- [ ] 深色模式
- [ ] 用戶個人化設定

# volticar_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

## 開發環境

為了確保專案能夠順利建置與運行，請確認您的開發環境符合以下要求：

*   **Flutter SDK**: `3.7.2`
*   **Java Development Kit (JDK)**: `11` (用於 Android 建置)

### 環境檢查

您可以執行專案根目錄下的檢查腳本，快速確認您的本地環境是否符合要求：

*   **Linux / macOS:**
    ```bash
    chmod +x check_environment.sh
    ./check_environment.sh
    ```
*   **Windows:**
    ```batch
    .\check_environment.bat
    ```

腳本會檢查您的 Java 和 Flutter 版本。如果檢查失敗，請根據提示安裝或切換至正確的版本。

### 使用 Docker 建置 (推薦)

為了完全避免本地環境差異導致的建置問題 (特別是 Java 和 Gradle 版本)，強烈建議使用 Docker 來建置 Android APK。

1.  **安裝 Docker**: 請確保您的系統已安裝 Docker Desktop 或 Docker Engine。
2.  **建置 Docker 映像檔**: 在專案根目錄執行：
    ```bash
    docker build -t volticar-builder .
    ```
    (映像檔名稱 `volticar-builder` 可自訂)
3.  **執行建置**:
    *   **Linux / macOS:**
        ```bash
        docker run --rm -v "$(pwd)/build/app/outputs/flutter-apk:/app/build/app/outputs/flutter-apk" volticar-builder
        ```
    *   **Windows (Command Prompt / PowerShell):**
        ```bash
        docker run --rm -v "%cd%/build/app/outputs/flutter-apk:/app/build/app/outputs/flutter-apk" volticar-builder
        ```
    建置完成後，APK 檔案將位於專案的 `build/app/outputs/flutter-apk/release/` 目錄下。您可以將此 APK 檔案安裝到 Android 模擬器或實體設備進行測試。

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
