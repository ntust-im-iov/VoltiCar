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
