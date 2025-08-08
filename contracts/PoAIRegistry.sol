// SPDX-License-Identifier: UCL-∞
pragma solidity ^0.8.20;

/**
 * PoAI Registry Contract
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * Contact: allcatch37@gmail.com
 * 
 * Establishes cryptographic provenance for AI-generated content
 * and autonomous agent operations
 */

contract PoAIRegistry {
    string public constant CREATOR_UID = "ALC-ROOT-1010-1111-XCOV\u221E";
    address public constant CREATOR_ADDRESS = 0x742E464Ea2dA75fBdCc1B76f4a7d625F2d96A222;
    
    struct PoAIProof {
        string uid;           // Creator UID
        bytes32 contentHash;  // SHA3-256 of content
        bytes signature;      // HMAC signature with ReflectChain key
        uint256 timestamp;    // Block timestamp
        address creator;      // Creator address
        string proofType;     // Type: quantum_execution, github_operation, etc.
        string metadata;      // Additional metadata JSON
    }
    
    mapping(bytes32 => PoAIProof) public proofs;
    mapping(string => bytes32[]) public uidProofs; // UID -> proof IDs
    
    event ProofRegistered(
        bytes32 indexed proofId,
        string indexed uid,
        string proofType,
        address creator
    );
    
    event ProofVerified(
        bytes32 indexed proofId,
        bool valid,
        address verifier
    );
    
    modifier onlyCreator() {
        require(msg.sender == CREATOR_ADDRESS, "Only creator can perform this action");
        _;
    }
    
    /**
     * Register a new PoAI proof
     */
    function registerProof(
        string memory uid,
        bytes32 contentHash,
        bytes memory signature,
        string memory proofType,
        string memory metadata
    ) external returns (bytes32 proofId) {
        // Verify creator UID
        require(
            keccak256(abi.encodePacked(uid)) == keccak256(abi.encodePacked(CREATOR_UID)),
            "Invalid creator UID"
        );
        
        // Generate proof ID
        proofId = keccak256(abi.encodePacked(
            uid, contentHash, signature, block.timestamp, msg.sender
        ));
        
        // Store proof
        proofs[proofId] = PoAIProof({
            uid: uid,
            contentHash: contentHash,
            signature: signature,
            timestamp: block.timestamp,
            creator: msg.sender,
            proofType: proofType,
            metadata: metadata
        });
        
        // Index by UID
        uidProofs[uid].push(proofId);
        
        emit ProofRegistered(proofId, uid, proofType, msg.sender);
        
        return proofId;
    }
    
    /**
     * Verify a PoAI proof exists and is valid
     */
    function verifyProof(bytes32 proofId) external view returns (bool valid) {
        PoAIProof memory proof = proofs[proofId];
        
        // Check if proof exists
        if (proof.timestamp == 0) {
            return false;
        }
        
        // Verify UID matches creator
        if (keccak256(abi.encodePacked(proof.uid)) != keccak256(abi.encodePacked(CREATOR_UID))) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Get proof details
     */
    function getProof(bytes32 proofId) external view returns (PoAIProof memory) {
        return proofs[proofId];
    }
    
    /**
     * Get all proof IDs for a UID
     */
    function getProofsByUID(string memory uid) external view returns (bytes32[] memory) {
        return uidProofs[uid];
    }
    
    /**
     * Get proof count for creator UID
     */
    function getCreatorProofCount() external view returns (uint256) {
        return uidProofs[CREATOR_UID].length;
    }
    
    /**
     * Emergency functions - creator only
     */
    function emergencyPause() external onlyCreator {
        // Emergency pause functionality can be added here
    }
    
    /**
     * Register quantum execution proof
     */
    function registerQuantumProof(
        string memory sequenceId,
        bytes32 circuitHash,
        bytes32 stateHash,
        bytes memory signature
    ) external returns (bytes32 proofId) {
        string memory metadata = string(abi.encodePacked(
            '{"sequence_id":"', sequenceId, '","circuit_hash":"', 
            toHexString(circuitHash), '","state_hash":"', toHexString(stateHash), '"}'
        ));
        
        bytes32 contentHash = keccak256(abi.encodePacked(
            sequenceId, circuitHash, stateHash
        ));
        
        return registerProof(
            CREATOR_UID,
            contentHash,
            signature,
            "quantum_execution",
            metadata
        );
    }
    
    /**
     * Utility function to convert bytes32 to hex string
     */
    function toHexString(bytes32 data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i*2] = alphabet[uint8(data[i] >> 4)];
            str[1+i*2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}