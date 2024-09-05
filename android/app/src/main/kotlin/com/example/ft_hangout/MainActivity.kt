package com.example.ft_hangout

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_sender"
    private val SMS_PERMISSION_CODE = 1
    private val CALL_PERMISSION_CODE = 2

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Enregistrer le MethodChannel dans SmsReceiver
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        SmsReceiver.methodChannel = methodChannel

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")

                    if (phoneNumber != null && message != null) {
                        sendSMS(phoneNumber, message, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
                    }
                }
                "makeCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    if (phoneNumber != null) {
                        makePhoneCall(phoneNumber, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Phone number is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Vérifiez et demandez les permissions nécessaires
        checkAndRequestSmsPermissions()
    }

    private fun checkAndRequestSmsPermissions() {
        val smsPermissions = arrayOf(
            Manifest.permission.SEND_SMS,
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
            Manifest.permission.CALL_PHONE // Ajout de la permission pour les appels téléphoniques
        )

        val permissionsNeeded = smsPermissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (permissionsNeeded.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsNeeded.toTypedArray(), SMS_PERMISSION_CODE)
        } else {
            Log.d("MainActivity", "All SMS permissions granted")
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_CODE || requestCode == CALL_PERMISSION_CODE) {
            val grantedPermissions = grantResults.indices
                .filter { grantResults[it] == PackageManager.PERMISSION_GRANTED }
                .map { permissions[it] }

            if (grantedPermissions.containsAll(listOf(Manifest.permission.SEND_SMS, Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS, Manifest.permission.CALL_PHONE))) {
                Log.d("MainActivity", "All permissions granted")
            } else {
                Log.d("MainActivity", "Some permissions denied")
            }
        }
    }

    private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), SMS_PERMISSION_CODE)
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

    private fun makePhoneCall(phoneNumber: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CALL_PHONE), CALL_PERMISSION_CODE)
        } else {
            try {
                val intent = Intent(Intent.ACTION_CALL)
                intent.data = Uri.parse("tel:$phoneNumber")
                startActivity(intent)
                result.success("Call initiated")
            } catch (e: Exception) {
                result.error("CALL_ERROR", "Failed to initiate call", null)
            }
        }
    }
}
