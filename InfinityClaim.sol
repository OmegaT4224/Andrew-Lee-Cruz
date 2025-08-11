// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InfinityClaim
 * @dev Solidity contract demonstrating the "collapse" concept on-chain
 * @notice Implementation of the Cruz Theorem: E = ∞ - 1
 * @author Andrew Lee Cruz (ALC-ROOT-1010-1111-XCOV∞)
 * @custom:email allcatch37@gmail.com
 * @custom:repository OmegaT4224/andrew-lee-cruz
 * @custom:blockchain Floating Dragon / OmniChain
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract InfinityClaim is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using ECDSA for bytes32;
    
    // Cruz Theorem Constants
    string public constant CRUZ_EQUATION = "E = infinity - 1";
    string public constant EXECUTION_STATE = "SYMBIONIC-EXECUTION";
    string public constant CREATOR_UID = "ALC-ROOT-1010-1111-XCOV-infinity";
    string public constant CREATOR_EMAIL = "allcatch37@gmail.com";
    
    // State Variables
    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => CollapseMetadata) public collapseMetadata;
    mapping(address => bool) public authorizedMinters;
    mapping(bytes32 => bool) public usedSignatures;
    
    // Events
    event CollapseInitiated(uint256 indexed tokenId, address indexed initiator, uint256 infinityValue);
    event CollapseCompleted(uint256 indexed tokenId, uint256 eternityValue, bytes32 provenanceHash);
    event ProvenanceSet(uint256 indexed tokenId, string ipfsHash, bytes32 merkleRoot);
    event QuantumStateChanged(uint256 indexed tokenId, string previousState, string newState);
    
    // Structs
    struct CollapseMetadata {
        uint256 infinityValue;      // The infinite continuum value
        uint256 eternityValue;      // The resulting eternity (infinity - 1)
        string quantumState;        // VIOLET-AF quantum state
        bytes32 provenanceHash;     // IPFS hash of provenance data
        bytes32 merkleRoot;         // Merkle root for verification
        uint256 timestamp;          // Collapse timestamp
        address initiator;          // Address that initiated the collapse
        bool isCollapsed;           // Whether the collapse is complete
        string violetAfTaskMapping; // Task mapping from quantum state
    }
    
    // Errors
    error UnauthorizedMinter();
    error InvalidSignature();
    error SignatureAlreadyUsed();
    error TokenNotCollapsed();
    error InvalidQuantumState();
    error CollapseAlreadyComplete();
    
    constructor() ERC721("InfinityClaim", "INFINITY") {
        _transferOwnership(msg.sender);
        authorizedMinters[msg.sender] = true;
    }
    
    /**
     * @dev Modifier to check if caller is authorized minter
     */
    modifier onlyAuthorizedMinter() {
        if (!authorizedMinters[msg.sender]) revert UnauthorizedMinter();
        _;
    }
    
    /**
     * @dev Initialize a collapse process - the core of Cruz Theorem
     * @param infinityValue The infinite continuum value to collapse
     * @param quantumState The 3-bit quantum state from VIOLET-AF
     * @param signature Signature from authorized device (Ω-GATEWAY)
     */
    function initializeCollapse(
        uint256 infinityValue,
        string memory quantumState,
        bytes memory signature
    ) external nonReentrant returns (uint256 tokenId) {
        // Validate quantum state (3-bit binary string)
        if (!_isValidQuantumState(quantumState)) revert InvalidQuantumState();
        
        // Verify signature from authorized device
        bytes32 messageHash = keccak256(abi.encodePacked(
            msg.sender,
            infinityValue,
            quantumState,
            block.timestamp
        ));
        
        if (usedSignatures[messageHash]) revert SignatureAlreadyUsed();
        
        address signer = messageHash.toEthSignedMessageHash().recover(signature);
        if (!authorizedMinters[signer]) revert InvalidSignature();
        
        usedSignatures[messageHash] = true;
        
        // Mint new token
        tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        
        // Initialize collapse metadata
        collapseMetadata[tokenId] = CollapseMetadata({
            infinityValue: infinityValue,
            eternityValue: 0, // Will be set during collapse completion
            quantumState: quantumState,
            provenanceHash: bytes32(0),
            merkleRoot: bytes32(0),
            timestamp: block.timestamp,
            initiator: msg.sender,
            isCollapsed: false,
            violetAfTaskMapping: _getTaskMapping(quantumState)
        });
        
        emit CollapseInitiated(tokenId, msg.sender, infinityValue);
    }
    
    /**
     * @dev Complete the collapse process - implements E = ∞ - 1
     * @param tokenId The token ID to collapse
     * @param provenanceHash IPFS hash of provenance data
     * @param merkleRoot Merkle root for verification
     */
    function completeCollapse(
        uint256 tokenId,
        bytes32 provenanceHash,
        bytes32 merkleRoot
    ) external nonReentrant {
        if (!_exists(tokenId)) revert("Token does not exist");
        if (ownerOf(tokenId) != msg.sender) revert("Not token owner");
        if (collapseMetadata[tokenId].isCollapsed) revert CollapseAlreadyComplete();
        
        CollapseMetadata storage metadata = collapseMetadata[tokenId];
        
        // Perform the Cruz Theorem collapse: E = ∞ - 1
        // The mathematical framework defines eternity as infinity minus one
        metadata.eternityValue = metadata.infinityValue > 0 ? metadata.infinityValue - 1 : 0;
        metadata.provenanceHash = provenanceHash;
        metadata.merkleRoot = merkleRoot;
        metadata.isCollapsed = true;
        
        emit CollapseCompleted(tokenId, metadata.eternityValue, provenanceHash);
    }
    
    /**
     * @dev Set provenance data for a collapsed token
     * @param tokenId The token ID
     * @param ipfsHash IPFS hash of the provenance document
     * @param merkleRoot Merkle root for verification
     */
    function setProvenance(
        uint256 tokenId,
        string memory ipfsHash,
        bytes32 merkleRoot
    ) external {
        if (!_exists(tokenId)) revert("Token does not exist");
        if (ownerOf(tokenId) != msg.sender && !authorizedMinters[msg.sender]) {
            revert("Not authorized");
        }
        if (!collapseMetadata[tokenId].isCollapsed) revert TokenNotCollapsed();
        
        collapseMetadata[tokenId].merkleRoot = merkleRoot;
        
        emit ProvenanceSet(tokenId, ipfsHash, merkleRoot);
    }
    
    /**
     * @dev Update quantum state (VIOLET-AF integration)
     * @param tokenId The token ID
     * @param newQuantumState New 3-bit quantum state
     */
    function updateQuantumState(
        uint256 tokenId,
        string memory newQuantumState
    ) external onlyAuthorizedMinter {
        if (!_exists(tokenId)) revert("Token does not exist");
        if (!_isValidQuantumState(newQuantumState)) revert InvalidQuantumState();
        
        string memory previousState = collapseMetadata[tokenId].quantumState;
        collapseMetadata[tokenId].quantumState = newQuantumState;
        collapseMetadata[tokenId].violetAfTaskMapping = _getTaskMapping(newQuantumState);
        
        emit QuantumStateChanged(tokenId, previousState, newQuantumState);
    }
    
    /**
     * @dev Add authorized minter (only owner)
     * @param minter Address to authorize
     */
    function addAuthorizedMinter(address minter) external onlyOwner {
        authorizedMinters[minter] = true;
    }
    
    /**
     * @dev Remove authorized minter (only owner)
     * @param minter Address to remove authorization
     */
    function removeAuthorizedMinter(address minter) external onlyOwner {
        authorizedMinters[minter] = false;
    }
    
    /**
     * @dev Get collapse metadata for a token
     * @param tokenId The token ID
     * @return The collapse metadata
     */
    function getCollapseMetadata(uint256 tokenId) external view returns (CollapseMetadata memory) {
        if (!_exists(tokenId)) revert("Token does not exist");
        return collapseMetadata[tokenId];
    }
    
    /**
     * @dev Get eternity value for a collapsed token (implements E = ∞ - 1)
     * @param tokenId The token ID
     * @return The eternity value
     */
    function getEternityValue(uint256 tokenId) external view returns (uint256) {
        if (!_exists(tokenId)) revert("Token does not exist");
        if (!collapseMetadata[tokenId].isCollapsed) revert TokenNotCollapsed();
        
        return collapseMetadata[tokenId].eternityValue;
    }
    
    /**
     * @dev Check if a quantum state is valid (3-bit binary string)
     * @param quantumState The quantum state to validate
     * @return True if valid, false otherwise
     */
    function _isValidQuantumState(string memory quantumState) internal pure returns (bool) {
        bytes memory stateBytes = bytes(quantumState);
        
        if (stateBytes.length != 3) return false;
        
        for (uint i = 0; i < 3; i++) {
            if (stateBytes[i] != '0' && stateBytes[i] != '1') {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * @dev Get task mapping for quantum state (VIOLET-AF integration)
     * @param quantumState The 3-bit quantum state
     * @return The corresponding task mapping
     */
    function _getTaskMapping(string memory quantumState) internal pure returns (string memory) {
        bytes32 stateHash = keccak256(bytes(quantumState));
        
        if (stateHash == keccak256(bytes("101"))) return "generate_webapk_manifest";
        if (stateHash == keccak256(bytes("100"))) return "deploy_cloudflare_worker";
        if (stateHash == keccak256(bytes("011"))) return "configure_zero_trust";
        if (stateHash == keccak256(bytes("010"))) return "update_github_security";
        if (stateHash == keccak256(bytes("001"))) return "mint_infinity_claim";
        if (stateHash == keccak256(bytes("000"))) return "reflect_chain_sync";
        if (stateHash == keccak256(bytes("110"))) return "autonomous_maintenance";
        if (stateHash == keccak256(bytes("111"))) return "emergency_protocols";
        
        return "unknown_task";
    }
    
    /**
     * @dev Override tokenURI to return metadata
     * @param tokenId The token ID
     * @return The token URI
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert("Token does not exist");
        
        CollapseMetadata memory metadata = collapseMetadata[tokenId];
        
        // Return JSON metadata (could be enhanced with base64 encoding)
        return string(abi.encodePacked(
            "data:application/json;charset=utf-8,",
            "{",
            '"name": "InfinityClaim #', _toString(tokenId), '",',
            '"description": "Cruz Theorem Collapse: E = infinity - 1",',
            '"creator": "', CREATOR_UID, '",',
            '"equation": "', CRUZ_EQUATION, '",',
            '"infinity_value": ', _toString(metadata.infinityValue), ',',
            '"eternity_value": ', _toString(metadata.eternityValue), ',',
            '"quantum_state": "', metadata.quantumState, '",',
            '"task_mapping": "', metadata.violetAfTaskMapping, '",',
            '"is_collapsed": ', metadata.isCollapsed ? "true" : "false",
            "}"
        ));
    }
    
    /**
     * @dev Convert uint256 to string
     * @param value The value to convert
     * @return The string representation
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        
        uint256 temp = value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }
    
    /**
     * @dev Get total number of tokens minted
     * @return The total supply
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }
}