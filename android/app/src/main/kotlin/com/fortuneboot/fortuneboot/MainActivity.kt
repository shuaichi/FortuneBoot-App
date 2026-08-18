package com.fortuneboot.fortuneboot

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val SCREEN_CAPTURE_CHANNEL =
            "fortuneboot/screen_capture_protection"
        private const val SET_SCREEN_CAPTURE_ALLOWED =
            "setScreenCaptureAllowed"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setScreenCaptureAllowed(false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_CAPTURE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != SET_SCREEN_CAPTURE_ALLOWED) {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val allowed = call.argument<Boolean>("allowed")
            if (allowed == null) {
                result.error("invalid_argument", "Missing allowed value", null)
                return@setMethodCallHandler
            }

            try {
                setScreenCaptureAllowed(allowed)
                result.success(null)
            } catch (exception: RuntimeException) {
                result.error(
                    "screen_capture_protection_failed",
                    exception.message,
                    null,
                )
            }
        }
    }

    private fun setScreenCaptureAllowed(allowed: Boolean) {
        if (allowed) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
