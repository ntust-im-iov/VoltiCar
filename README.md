# VoltiCar

## 專案簡介

VoltiCar 是一個專注於電動車充電站管理的 Flutter 應用程式。這個應用程式幫助用戶輕鬆找到附近的充電站，並提供即時的充電站狀態資訊。本專案旨在解決電動車用戶在尋找充電站時遇到的困擾，提供一個直觀且實用的解決方案。

## 專案結構

專案採用分層架構設計，遵循 MVVM (Model-View-ViewModel) 模式：

```
├─core
│  ├─constants
│  ├─network
│  └─utils
├─features
│  ├─auth(登入註冊功能)
│  │  ├─models
│  │  ├─repositories
│  │  ├─services
│  │  ├─viewmodels
│  │  └─views
│  └─home(主畫面功能)
│      ├─models
│      ├─repositories
│      ├─services
│      ├─viewmodels
│      └─views
└─shared(共享物件)
    ├─maplist
    └─widgets
```

### 目錄說明

- **core/**: 核心功能模組
  - **constants/**: 常數定義
  - **network/**: 網絡相關功能
  - **utils/**: 工具類和通用方法
- **features/**: 功能模組
  - **auth/**: 身份驗證模組 (登入、註冊功能)
    - **models/**: 數據模型
    - **repositories/**: 數據訪問層
    - **services/**: 業務邏輯層
    - **viewmodels/**: 視圖模型
    - **views/**: UI 視圖
  - **home/**: 主畫面功能模組
    - **models/**: 數據模型
    - **repositories/**: 數據訪問層
    - **services/**: 業務邏輯層
    - **viewmodels/**: 視圖模型
    - **views/**: UI 視圖
- **shared/**: 共享組件
  - **maplist/**: 地圖列表相關功能
  - **widgets/**: 可重用的 UI 組件

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
