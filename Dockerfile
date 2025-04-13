# 使用包含較新 Flutter 穩定版本和兼容 Java 版本的基礎映像檔
# 參考: https://hub.docker.com/r/cirrusci/flutter
FROM cirrusci/flutter:stable

# 設定工作目錄
WORKDIR /app

# 複製 pubspec 檔案
COPY pubspec.* ./

# 下載 Flutter 依賴項
# 這一步會預先下載依賴，以便後續建置更快，並利用 Docker 的層快取
RUN flutter pub get

# 複製專案的其餘檔案 (根據 .dockerignore 排除不必要的檔案)
COPY . .

# (可選) 執行 flutter doctor 驗證環境 (會在建置映像檔時執行)
# RUN flutter doctor -v

# 預設命令：建置 Android APK (Release 版本)
# 您可以在執行 docker run 時覆寫此命令，例如建置 debug 版本：
# docker run --rm -v $(pwd)/build/app/outputs/flutter-apk:/app/build/app/outputs/flutter-apk your-image-name flutter build apk --debug
CMD ["flutter", "build", "apk", "--release"]
