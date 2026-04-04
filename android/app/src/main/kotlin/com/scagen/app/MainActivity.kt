package com.scagen.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private val pendingTexts = ArrayDeque<String>()
    private var isDartReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureIncomingText(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialText" -> {
                    isDartReady = true
                    val initialTexts = pendingTexts.toList()
                    pendingTexts.clear()
                    result.success(initialTexts)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureIncomingText(intent)
    }

    private fun captureIncomingText(intent: Intent?) {
        val text = extractIncomingText(intent) ?: return
        if (isDartReady && channel != null) {
            channel?.invokeMethod("onText", text)
        } else {
            while (pendingTexts.size >= MAX_PENDING_TEXTS) {
                pendingTexts.removeFirstOrNull()
            }
            pendingTexts.addLast(text)
        }
    }

    private fun extractIncomingText(intent: Intent?): String? {
        if (intent == null) return null
        return when (intent.action) {
            Intent.ACTION_PROCESS_TEXT -> intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
            Intent.ACTION_SEND -> {
                if (intent.type == "text/plain") {
                    intent.getStringExtra(Intent.EXTRA_TEXT)
                } else {
                    null
                }
            }

            else -> null
        }
            ?.trim()
            ?.take(MAX_SHARED_TEXT_LENGTH)
            ?.takeIf { it.isNotEmpty() }
    }

    companion object {
        private const val CHANNEL_NAME = "scagen/process_text"
        private const val MAX_PENDING_TEXTS = 8
        private const val MAX_SHARED_TEXT_LENGTH = 8192
    }
}
