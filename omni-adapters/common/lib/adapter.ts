/**
 * Omni-Adapter Interface for Omni-Chain Proof-of-AI Overlays
 * 
 * Author: Andrew Lee Cruz
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * ORCID: 0009-0000-3695-1084
 * 
 * Universal Creator License (UCL-∞)
 * All rights reserved. This work is protected by blockchain provenance.
 */

import { ChainWitness, PoAIDigest } from '../types';

export interface ProvenanceIdentity {
  uid: string;
  orcid: string;
  creator: string;
  timestamp: number;
}

export interface WatcherConfig {
  chainId: string;
  rpcEndpoint: string;
  startBlock?: number;
  batchSize?: number;
  identity: ProvenanceIdentity;
}

export interface WitnessBuilderConfig {
  chainId: string;
  witnessType: string;
  identity: ProvenanceIdentity;
}

export interface DigestConfig {
  algorithm: string;
  version: string;
  identity: ProvenanceIdentity;
}

export interface SubmitConfig {
  targetChain: string;
  endpoint: string;
  identity: ProvenanceIdentity;
}

export interface AssertionConfig {
  contractAddress?: string;
  gasLimit?: number;
  identity: ProvenanceIdentity;
}

/**
 * Core OmniAdapter interface that all chain-specific adapters must implement
 */
export interface OmniAdapter {
  /**
   * Chain identifier (e.g., 'ethereum', 'solana', 'cosmos')
   */
  readonly chainId: string;

  /**
   * Identity and provenance information
   */
  readonly identity: ProvenanceIdentity;

  /**
   * Initialize the adapter with configuration
   */
  initialize(config: WatcherConfig): Promise<void>;

  /**
   * Watch for relevant blockchain events and transactions
   */
  watch(callback: (event: ChainEvent) => void): Promise<void>;

  /**
   * Stop watching
   */
  stopWatching(): Promise<void>;

  /**
   * Build a witness from observed chain data
   */
  buildWitness(event: ChainEvent, config: WitnessBuilderConfig): Promise<ChainWitness>;

  /**
   * Compute Proof-of-AI digest from witness data
   */
  computeDigest(witness: ChainWitness, config: DigestConfig): Promise<PoAIDigest>;

  /**
   * Submit digest to target chain or system
   */
  submit(digest: PoAIDigest, config: SubmitConfig): Promise<SubmissionResult>;

  /**
   * Optional: Assert on-chain proof (for chains that support smart contracts)
   */
  assertOnChain?(digest: PoAIDigest, config: AssertionConfig): Promise<AssertionResult>;

  /**
   * Get adapter status and metrics
   */
  getStatus(): AdapterStatus;
}

export interface ChainEvent {
  chainId: string;
  blockNumber: number;
  transactionHash: string;
  eventType: string;
  data: any;
  timestamp: number;
  identity: ProvenanceIdentity;
}

export interface SubmissionResult {
  success: boolean;
  transactionHash?: string;
  error?: string;
  timestamp: number;
  identity: ProvenanceIdentity;
}

export interface AssertionResult {
  success: boolean;
  contractAddress: string;
  transactionHash: string;
  gasUsed?: number;
  timestamp: number;
  identity: ProvenanceIdentity;
}

export interface AdapterStatus {
  chainId: string;
  isRunning: boolean;
  lastProcessedBlock: number;
  eventsProcessed: number;
  digestsComputed: number;
  submissionsSuccessful: number;
  errors: number;
  uptime: number;
  identity: ProvenanceIdentity;
}

/**
 * Factory function to create chain-specific adapters
 */
export interface AdapterFactory {
  createAdapter(chainId: string, identity: ProvenanceIdentity): OmniAdapter;
  getSupportedChains(): string[];
}

/**
 * Default provenance identity for Andrew Lee Cruz
 */
export const DEFAULT_IDENTITY: ProvenanceIdentity = {
  uid: 'ALC-ROOT-1010-1111-XCOV∞',
  orcid: '0009-0000-3695-1084',
  creator: 'Andrew Lee Cruz',
  timestamp: Date.now()
};

/**
 * Utility functions for common operations
 */
export class AdapterUtils {
  static createIdentity(overrides: Partial<ProvenanceIdentity> = {}): ProvenanceIdentity {
    return {
      ...DEFAULT_IDENTITY,
      ...overrides,
      timestamp: Date.now()
    };
  }

  static validateIdentity(identity: ProvenanceIdentity): boolean {
    return !!(identity.uid && identity.orcid && identity.creator);
  }

  static formatChainId(chainId: string): string {
    return chainId.toLowerCase().trim();
  }
}