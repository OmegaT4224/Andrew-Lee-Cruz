"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.evmWatcher = exports.EVMWatcher = void 0;
const ethers_1 = require("ethers");
const events_1 = require("events");
const adapter_1 = require("./common/lib/adapter");
class EVMWatcher extends events_1.EventEmitter {
    constructor(identity = adapter_1.DEFAULT_IDENTITY) {
        super();
        this.provider = null;
        this.wsProvider = null;
        this.isWatching = false;
        this.lastProcessedBlock = 0;
        this.identity = identity;
        console.log(`[EVMWatcher] Initialized for ${this.identity.creator} (${this.identity.uid})`);
    }
    /**
     * Initialize the watcher with RPC endpoint
     */
    async initialize(config) {
        try {
            // Create HTTP provider for standard operations
            this.provider = new ethers_1.ethers.JsonRpcProvider(config.rpcEndpoint);
            // Create WebSocket provider for real-time events if available
            const wsEndpoint = config.rpcEndpoint.replace('http', 'ws');
            try {
                this.wsProvider = new ethers_1.ethers.WebSocketProvider(wsEndpoint);
            }
            catch (error) {
                console.log('[EVMWatcher] WebSocket not available, using polling mode');
            }
            // Get current block number
            const currentBlock = await this.provider.getBlockNumber();
            this.lastProcessedBlock = config.startBlock || currentBlock;
            console.log(`[EVMWatcher] Initialized on chain ${config.chainId}, starting from block ${this.lastProcessedBlock}`);
        }
        catch (error) {
            throw new Error(`Failed to initialize EVM watcher: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Start watching for blockchain events
     */
    async startWatching(config) {
        if (!this.provider) {
            throw new Error('Watcher not initialized');
        }
        this.isWatching = true;
        console.log(`[EVMWatcher] Starting to watch chain ${config.chainId}`);
        if (this.wsProvider) {
            await this.startWebSocketWatching(config);
        }
        else {
            await this.startPollingWatching(config);
        }
    }
    /**
     * Real-time WebSocket watching
     */
    async startWebSocketWatching(config) {
        if (!this.wsProvider)
            return;
        // Listen for new blocks
        this.wsProvider.on('block', async (blockNumber) => {
            if (!this.isWatching)
                return;
            try {
                await this.processBlock(blockNumber, config);
            }
            catch (error) {
                console.error(`[EVMWatcher] Error processing block ${blockNumber}:`, error);
            }
        });
        // Listen for specific contract events if configured
        if (config.contracts && config.eventTopics) {
            for (const contractAddress of config.contracts) {
                for (const topic of config.eventTopics) {
                    const filter = {
                        address: contractAddress,
                        topics: [topic]
                    };
                    this.wsProvider.on(filter, (log) => {
                        this.handleContractEvent(log, config);
                    });
                }
            }
        }
        console.log('[EVMWatcher] WebSocket watching started');
    }
    /**
     * Polling-based watching for networks without WebSocket support
     */
    async startPollingWatching(config) {
        const pollInterval = 5000; // 5 seconds
        const poll = async () => {
            if (!this.isWatching || !this.provider)
                return;
            try {
                const currentBlock = await this.provider.getBlockNumber();
                // Process any new blocks
                for (let blockNum = this.lastProcessedBlock + 1; blockNum <= currentBlock; blockNum++) {
                    await this.processBlock(blockNum, config);
                }
            }
            catch (error) {
                console.error('[EVMWatcher] Polling error:', error);
            }
            // Schedule next poll
            if (this.isWatching) {
                setTimeout(poll, pollInterval);
            }
        };
        // Start polling
        poll();
        console.log('[EVMWatcher] Polling mode started');
    }
    /**
     * Process a specific block
     */
    async processBlock(blockNumber, config) {
        if (!this.provider)
            return;
        try {
            const block = await this.provider.getBlock(blockNumber, true);
            if (!block)
                return;
            // Emit block event
            const blockEvent = {
                chainId: config.chainId,
                blockNumber: block.number,
                transactionHash: '0x' + '0'.repeat(64), // Placeholder for block events
                eventType: 'block',
                data: {
                    hash: block.hash,
                    parentHash: block.parentHash,
                    timestamp: block.timestamp,
                    gasUsed: block.gasUsed,
                    gasLimit: block.gasLimit,
                    transactionCount: block.transactions.length
                },
                timestamp: Date.now(),
                identity: this.identity
            };
            this.emit('event', blockEvent);
            // Process transactions if enabled
            if (config.includeTransactions && block.transactions) {
                for (const tx of block.transactions) {
                    if (typeof tx === 'string')
                        continue; // Skip if just hash
                    const txResponse = tx;
                    const txEvent = {
                        chainId: config.chainId,
                        blockNumber: block.number,
                        transactionHash: txResponse.hash,
                        eventType: 'transaction',
                        data: {
                            from: txResponse.from,
                            to: txResponse.to,
                            value: txResponse.value.toString(),
                            gasPrice: txResponse.gasPrice?.toString(),
                            gasLimit: txResponse.gasLimit.toString(),
                            data: txResponse.data
                        },
                        timestamp: Date.now(),
                        identity: this.identity
                    };
                    this.emit('event', txEvent);
                }
            }
            this.lastProcessedBlock = blockNumber;
        }
        catch (error) {
            console.error(`[EVMWatcher] Error processing block ${blockNumber}:`, error);
        }
    }
    /**
     * Handle specific contract events
     */
    handleContractEvent(log, config) {
        const event = {
            chainId: config.chainId,
            blockNumber: log.blockNumber,
            transactionHash: log.transactionHash,
            eventType: 'contract_event',
            data: {
                address: log.address,
                topics: log.topics,
                data: log.data,
                logIndex: log.index
            },
            timestamp: Date.now(),
            identity: this.identity
        };
        this.emit('event', event);
    }
    /**
     * Stop watching
     */
    async stopWatching() {
        this.isWatching = false;
        if (this.wsProvider) {
            await this.wsProvider.destroy();
            this.wsProvider = null;
        }
        console.log('[EVMWatcher] Stopped watching');
    }
    /**
     * Get current status
     */
    getStatus() {
        return {
            isWatching: this.isWatching,
            lastProcessedBlock: this.lastProcessedBlock,
            hasWebSocket: !!this.wsProvider,
            identity: this.identity
        };
    }
}
exports.EVMWatcher = EVMWatcher;
// Export singleton instance for easy usage
exports.evmWatcher = new EVMWatcher();
//# sourceMappingURL=watcher.js.map