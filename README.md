## 應用程式功能

本應用程式主要包含以下功能模組：

*   **使用者驗證**:
    *   登入 (`lib/views/auth/login_view.dart`)
    *   註冊 (`lib/views/auth/register_view.dart`)
    *   重設密碼 (`lib/views/auth/reset_password_view.dart`)
*   **核心功能 (登入後)**:
    *   主畫面儀表板 (`lib/views/home/home_view.dart`)
    *   車庫 (`lib/views/home/garage_view.dart`): 可能用於管理擁有的車輛
    *   我的車輛 (`lib/views/home/mycar_view.dart`): 查看特定車輛詳細資訊
    *   地圖 (`lib/views/home/map_view.dart`): 可能顯示充電站或其他地點
    *   充電管理 (`lib/views/home/charging_view.dart`): 查看或控制充電狀態
    *   帳號設定 (`lib/views/home/account_view.dart`)
    *   工具 (`lib/views/home/tools_view.dart`)
    *   競賽 (`lib/views/home/race_view.dart`): 可能為遊戲化功能

## 開發環境

為了確保專案能夠順利建置與運行，建議您的開發環境符合以下要求 (本地環境版本已透過 `check_environment.bat` 更新檢查)：

*   **Flutter SDK**: `3.29.2` (或最新穩定版)
*   **Java Development Kit (JDK)**: `23` (或與最新 Flutter 穩定版兼容的版本，用於 Android 建置)

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
2.  **建置 Docker 映像檔**: Dockerfile 已更新為使用 `cirrusci/flutter:stable` 基礎映像檔，以提供較新的 Flutter 和 Java 環境。在專案根目錄執行：
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
