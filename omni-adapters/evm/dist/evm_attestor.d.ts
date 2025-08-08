/**
 * EVM Attestor - On-chain assertion and digest submission
 * Handles submitting Proof-of-AI digests to EVM-compatible blockchains
 *
 * Author: Andrew Lee Cruz
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * ORCID: 0009-0000-3695-1084
 *
 * Universal Creator License (UCL-∞)
 * All rights reserved. Protected by blockchain provenance.
 */
import { ethers } from 'ethers';
import { PoAIDigest, ChainWitness } from './common/types';
import { AssertionConfig, AssertionResult, SubmitConfig, SubmissionResult, DigestConfig, ProvenanceIdentity } from './common/lib/adapter';
export interface EVMAttestorConfig {
    contractAddress?: string;
    gasLimit?: number;
    gasPrice?: string;
    privateKey?: string;
    walletAddress?: string;
}
export declare class EVMAttestor {
    private provider;
    private signer;
    private contract;
    private readonly identity;
    constructor(identity?: ProvenanceIdentity);
    /**
     * Initialize the attestor with provider and signer
     */
    initialize(rpcEndpoint: string, config?: EVMAttestorConfig): Promise<void>;
    /**
     * Compute Proof-of-AI digest from witness data
     */
    computeDigest(witness: ChainWitness, config: DigestConfig): Promise<PoAIDigest>;
    /**
     * Submit digest to external system or registry
     */
    submit(digest: PoAIDigest, config: SubmitConfig): Promise<SubmissionResult>;
    /**
     * Assert digest on-chain via smart contract
     */
    assertOnChain(digest: PoAIDigest, config: AssertionConfig): Promise<AssertionResult>;
    /**
     * Compute hash of witness data
     */
    private computeWitnessHash;
    /**
     * Compute digest using specified algorithm
     */
    private computeDigestByAlgorithm;
    /**
     * Get attestor status
     */
    getStatus(): {
        initialized: boolean;
        hasSigner: boolean;
        hasContract: boolean;
        signerAddress: string | undefined;
        contractAddress: string | ethers.Addressable | undefined;
        supportedAlgorithms: string[];
        identity: ProvenanceIdentity;
    };
}
export declare const evmAttestor: EVMAttestor;
//# sourceMappingURL=evm_attestor.d.ts.map