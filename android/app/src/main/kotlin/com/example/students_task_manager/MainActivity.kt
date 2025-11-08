package com.example.students_task_manager

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "notification_permissions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestBatteryOptimizationExemption" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
                        val packageName = packageName
                        
                        if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                            try {
                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                    data = Uri.parse("package:$packageName")
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                // If the intent fails, try opening battery settings
                                try {
                                    val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                                    startActivity(intent)
                                    result.success(false) // User needs to manually enable
                                } catch (e2: Exception) {
                                    result.success(false)
                                }
                            }
                        } else {
                            result.success(true) // Already exempted
                        }
                    } else {
                        result.success(true) // Not needed for older Android versions
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
