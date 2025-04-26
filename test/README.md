# Volticar 應用測試指南

本指南說明如何為 Volticar 應用運行各種測試。

## 前置準備

1. 確保已安裝所有依賴：

```bash
flutter pub get
```

2. 為模擬測試生成必要的文件：

```bash
flutter pub run build_runner build
```

## 運行測試

### 運行單個測試文件

```bash
flutter test test/unit/core/utils/observer_test.dart
```

### 運行所有單元測試

```bash
flutter test test/unit/
```

### 運行所有 Widget 測試

```bash
flutter test test/widget/
```

### 運行所有測試

```bash
flutter test
```

## 測試覆蓋率

要生成測試覆蓋率報告：

```bash
flutter test --coverage
```

這將在項目根目錄的 `coverage/` 文件夾中生成報告。

若要將覆蓋率報告轉換為 HTML 格式以便查看，你需要安裝 LCOV：

### Windows

使用 Chocolatey 安裝：

```bash
choco install lcov
```

### macOS

使用 Homebrew 安裝：

```bash
brew install lcov
```

### 生成 HTML 報告

```bash
genhtml coverage/lcov.info -o coverage/html
```

現在你可以打開 `coverage/html/index.html` 文件查看測試覆蓋率報告。

## 測試結構

- `test/unit/` - 單元測試，測試單個類和函數的邏輯
  - `test/unit/core/` - 核心組件的測試
  - `test/unit/features/` - 功能模塊的測試
- `test/widget/` - Widget 測試，測試 UI 組件的渲染和交互
- `test/integration/` - 集成測試（尚未實現）

## 測試命名約定

- 單元測試文件名：`{被測試的類名}_test.dart`
- Widget 測試文件名：`{被測試的組件名}_test.dart`

## 注意事項

1. 確保在寫測試之前理解被測試代碼的功能
2. 使用 `setUp` 和 `tearDown` 準備和清理測試環境
3. 使用 `group` 組織相關的測試用例
4. 對於依賴外部服務的類，使用 Mockito 模擬依賴 