/**
 * Common type definitions for Omni-Chain Proof-of-AI
 * 
 * Author: Andrew Lee Cruz
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * ORCID: 0009-0000-3695-1084
 */

export interface ChainWitness {
  version: string;
  chainId: string;
  blockNumber: number;
  transactionHash: string;
  timestamp: number;
  eventData: any;
  merkleProof?: string[];
  signature: string;
  identity: {
    uid: string;
    orcid: string;
    creator: string;
  };
}

export interface PoAIDigest {
  version: string;
  algorithm: string;
  chainId: string;
  witnessHash: string;
  digest: string;
  timestamp: number;
  metadata: {
    blockNumber: number;
    transactionCount: number;
    computationTime: number;
  };
  identity: {
    uid: string;
    orcid: string;
    creator: string;
  };
}