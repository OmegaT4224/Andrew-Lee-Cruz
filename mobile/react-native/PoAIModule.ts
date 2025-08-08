import { NativeModules, NativeEventEmitter } from 'react-native';

const { PoAIModule } = NativeModules;

/**
 * VIOLET-AF PoAI React Native Bridge
 * 
 * Cross-platform interface for PoAI functionality
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */

export interface PoAIStatus {
  isRunning: boolean;
  batteryLevel: number;
  isCharging: boolean;
  cpuTemperature: number;
  canRunPoAI: boolean;
  creatorUID: string;
  hasHardwareKey: boolean;
}

export interface PoAIResult {
  success: boolean;
  digest?: string;
  signature?: string;
  error?: string;
}

export interface AttestationData {
  deviceFingerprint: string;
  playIntegrityToken?: string;
  isValid: boolean;
  timestamp: number;
}

class PoAINativeModule {
  private eventEmitter: NativeEventEmitter;
  
  constructor() {
    this.eventEmitter = new NativeEventEmitter(PoAIModule);
  }

  /**
   * Start the PoAI service
   */
  async start(): Promise<boolean> {
    try {
      return await PoAIModule.start();
    } catch (error) {
      console.error('Failed to start PoAI service:', error);
      return false;
    }
  }

  /**
   * Stop the PoAI service
   */
  async stop(): Promise<boolean> {
    try {
      return await PoAIModule.stop();
    } catch (error) {
      console.error('Failed to stop PoAI service:', error);
      return false;
    }
  }

  /**
   * Get current PoAI service status
   */
  async status(): Promise<PoAIStatus | null> {
    try {
      return await PoAIModule.getStatus();
    } catch (error) {
      console.error('Failed to get PoAI status:', error);
      return null;
    }
  }

  /**
   * Submit a single PoAI computation
   */
  async submitOnce(inputJson: string): Promise<PoAIResult> {
    try {
      const result = await PoAIModule.submitOnce(inputJson);
      return {
        success: true,
        digest: result.digest,
        signature: result.signature
      };
    } catch (error) {
      console.error('Failed to submit PoAI:', error);
      return {
        success: false,
        error: error.message || 'Unknown error'
      };
    }
  }

  /**
   * Generate device attestation
   */
  async generateAttestation(): Promise<AttestationData | null> {
    try {
      return await PoAIModule.generateAttestation();
    } catch (error) {
      console.error('Failed to generate attestation:', error);
      return null;
    }
  }

  /**
   * Check if device meets energy policy requirements
   */
  async checkEnergyPolicy(): Promise<boolean> {
    try {
      return await PoAIModule.checkEnergyPolicy();
    } catch (error) {
      console.error('Failed to check energy policy:', error);
      return false;
    }
  }

  /**
   * Get device capabilities and hardware info
   */
  async getDeviceCapabilities(): Promise<{
    hasStrongBox: boolean;
    hasHardwareKeystore: boolean;
    supportsPlayIntegrity: boolean;
    energyAware: boolean;
  } | null> {
    try {
      return await PoAIModule.getDeviceCapabilities();
    } catch (error) {
      console.error('Failed to get device capabilities:', error);
      return null;
    }
  }

  /**
   * Subscribe to PoAI service events
   */
  onPoAIEvent(callback: (event: {
    type: 'status_changed' | 'computation_complete' | 'energy_policy_updated';
    data: any;
  }) => void): () => void {
    const subscription = this.eventEmitter.addListener('PoAIEvent', callback);
    return () => subscription.remove();
  }

  /**
   * Subscribe to energy policy changes
   */
  onEnergyPolicyChange(callback: (canRun: boolean, details: {
    batteryLevel: number;
    isCharging: boolean;
    screenOff: boolean;
    cpuCool: boolean;
  }) => void): () => void {
    const subscription = this.eventEmitter.addListener('EnergyPolicyChange', (event) => {
      callback(event.canRun, event.details);
    });
    return () => subscription.remove();
  }

  /**
   * Get PoAI computation history (last 10 entries)
   */
  async getComputationHistory(): Promise<Array<{
    timestamp: number;
    digest: string;
    energyCompliant: boolean;
    batteryLevel: number;
  }> | null> {
    try {
      return await PoAIModule.getComputationHistory();
    } catch (error) {
      console.error('Failed to get computation history:', error);
      return null;
    }
  }

  /**
   * Force a single PoAI computation (ignores energy policy for testing)
   */
  async forceComputation(inputJson: string, bypassEnergyPolicy: boolean = false): Promise<PoAIResult> {
    try {
      const result = await PoAIModule.forceComputation(inputJson, bypassEnergyPolicy);
      return {
        success: true,
        digest: result.digest,
        signature: result.signature
      };
    } catch (error) {
      console.error('Failed to force computation:', error);
      return {
        success: false,
        error: error.message || 'Unknown error'
      };
    }
  }
}

// Export singleton instance
export const PoAI = new PoAINativeModule();

// Export types
export default PoAI;

// Constants
export const POAI_CONSTANTS = {
  CREATOR_UID: 'ALC-ROOT-1010-1111-XCOV∞',
  CREATOR_EMAIL: 'allcatch37@gmail.com',
  ENERGY_POLICY: {
    MIN_BATTERY_LEVEL: 70,
    REQUIRE_CHARGING_OR_HIGH_BATTERY: true,
    REQUIRE_SCREEN_OFF: true,
    MAX_CPU_TEMPERATURE: 45.0
  },
  SERVICE_CONFIG: {
    WORK_INTERVAL_MINUTES: 15,
    NOTIFICATION_CHANNEL: 'poai_service_channel',
    FOREGROUND_SERVICE_ID: 1001
  }
};

/**
 * Utility functions for PoAI integration
 */
export const PoAIUtils = {
  /**
   * Format PoAI status for display
   */
  formatStatus: (status: PoAIStatus): string => {
    return `PoAI Service: ${status.isRunning ? 'ACTIVE' : 'INACTIVE'} | ` +
           `Battery: ${status.batteryLevel}% ${status.isCharging ? '(Charging)' : ''} | ` +
           `CPU: ${status.cpuTemperature}°C | ` +
           `Energy Policy: ${status.canRunPoAI ? 'COMPLIANT' : 'NON-COMPLIANT'}`;
  },

  /**
   * Check if current conditions meet energy policy
   */
  meetsEnergyPolicy: (status: PoAIStatus): boolean => {
    const { batteryLevel, isCharging, cpuTemperature } = status;
    return (isCharging || batteryLevel > POAI_CONSTANTS.ENERGY_POLICY.MIN_BATTERY_LEVEL) &&
           cpuTemperature < POAI_CONSTANTS.ENERGY_POLICY.MAX_CPU_TEMPERATURE;
  },

  /**
   * Create test input for PoAI computation
   */
  createTestInput: (testType: 'basic' | 'quantum' | 'stress'): string => {
    const baseInput = {
      uid: POAI_CONSTANTS.CREATOR_UID,
      timestamp: Date.now(),
      testType,
      deviceId: 'react-native-bridge'
    };

    switch (testType) {
      case 'quantum':
        return JSON.stringify({
          ...baseInput,
          quantumState: '|0⟩ + |1⟩',
          entanglement: true,
          measurements: 1024
        });
      case 'stress':
        return JSON.stringify({
          ...baseInput,
          iterations: 10000,
          complexity: 'high',
          vector: Array(256).fill(0).map(() => Math.random())
        });
      default:
        return JSON.stringify(baseInput);
    }
  }
};