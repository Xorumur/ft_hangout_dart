package com.example.ft_hangout

import io.flutter.embedding.android.FlutterActivity
import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_sender"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSMS") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")

                if (phoneNumber != null && message != null) {
                    sendSMS(phoneNumber, message, result)
                } else {
                    result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), 1)
        } else {
            try {
                val smsManager = SmsManager.getDefault()
                smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                result.success("SMS sent successfully")
            } catch (e: Exception) {
                result.error("SMS_ERROR", "Failed to send SMS", null)
            }
        }
    }
}
