// SPDX-License-Identifier: UCL-∞
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title AXIOM_TOE_Anchor
 * @dev NFT contract for anchoring IPFS CIDs and content hashes with enhanced metadata
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */
contract AXIOM_TOE_Anchor is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    string public constant CREATOR_UID = "ALC-ROOT-1010-1111-XCOV∞";
    string public constant CREATOR_ORCID = "0009-0000-3695-1084";
    string public constant CREATOR_EMAIL = "allcatch37@gmail.com";

    struct AnchoredContent {
        string cid;
        bytes32 sha256Hash;
        uint256 timestamp;
        address anchor;
        string contentType;
        string title;
        string description;
        bool immutable;
    }

    // Events
    event CIDAnchored(
        uint256 indexed tokenId,
        string indexed cid,
        bytes32 indexed sha256Hash,
        address anchor,
        uint256 timestamp
    );

    event ContentUpdated(
        uint256 indexed tokenId,
        string newCid,
        bytes32 newSha256Hash
    );

    event ImmutabilitySet(
        uint256 indexed tokenId,
        bool immutable
    );

    // State variables
    Counters.Counter private _tokenIdCounter;
    
    mapping(uint256 => AnchoredContent) public anchoredContent;
    mapping(string => uint256) public cidToTokenId;
    mapping(bytes32 => uint256) public hashToTokenId;
    
    string public baseTokenURI;
    uint256 public totalAnchored;

    constructor(address initialOwner, string memory _baseTokenURI) 
        ERC721("AXIOM TOE Anchor", "AXIOM") 
        Ownable(initialOwner) {
        baseTokenURI = _baseTokenURI;
        
        // Mint genesis token to creator
        _mintGenesisToken();
    }

    /**
     * @dev Anchor IPFS CID with SHA256 hash verification
     */
    function anchorCID(
        string memory cid,
        bytes32 sha256Hash,
        string memory contentType,
        string memory title,
        string memory description
    ) external returns (uint256) {
        require(bytes(cid).length > 0, "CID cannot be empty");
        require(sha256Hash != bytes32(0), "Hash cannot be empty");
        require(cidToTokenId[cid] == 0, "CID already anchored");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        // Create anchored content record
        AnchoredContent memory content = AnchoredContent({
            cid: cid,
            sha256Hash: sha256Hash,
            timestamp: block.timestamp,
            anchor: msg.sender,
            contentType: contentType,
            title: title,
            description: description,
            immutable: false
        });

        anchoredContent[tokenId] = content;
        cidToTokenId[cid] = tokenId;
        hashToTokenId[sha256Hash] = tokenId;
        totalAnchored++;

        // Mint NFT to anchor
        _safeMint(msg.sender, tokenId);
        
        // Set token URI with metadata
        string memory tokenURI = _buildTokenURI(tokenId, content);
        _setTokenURI(tokenId, tokenURI);

        emit CIDAnchored(tokenId, cid, sha256Hash, msg.sender, block.timestamp);

        return tokenId;
    }

    /**
     * @dev Update anchored content (if not immutable)
     */
    function updateContent(
        uint256 tokenId,
        string memory newCid,
        bytes32 newSha256Hash,
        string memory newTitle,
        string memory newDescription
    ) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender || msg.sender == owner(), "Not authorized");
        require(!anchoredContent[tokenId].immutable, "Content is immutable");
        require(bytes(newCid).length > 0, "CID cannot be empty");
        require(newSha256Hash != bytes32(0), "Hash cannot be empty");

        AnchoredContent storage content = anchoredContent[tokenId];
        
        // Remove old mappings
        delete cidToTokenId[content.cid];
        delete hashToTokenId[content.sha256Hash];
        
        // Update content
        content.cid = newCid;
        content.sha256Hash = newSha256Hash;
        content.title = newTitle;
        content.description = newDescription;
        
        // Add new mappings
        cidToTokenId[newCid] = tokenId;
        hashToTokenId[newSha256Hash] = tokenId;
        
        // Update token URI
        string memory tokenURI = _buildTokenURI(tokenId, content);
        _setTokenURI(tokenId, tokenURI);

        emit ContentUpdated(tokenId, newCid, newSha256Hash);
    }

    /**
     * @dev Set content as immutable (cannot be undone)
     */
    function setImmutable(uint256 tokenId) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender || msg.sender == owner(), "Not authorized");
        require(!anchoredContent[tokenId].immutable, "Already immutable");

        anchoredContent[tokenId].immutable = true;

        emit ImmutabilitySet(tokenId, true);
    }

    /**
     * @dev Get anchored content by token ID
     */
    function getAnchoredContent(uint256 tokenId) 
        external view returns (AnchoredContent memory) {
        require(_exists(tokenId), "Token does not exist");
        return anchoredContent[tokenId];
    }

    /**
     * @dev Get token ID by CID
     */
    function getTokenIdByCID(string memory cid) external view returns (uint256) {
        return cidToTokenId[cid];
    }

    /**
     * @dev Get token ID by SHA256 hash
     */
    function getTokenIdByHash(bytes32 hash) external view returns (uint256) {
        return hashToTokenId[hash];
    }

    /**
     * @dev Verify content integrity
     */
    function verifyContent(uint256 tokenId, bytes32 providedHash) 
        external view returns (bool) {
        require(_exists(tokenId), "Token does not exist");
        return anchoredContent[tokenId].sha256Hash == providedHash;
    }

    /**
     * @dev Get all tokens owned by an address
     */
    function getTokensByOwner(address owner_) 
        external view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(owner_);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= _tokenIdCounter.current(); i++) {
            if (_exists(i) && ownerOf(i) == owner_) {
                tokenIds[currentIndex] = i;
                currentIndex++;
            }
        }

        return tokenIds;
    }

    /**
     * @dev Batch anchor multiple CIDs
     */
    function batchAnchorCIDs(
        string[] memory cids,
        bytes32[] memory hashes,
        string[] memory contentTypes,
        string[] memory titles,
        string[] memory descriptions
    ) external returns (uint256[] memory) {
        require(
            cids.length == hashes.length &&
            hashes.length == contentTypes.length &&
            contentTypes.length == titles.length &&
            titles.length == descriptions.length,
            "Array length mismatch"
        );

        uint256[] memory tokenIds = new uint256[](cids.length);
        
        for (uint256 i = 0; i < cids.length; i++) {
            tokenIds[i] = anchorCID(
                cids[i],
                hashes[i],
                contentTypes[i],
                titles[i],
                descriptions[i]
            );
        }

        return tokenIds;
    }

    /**
     * @dev Update base token URI (owner only)
     */
    function setBaseTokenURI(string memory newBaseTokenURI) external onlyOwner {
        baseTokenURI = newBaseTokenURI;
    }

    // Internal functions

    function _mintGenesisToken() internal {
        _tokenIdCounter.increment();
        uint256 genesisTokenId = _tokenIdCounter.current();

        // Create genesis content
        AnchoredContent memory genesisContent = AnchoredContent({
            cid: "ipfs://bafybeigd3omnichain000genesis000cid",
            sha256Hash: 0x0000000000000000000000000000000000000000000000000000000000000000,
            timestamp: block.timestamp,
            anchor: owner(),
            contentType: "genesis",
            title: "VIOLET-AF PoAI Genesis Anchor",
            description: "Genesis token for VIOLET-AF Proof-of-AI Chain",
            immutable: true
        });

        anchoredContent[genesisTokenId] = genesisContent;
        cidToTokenId[genesisContent.cid] = genesisTokenId;
        totalAnchored++;

        _safeMint(owner(), genesisTokenId);
        
        string memory tokenURI = _buildTokenURI(genesisTokenId, genesisContent);
        _setTokenURI(genesisTokenId, tokenURI);

        emit CIDAnchored(
            genesisTokenId,
            genesisContent.cid,
            genesisContent.sha256Hash,
            owner(),
            block.timestamp
        );
    }

    function _buildTokenURI(uint256 tokenId, AnchoredContent memory content) 
        internal view returns (string memory) {
        // In production, this would generate proper JSON metadata
        // For now, return a simple metadata URL
        return string(abi.encodePacked(
            baseTokenURI,
            "/",
            Strings.toString(tokenId),
            ".json"
        ));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId > 0 && tokenId <= _tokenIdCounter.current();
    }

    // Override required functions

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        
        // Clean up mappings
        AnchoredContent memory content = anchoredContent[tokenId];
        delete cidToTokenId[content.cid];
        delete hashToTokenId[content.sha256Hash];
        delete anchoredContent[tokenId];
        totalAnchored--;
    }

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}