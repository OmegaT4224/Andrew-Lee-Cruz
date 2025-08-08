// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AXIOM_TOE_Anchor
 * @dev ERC-721 anchor pinning bundle hash/CID + UID for OmegaT Builder
 * @author Andrew Lee Cruz <allcatch37@gmail.com>
 * @notice UID: ALC-ROOT-1010-1111-XCOV∞
 */
contract AXIOM_TOE_Anchor is ERC721, Ownable {
    string public constant CREATOR_UID = "ALC-ROOT-1010-1111-XCOV∞";
    string public constant VERSION = "1.0.0";
    
    struct AnchorData {
        string bundleHash;  // IPFS hash or CID
        string uid;         // Creator UID
        string projectName;
        uint256 timestamp;
        string metadata;    // Additional JSON metadata
        bool isActive;
    }
    
    mapping(uint256 => AnchorData) public anchors;
    mapping(string => uint256) public bundleHashToTokenId;
    mapping(string => uint256[]) public uidToTokenIds;
    
    uint256 private _nextTokenId = 1;
    
    event AnchorCreated(
        uint256 indexed tokenId,
        string indexed bundleHash,
        string indexed uid,
        string projectName
    );
    
    event AnchorUpdated(uint256 indexed tokenId, string metadata);
    event AnchorDeactivated(uint256 indexed tokenId);
    
    constructor() ERC721("AXIOM TOE Anchor", "AXIOM") Ownable(msg.sender) {}
    
    /**
     * @dev Create a new anchor NFT
     * @param to Address to mint the NFT to
     * @param bundleHash IPFS hash or CID of the bundle
     * @param uid Creator UID
     * @param projectName Name of the project
     * @param metadata Additional metadata as JSON string
     */
    function createAnchor(
        address to,
        string memory bundleHash,
        string memory uid,
        string memory projectName,
        string memory metadata
    ) external onlyOwner returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        require(bytes(bundleHash).length > 0, "Bundle hash cannot be empty");
        require(bytes(uid).length > 0, "UID cannot be empty");
        require(bundleHashToTokenId[bundleHash] == 0, "Bundle hash already anchored");
        
        uint256 tokenId = _nextTokenId++;
        
        anchors[tokenId] = AnchorData({
            bundleHash: bundleHash,
            uid: uid,
            projectName: projectName,
            timestamp: block.timestamp,
            metadata: metadata,
            isActive: true
        });
        
        bundleHashToTokenId[bundleHash] = tokenId;
        uidToTokenIds[uid].push(tokenId);
        
        _safeMint(to, tokenId);
        
        emit AnchorCreated(tokenId, bundleHash, uid, projectName);
        return tokenId;
    }
    
    /**
     * @dev Update metadata for an existing anchor
     * @param tokenId The token ID to update
     * @param metadata New metadata as JSON string
     */
    function updateAnchorMetadata(uint256 tokenId, string memory metadata) external onlyOwner {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        anchors[tokenId].metadata = metadata;
        emit AnchorUpdated(tokenId, metadata);
    }
    
    /**
     * @dev Deactivate an anchor (but keep the NFT)
     * @param tokenId The token ID to deactivate
     */
    function deactivateAnchor(uint256 tokenId) external onlyOwner {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        anchors[tokenId].isActive = false;
        emit AnchorDeactivated(tokenId);
    }
    
    /**
     * @dev Get anchor data for a token ID
     * @param tokenId The token ID to query
     */
    function getAnchor(uint256 tokenId) external view returns (AnchorData memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return anchors[tokenId];
    }
    
    /**
     * @dev Get token ID for a bundle hash
     * @param bundleHash The bundle hash to query
     */
    function getTokenIdByBundleHash(string memory bundleHash) external view returns (uint256) {
        return bundleHashToTokenId[bundleHash];
    }
    
    /**
     * @dev Get all token IDs for a UID
     * @param uid The UID to query
     */
    function getTokenIdsByUID(string memory uid) external view returns (uint256[] memory) {
        return uidToTokenIds[uid];
    }
    
    /**
     * @dev Check if an anchor is active
     * @param tokenId The token ID to check
     */
    function isAnchorActive(uint256 tokenId) external view returns (bool) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return anchors[tokenId].isActive;
    }
    
    /**
     * @dev Override tokenURI to include dynamic metadata
     * @param tokenId The token ID to get URI for
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        
        AnchorData memory anchor = anchors[tokenId];
        
        // Return base64 encoded JSON metadata
        string memory json = string(abi.encodePacked(
            '{"name": "AXIOM TOE Anchor #', toString(tokenId), '",',
            '"description": "OmegaT Builder project anchor for ', anchor.projectName, '",',
            '"image": "https://synthetica.us/axiom-toe-anchor.png",',
            '"attributes": [',
                '{"trait_type": "Bundle Hash", "value": "', anchor.bundleHash, '"},',
                '{"trait_type": "UID", "value": "', anchor.uid, '"},',
                '{"trait_type": "Project", "value": "', anchor.projectName, '"},',
                '{"trait_type": "Timestamp", "value": ', toString(anchor.timestamp), '},',
                '{"trait_type": "Active", "value": ', anchor.isActive ? 'true' : 'false', '}',
            '],',
            '"external_url": "https://omegat.net/anchor/', toString(tokenId), '"',
            '}'
        ));
        
        return string(abi.encodePacked(
            "data:application/json;base64,",
            base64Encode(bytes(json))
        ));
    }
    
    /**
     * @dev Convert uint256 to string
     */
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
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
     * @dev Base64 encode bytes
     */
    function base64Encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";
        
        string memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        
        string memory result = new string(encodedLen + 32);
        
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            
            for {
                let i := 0
            } lt(i, mload(data)) {
                i := add(i, 3)
            } {
                let input := and(mload(add(data, i)), 0xffffff)
                
                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)
                
                mstore(resultPtr, out)
                
                resultPtr := add(resultPtr, 4)
            }
            
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            
            mstore(result, encodedLen)
        }
        
        return result;
    }
}