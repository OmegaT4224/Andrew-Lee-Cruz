/**
 * EVM Blockchain Watcher
 * Monitors EVM-compatible chains for relevant events and transactions
 *
 * Author: Andrew Lee Cruz
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * ORCID: 0009-0000-3695-1084
 *
 * Universal Creator License (UCL-∞)
 * All rights reserved. Protected by blockchain provenance.
 */
import { EventEmitter } from 'events';
import { ProvenanceIdentity, WatcherConfig } from './common/lib/adapter';
export interface EVMWatcherConfig extends WatcherConfig {
    contracts?: string[];
    eventTopics?: string[];
    includeTransactions?: boolean;
}
export declare class EVMWatcher extends EventEmitter {
    private provider;
    private wsProvider;
    private isWatching;
    private lastProcessedBlock;
    private readonly identity;
    constructor(identity?: ProvenanceIdentity);
    /**
     * Initialize the watcher with RPC endpoint
     */
    initialize(config: EVMWatcherConfig): Promise<void>;
    /**
     * Start watching for blockchain events
     */
    startWatching(config: EVMWatcherConfig): Promise<void>;
    /**
     * Real-time WebSocket watching
     */
    private startWebSocketWatching;
    /**
     * Polling-based watching for networks without WebSocket support
     */
    private startPollingWatching;
    /**
     * Process a specific block
     */
    private processBlock;
    /**
     * Handle specific contract events
     */
    private handleContractEvent;
    /**
     * Stop watching
     */
    stopWatching(): Promise<void>;
    /**
     * Get current status
     */
    getStatus(): {
        isWatching: boolean;
        lastProcessedBlock: number;
        hasWebSocket: boolean;
        identity: ProvenanceIdentity;
    };
}
export declare const evmWatcher: EVMWatcher;
//# sourceMappingURL=watcher.d.ts.map