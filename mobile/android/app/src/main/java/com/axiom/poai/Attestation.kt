package com.axiom.poai

import android.content.Context
import android.util.Log
import com.google.android.play.core.integrity.IntegrityManager
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import com.google.android.gms.tasks.Task
import java.security.MessageDigest
import android.os.Build
import android.provider.Settings

/**
 * Device attestation and integrity verification module
 * 
 * Provides Play Integrity attestation and device fingerprinting to prevent spoofing
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */
class Attestation(private val context: Context) {
    
    companion object {
        private const val TAG = "PoAIAttestation"
        private const val NONCE_SEED = "ALC-ROOT-1010-1111-XCOV∞"
    }

    private val integrityManager: IntegrityManager = IntegrityManagerFactory.create(context)

    /**
     * Generate Play Integrity attestation token
     */
    fun generateAttestationToken(callback: (String?) -> Unit) {
        try {
            val nonce = generateNonce()
            val integrityTokenRequest = IntegrityTokenRequest.builder()
                .setNonce(nonce)
                .build()

            integrityManager.requestIntegrityToken(integrityTokenRequest)
                .addOnSuccessListener { response: IntegrityTokenResponse ->
                    val token = response.token()
                    Log.i(TAG, "Play Integrity token generated successfully")
                    callback(token)
                }
                .addOnFailureListener { exception ->
                    Log.e(TAG, "Failed to generate Play Integrity token", exception)
                    callback(null)
                }
        } catch (e: Exception) {
            Log.e(TAG, "Exception during attestation token generation", e)
            callback(null)
        }
    }

    /**
     * Generate device fingerprint for spoofing prevention
     */
    fun getDeviceFingerprint(): DeviceFingerprint {
        return DeviceFingerprint(
            deviceId = getSecureDeviceId(),
            buildFingerprint = Build.FINGERPRINT,
            model = Build.MODEL,
            manufacturer = Build.MANUFACTURER,
            brand = Build.BRAND,
            product = Build.PRODUCT,
            board = Build.BOARD,
            hardware = Build.HARDWARE,
            bootloader = Build.BOOTLOADER,
            androidId = getAndroidId(),
            securityPatch = Build.VERSION.SECURITY_PATCH,
            apiLevel = Build.VERSION.SDK_INT,
            uid = NONCE_SEED
        )
    }

    /**
     * Verify device integrity and authenticity
     */
    fun verifyDeviceIntegrity(): DeviceIntegrityResult {
        val fingerprint = getDeviceFingerprint()
        
        // Check for rooting/tampering indicators
        val isRooted = checkRootingIndicators()
        val isEmulator = checkEmulatorIndicators()
        val hasValidFingerprint = fingerprint.buildFingerprint.isNotEmpty()
        
        val isValid = !isRooted && !isEmulator && hasValidFingerprint
        
        return DeviceIntegrityResult(
            isValid = isValid,
            isRooted = isRooted,
            isEmulator = isEmulator,
            fingerprint = fingerprint,
            timestamp = System.currentTimeMillis()
        )
    }

    /**
     * Create attestation package for PoAI submission
     */
    fun createAttestationPackage(callback: (AttestationPackage?) -> Unit) {
        val integrityResult = verifyDeviceIntegrity()
        
        if (!integrityResult.isValid) {
            Log.w(TAG, "Device integrity check failed")
            callback(null)
            return
        }

        generateAttestationToken { token ->
            if (token != null) {
                val package_ = AttestationPackage(
                    playIntegrityToken = token,
                    deviceFingerprint = integrityResult.fingerprint,
                    integrityResult = integrityResult,
                    createdAt = System.currentTimeMillis(),
                    uid = NONCE_SEED
                )
                callback(package_)
            } else {
                callback(null)
            }
        }
    }

    private fun generateNonce(): String {
        val timestamp = System.currentTimeMillis().toString()
        val input = "$NONCE_SEED:$timestamp"
        
        val digest = MessageDigest.getInstance("SHA-256")
        val hash = digest.digest(input.toByteArray())
        return hash.joinToString("") { "%02x".format(it) }
    }

    private fun getSecureDeviceId(): String {
        return try {
            // Create a stable device identifier without using sensitive data
            val components = listOf(
                Build.FINGERPRINT,
                Build.BOARD,
                Build.HARDWARE,
                Build.MANUFACTURER,
                Build.MODEL
            ).joinToString("|")
            
            val digest = MessageDigest.getInstance("SHA-256")
            val hash = digest.digest(components.toByteArray())
            hash.joinToString("") { "%02x".format(it) }.take(16)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to generate secure device ID", e)
            "unknown_device"
        }
    }

    private fun getAndroidId(): String {
        return try {
            Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID) ?: ""
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get Android ID", e)
            ""
        }
    }

    private fun checkRootingIndicators(): Boolean {
        // Simple rooting detection - in production, use a comprehensive library
        val rootIndicators = listOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/data/data/com.noshufou.android.su"
        )
        
        return rootIndicators.any { java.io.File(it).exists() }
    }

    private fun checkEmulatorIndicators(): Boolean {
        // Simple emulator detection
        return Build.FINGERPRINT.startsWith("generic") ||
               Build.FINGERPRINT.startsWith("unknown") ||
               Build.MODEL.contains("google_sdk") ||
               Build.MODEL.contains("Emulator") ||
               Build.MODEL.contains("Android SDK") ||
               Build.MANUFACTURER.contains("Genymotion") ||
               Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
    }
}

/**
 * Data classes for attestation results
 */
data class DeviceFingerprint(
    val deviceId: String,
    val buildFingerprint: String,
    val model: String,
    val manufacturer: String,
    val brand: String,
    val product: String,
    val board: String,
    val hardware: String,
    val bootloader: String,
    val androidId: String,
    val securityPatch: String,
    val apiLevel: Int,
    val uid: String
)

data class DeviceIntegrityResult(
    val isValid: Boolean,
    val isRooted: Boolean,
    val isEmulator: Boolean,
    val fingerprint: DeviceFingerprint,
    val timestamp: Long
)

data class AttestationPackage(
    val playIntegrityToken: String,
    val deviceFingerprint: DeviceFingerprint,
    val integrityResult: DeviceIntegrityResult,
    val createdAt: Long,
    val uid: String
)