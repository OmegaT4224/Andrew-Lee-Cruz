"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdapterUtils = exports.DEFAULT_IDENTITY = void 0;
/**
 * Default provenance identity for Andrew Lee Cruz
 */
exports.DEFAULT_IDENTITY = {
    uid: 'ALC-ROOT-1010-1111-XCOV∞',
    orcid: '0009-0000-3695-1084',
    creator: 'Andrew Lee Cruz',
    timestamp: Date.now()
};
/**
 * Utility functions for common operations
 */
class AdapterUtils {
    static createIdentity(overrides = {}) {
        return {
            ...exports.DEFAULT_IDENTITY,
            ...overrides,
            timestamp: Date.now()
        };
    }
    static validateIdentity(identity) {
        return !!(identity.uid && identity.orcid && identity.creator);
    }
    static formatChainId(chainId) {
        return chainId.toLowerCase().trim();
    }
}
exports.AdapterUtils = AdapterUtils;
//# sourceMappingURL=adapter.js.map