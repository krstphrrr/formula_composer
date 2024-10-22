package com.example.formula_composer

import android.util.Log
import android.content.ContentResolver
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream
import java.nio.charset.StandardCharsets

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.formula_composer/file_operations"

    override fun configureFlutterEngine(@NonNull flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "writeToContentUri") {
                val uriString = call.argument<String>("uri")
                val csvContent = call.argument<String>("csvContent")
        
                if (uriString != null && csvContent != null) {
                    Log.d("MainActivity", "URI String: $uriString")
                    Log.d("MainActivity", "CSV Content: $csvContent")
                    
                    val success = writeToContentUri(uriString, csvContent)
                    if (success) {
                        result.success(null)
                    } else {
                        result.error("UNAVAILABLE", "Failed to write to content URI", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun writeToContentUri(uriString: String, csvContent: String): Boolean {
        return try {
            val uri = Uri.parse(uriString)
            val resolver: ContentResolver = applicationContext.contentResolver
            resolver.openOutputStream(uri)?.use { outputStream ->
                outputStream.write(csvContent.toByteArray(StandardCharsets.UTF_8))
                outputStream.flush()
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}

