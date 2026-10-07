package com.fortuneboot.intelligent

import android.content.pm.PackageManager
import android.hardware.fingerprint.FingerprintManager
import android.os.Build
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var pending: MethodChannel.Result? = null
    private var fingerprintCancel: CancellationSignal? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "availability" -> result.success(availability())
                "authenticate" -> authenticate(call, result)
                "cancel" -> {
                    finishAuth(false)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun availability(): Map<String, Boolean> {
        val pm = packageManager
        val biometric = BiometricManager.from(this)
        val strongOk =
            biometric.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG) ==
                BiometricManager.BIOMETRIC_SUCCESS
        val weakOk =
            biometric.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK) ==
                BiometricManager.BIOMETRIC_SUCCESS
        return mapOf(
            "face" to (pm.hasSystemFeature(PackageManager.FEATURE_FACE) || weakOk),
            "fingerprint" to (hasEnrolledFingerprint() || strongOk),
            "strong" to strongOk,
            "weak" to weakOk,
        )
    }

    private fun authenticate(call: MethodCall, result: MethodChannel.Result) {
        val method = call.argument<String>("method").orEmpty()
        val reason = call.argument<String>("reason").orEmpty()
        if (method == "fingerprint") {
            authenticateFingerprint(result)
            return
        }
        authenticateFace(reason, result)
    }

    @Suppress("DEPRECATION")
    private fun hasEnrolledFingerprint(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return false
        val manager = getSystemService(FingerprintManager::class.java) ?: return false
        return manager.isHardwareDetected && manager.hasEnrolledFingerprints()
    }

    @Suppress("DEPRECATION")
    private fun authenticateFingerprint(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || !hasEnrolledFingerprint()) {
            result.success(false)
            return
        }
        val manager = getSystemService(FingerprintManager::class.java)
        if (manager == null) {
            result.success(false)
            return
        }
        finishAuth(false)
        pending = result
        val cancel = CancellationSignal()
        fingerprintCancel = cancel
        manager.authenticate(
            null,
            cancel,
            0,
            object : FingerprintManager.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    authResult: FingerprintManager.AuthenticationResult?,
                ) {
                    runOnUiThread { finishAuth(true) }
                }

                override fun onAuthenticationError(
                    errorCode: Int,
                    errString: CharSequence?,
                ) {
                    runOnUiThread { finishAuth(false) }
                }
            },
            Handler(Looper.getMainLooper()),
        )
    }

    private fun authenticateFace(reason: String, result: MethodChannel.Result) {
        val authenticators = BiometricManager.Authenticators.BIOMETRIC_WEAK
        val can = BiometricManager.from(this).canAuthenticate(authenticators)
        if (can != BiometricManager.BIOMETRIC_SUCCESS) {
            result.success(false)
            return
        }
        finishAuth(false)
        pending = result
        val prompt =
            BiometricPrompt(
                this,
                ContextCompat.getMainExecutor(this),
                object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationSucceeded(
                        authResult: BiometricPrompt.AuthenticationResult,
                    ) {
                        finishAuth(true)
                    }

                    override fun onAuthenticationError(
                        errorCode: Int,
                        errString: CharSequence,
                    ) {
                        finishAuth(false)
                    }
                },
            )
        val info =
            BiometricPrompt.PromptInfo.Builder()
                .setTitle("面容解锁")
                .setSubtitle(reason)
                .setAllowedAuthenticators(authenticators)
                .setNegativeButtonText("取消")
                .setConfirmationRequired(false)
                .build()
        prompt.authenticate(info)
    }

    private fun finishAuth(ok: Boolean) {
        val reply = pending
        pending = null
        val cancel = fingerprintCancel
        fingerprintCancel = null
        if (cancel != null && !cancel.isCanceled) {
            cancel.cancel()
        }
        reply?.success(ok)
    }

    companion object {
        private const val CHANNEL = "fortuneboot/app_lock"
    }
}
