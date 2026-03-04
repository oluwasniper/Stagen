package com.example.revolutionary_stuff

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private val pendingTexts = ArrayDeque<String>()

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
                    result.success(pendingTexts.removeFirstOrNull())
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
        pendingTexts.addLast(text)
        channel?.invokeMethod("onText", text)
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
        }?.trim()?.takeIf { it.isNotEmpty() }
    }

    companion object {
        private const val CHANNEL_NAME = "scagen/process_text"
    }
}
