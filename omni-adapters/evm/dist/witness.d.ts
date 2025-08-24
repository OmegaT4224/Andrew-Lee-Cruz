/**
 * EVM Chain Witness Builder
 * Constructs cryptographically verifiable witnesses from EVM chain events
 *
 * Author: Andrew Lee Cruz
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * ORCID: 0009-0000-3695-1084
 *
 * Universal Creator License (UCL-∞)
 * All rights reserved. Protected by blockchain provenance.
 */
import { ChainWitness } from './common/types';
import { ChainEvent, WitnessBuilderConfig, ProvenanceIdentity } from './common/lib/adapter';
export interface EVMWitnessConfig extends WitnessBuilderConfig {
    includeReceiptProof?: boolean;
    includeMerkleProof?: boolean;
    signatureMethod?: 'ecdsa' | 'ecdsa_recoverable';
}
export declare class EVMWitnessBuilder {
    private provider;
    private readonly identity;
    constructor(identity?: ProvenanceIdentity);
    /**
     * Initialize with provider
     */
    initialize(rpcEndpoint: string): Promise<void>;
    /**
     * Build a chain witness from an EVM event
     */
    buildWitness(event: ChainEvent, config: EVMWitnessConfig): Promise<ChainWitness>;
    /**
     * Generate a simplified Merkle proof for transaction inclusion
     */
    private generateMerkleProof;
    /**
     * Create a deterministic hash of witness data
     */
    private createWitnessHash;
    /**
     * Sign the witness hash (simplified implementation)
     */
    private signWitness;
    /**
     * Verify a witness signature
     */
    verifyWitness(witness: ChainWitness): Promise<boolean>;
    /**
     * Get witness builder status
     */
    getStatus(): {
        initialized: boolean;
        identity: ProvenanceIdentity;
        supportedMethods: string[];
        capabilities: {
            merkleProofs: boolean;
            receiptProofs: boolean;
            stateProofs: boolean;
        };
    };
}
export declare const evmWitnessBuilder: EVMWitnessBuilder;
//# sourceMappingURL=witness.d.ts.map