package com.example.volticar_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun getRenderMode(): RenderMode {
        return RenderMode.surface
    }
}
