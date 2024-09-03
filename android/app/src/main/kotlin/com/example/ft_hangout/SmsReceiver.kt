package com.example.ft_hangout

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class SmsReceiver : BroadcastReceiver() {
    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val bundle: Bundle? = intent.extras
        try {
            if (bundle != null) {
                val pdus = bundle["pdus"] as Array<*>
                for (pdu in pdus) {
                    val message = SmsMessage.createFromPdu(pdu as ByteArray)
                    val sender = message.displayOriginatingAddress
                    val content = message.messageBody

                    Log.d("SmsReceiver", "Message received from $sender: $content")

                    // Transmet le message à Flutter via le MethodChannel
                    methodChannel?.invokeMethod("onSmsReceived", mapOf(
                        "sender" to sender,
                        "message" to content
                    ))
                }
            }
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Exception in SmsReceiver: ${e.message}")
        }
    }
}
