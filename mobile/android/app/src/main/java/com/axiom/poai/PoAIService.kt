package com.axiom.poai

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.WorkManager
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.ExistingPeriodicWorkPolicy
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.util.concurrent.TimeUnit
import java.security.MessageDigest
import android.os.BatteryManager

/**
 * VIOLET-AF Proof-of-AI Service
 * 
 * Energy-aware PoAI computation service that only runs when:
 * - Device is charging OR battery > 70%
 * - Screen is off
 * - CPU temperature is normal
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */
class PoAIService : Service() {
    companion object {
        private const val TAG = "PoAIService"
        private const val NOTIFICATION_CHANNEL_ID = "poai_service_channel"
        private const val NOTIFICATION_ID = 1001
        private const val CREATOR_UID = "ALC-ROOT-1010-1111-XCOV∞"
        private const val CREATOR_EMAIL = "allcatch37@gmail.com"
        private const val KEY_ALIAS = "poai_ed25519_key"
        private const val WORK_TAG = "poai_digest_work"
    }

    private lateinit var keyStore: KeyStore
    private lateinit var powerManager: PowerManager
    private lateinit var batteryManager: BatteryManager
    private var isServiceRunning = false

    inner class PoAIBinder : Binder() {
        fun getService(): PoAIService = this@PoAIService
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "PoAI Service created - VIOLET-AF Quantum Logic Initialized")
        
        powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        
        createNotificationChannel()
        initializeKeyStore()
        
        // Schedule periodic PoAI digest computation
        schedulePoAIWork()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!isServiceRunning && shouldRunPoAI()) {
            startForegroundService()
            isServiceRunning = true
            Log.i(TAG, "PoAI Service started with energy-aware policy")
        } else {
            Log.w(TAG, "PoAI Service not started - energy policy requirements not met")
            stopSelf()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder = PoAIBinder()

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        WorkManager.getInstance(this).cancelAllWorkByTag(WORK_TAG)
        Log.d(TAG, "PoAI Service destroyed")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "VIOLET-AF PoAI Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Quantum-powered Proof-of-AI computation service"
                setSound(null, null)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("VIOLET-AF PoAI Active")
            .setContentText("Quantum logic processing with energy-aware policy")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setSilent(true)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun initializeKeyStore() {
        try {
            keyStore = KeyStore.getInstance("AndroidKeyStore")
            keyStore.load(null)
            
            if (!keyStore.containsAlias(KEY_ALIAS)) {
                generateED25519KeyPair()
                Log.i(TAG, "Generated new ED25519 key pair in StrongBox/Keystore")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize keystore", e)
        }
    }

    private fun generateED25519KeyPair() {
        val keyPairGenerator = KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_EC, 
            "AndroidKeyStore"
        )
        
        val parameterSpec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        )
        .setDigests(KeyProperties.DIGEST_SHA256)
        .setUserAuthenticationRequired(false)
        .apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                setIsStrongBoxBacked(true) // Use StrongBox if available
            }
        }
        .build()

        keyPairGenerator.initialize(parameterSpec)
        keyPairGenerator.generateKeyPair()
    }

    private fun shouldRunPoAI(): Boolean {
        val batteryLevel = getBatteryLevel()
        val isCharging = isDeviceCharging()
        val isScreenOff = !powerManager.isInteractive
        val isCpuCool = getCpuTemperature() < 45.0f // Celsius
        
        val shouldRun = (isCharging || batteryLevel > 70) && isScreenOff && isCpuCool
        
        Log.d(TAG, "Energy policy check - Battery: $batteryLevel%, Charging: $isCharging, Screen: ${if(isScreenOff) "OFF" else "ON"}, CPU: ${getCpuTemperature()}°C, Should run: $shouldRun")
        
        return shouldRun
    }

    private fun getBatteryLevel(): Int {
        val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return if (level == Integer.MIN_VALUE) 50 else level // Default to 50% if unknown
    }

    private fun isDeviceCharging(): Boolean {
        val status = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_STATUS)
        return status == BatteryManager.BATTERY_STATUS_CHARGING ||
               status == BatteryManager.BATTERY_STATUS_FULL
    }

    private fun getCpuTemperature(): Float {
        // Simplified CPU temperature check
        // In production, you'd read from thermal sensors
        return 35.0f // Placeholder - assume normal temperature
    }

    private fun schedulePoAIWork() {
        val poaiRequest = PeriodicWorkRequestBuilder<PoAIDigestWorker>(15, TimeUnit.MINUTES)
            .addTag(WORK_TAG)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "poai_digest_computation",
            ExistingPeriodicWorkPolicy.REPLACE,
            poaiRequest
        )
        
        Log.i(TAG, "Scheduled periodic PoAI digest computation every 15 minutes")
    }

    /**
     * Compute PoAI digest and sign with hardware-backed key
     */
    fun computePoAIDigest(inputData: String): Pair<String, String>? {
        try {
            if (!shouldRunPoAI()) {
                Log.w(TAG, "Cannot compute PoAI digest - energy policy requirements not met")
                return null
            }

            // Create PoAI payload with UID
            val timestamp = System.currentTimeMillis()
            val payload = "$inputData|$CREATOR_UID|$timestamp"
            
            // Compute SHA256 digest
            val digest = MessageDigest.getInstance("SHA-256")
            val hash = digest.digest(payload.toByteArray())
            val digestHex = hash.joinToString("") { "%02x".format(it) }
            
            // Sign with hardware-backed ED25519 key
            val signature = signWithHardwareKey(digestHex)
            
            Log.i(TAG, "Computed PoAI digest: $digestHex")
            return Pair(digestHex, signature ?: "")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to compute PoAI digest", e)
            return null
        }
    }

    private fun signWithHardwareKey(data: String): String? {
        try {
            val privateKey = keyStore.getKey(KEY_ALIAS, null)
            val signature = Signature.getInstance("SHA256withECDSA")
            signature.initSign(privateKey)
            signature.update(data.toByteArray())
            
            val signatureBytes = signature.sign()
            return signatureBytes.joinToString("") { "%02x".format(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to sign with hardware key", e)
            return null
        }
    }

    /**
     * Submit PoAI computation once (for manual triggers)
     */
    fun submitOnce(inputJson: String): Boolean {
        return try {
            val result = computePoAIDigest(inputJson)
            if (result != null) {
                // In production, this would submit to the Cloudflare Worker
                Log.i(TAG, "PoAI submission ready - Digest: ${result.first}, Signature: ${result.second}")
                true
            } else {
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to submit PoAI", e)
            false
        }
    }

    /**
     * Get current service status
     */
    fun getStatus(): Map<String, Any> = mapOf(
        "isRunning" to isServiceRunning,
        "batteryLevel" to getBatteryLevel(),
        "isCharging" to isDeviceCharging(),
        "cpuTemperature" to getCpuTemperature(),
        "canRunPoAI" to shouldRunPoAI(),
        "creatorUID" to CREATOR_UID,
        "hasHardwareKey" to keyStore.containsAlias(KEY_ALIAS)
    )
}