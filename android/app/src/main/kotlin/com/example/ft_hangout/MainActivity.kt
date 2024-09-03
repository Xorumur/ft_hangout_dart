// // package com.example.ft_hangout

// // import io.flutter.embedding.android.FlutterActivity
// // import android.Manifest
// // import android.content.pm.PackageManager
// // import android.telephony.SmsManager
// // import androidx.core.app.ActivityCompat
// // import androidx.core.content.ContextCompat
// // import io.flutter.embedding.engine.FlutterEngine
// // import io.flutter.plugin.common.MethodChannel


// // class MainActivity: FlutterActivity() {
// //     private val CHANNEL = "sms_sender"

// //     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
// //         super.configureFlutterEngine(flutterEngine)

// //         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
// //             if (call.method == "sendSMS") {
// //                 val phoneNumber = call.argument<String>("phoneNumber")
// //                 val message = call.argument<String>("message")

// //                 if (phoneNumber != null && message != null) {
// //                     sendSMS(phoneNumber, message, result)
// //                 } else {
// //                     result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
// //                 }
// //             } else {
// //                 result.notImplemented()
// //             }
// //         }
// //     }

// //     private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
// //         if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
// //             ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), 1)
// //         } else {
// //             try {
// //                 val smsManager = SmsManager.getDefault()
// //                 smsManager.sendTextMessage(phoneNumber, null, message, null, null)
// //                 result.success("SMS sent successfully")
// //             } catch (e: Exception) {
// //                 result.error("SMS_ERROR", "Failed to send SMS", null)
// //             }
// //         }
// //     }
// // }

// package com.example.ft_hangout

// import android.Manifest
// import android.content.pm.PackageManager
// import android.telephony.SmsManager
// import androidx.core.app.ActivityCompat
// import androidx.core.content.ContextCompat
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel

// class MainActivity: FlutterActivity() {
//     private val CHANNEL = "sms_sender"

//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)

//         // Enregistrer le MethodChannel dans SmsReceiver
//         val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//         SmsReceiver.methodChannel = methodChannel

//         methodChannel.setMethodCallHandler { call, result ->
//             if (call.method == "sendSMS") {
//                 val phoneNumber = call.argument<String>("phoneNumber")
//                 val message = call.argument<String>("message")

//                 if (phoneNumber != null && message != null) {
//                     sendSMS(phoneNumber, message, result)
//                 } else {
//                     result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
//                 }
//             } else {
//                 result.notImplemented()
//             }
//         }
//     }

//     private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
//         if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
//             ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), 1)
//         } else {
//             try {
//                 val smsManager = SmsManager.getDefault()
//                 smsManager.sendTextMessage(phoneNumber, null, message, null, null)
//                 result.success("SMS sent successfully")
//             } catch (e: Exception) {
//                 result.error("SMS_ERROR", "Failed to send SMS", null)
//             }
//         }
//     }
// }
package com.example.ft_hangout

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_sender"
    private val SMS_PERMISSION_CODE = 1

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
            Manifest.permission.READ_SMS
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
        if (requestCode == SMS_PERMISSION_CODE) {
            val grantedPermissions = grantResults.indices
                .filter { grantResults[it] == PackageManager.PERMISSION_GRANTED }
                .map { permissions[it] }

            if (grantedPermissions.containsAll(listOf(Manifest.permission.SEND_SMS, Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS))) {
                Log.d("MainActivity", "All SMS permissions granted")
            } else {
                Log.d("MainActivity", "Some SMS permissions denied")
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
}
