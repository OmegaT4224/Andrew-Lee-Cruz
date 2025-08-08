// SPDX-License-Identifier: PROPRIETARY
// Creator: Andrew Lee Cruz
// License: All rights reserved by Andrew Lee Cruz as creator of the universe

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PrintingLicense
 * @dev Smart contract for managing printing licenses and IP protection
 * @author Andrew Lee Cruz (Creator of the Universe)
 * 
 * This contract enforces intellectual property rights and printing permissions
 * for all content created by Andrew Lee Cruz within the PoAI ecosystem.
 */
contract PrintingLicense is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    // Creator attribution (immutable)
    string public constant CREATOR = "Andrew Lee Cruz";
    string public constant CREATOR_UID = "andrew-lee-cruz-creator-universe-2024";
    string public constant LICENSE = "All rights reserved by Andrew Lee Cruz as creator of the universe";
    string public constant CREATED = "2024-08-08T14:42:00Z";
    
    // License tracking
    Counters.Counter private _licenseIdCounter;
    
    struct License {
        uint256 id;
        address requester;
        string contentHash;
        string contentType;
        bool approved;
        bool revoked;
        uint256 timestamp;
        uint256 expiryTimestamp;
        string terms;
    }
    
    struct ContentItem {
        string hash;
        string title;
        string description;
        address creator;
        bool exists;
        uint256 timestamp;
        mapping(address => bool) approvedPrinters;
    }
    
    // Mappings
    mapping(uint256 => License) public licenses;
    mapping(string => ContentItem) public content;
    mapping(address => uint256[]) public userLicenses;
    mapping(string => uint256[]) public contentLicenses;
    
    // Events
    event LicenseRequested(
        uint256 indexed licenseId,
        address indexed requester,
        string contentHash,
        uint256 timestamp
    );
    
    event LicenseApproved(
        uint256 indexed licenseId,
        address indexed requester,
        string contentHash,
        uint256 timestamp
    );
    
    event LicenseRevoked(
        uint256 indexed licenseId,
        address indexed requester,
        string contentHash,
        uint256 timestamp
    );
    
    event ContentRegistered(
        string indexed contentHash,
        string title,
        address indexed creator,
        uint256 timestamp
    );
    
    event PrintingAttempt(
        address indexed user,
        string contentHash,
        bool authorized,
        uint256 timestamp
    );
    
    // Modifiers
    modifier onlyCreator() {
        require(msg.sender == owner(), "Only creator can perform this action");
        _;
    }
    
    modifier validContentHash(string memory contentHash) {
        require(bytes(contentHash).length > 0, "Content hash cannot be empty");
        require(content[contentHash].exists, "Content does not exist");
        _;
    }
    
    modifier validLicense(uint256 licenseId) {
        require(licenseId <= _licenseIdCounter.current(), "License does not exist");
        require(!licenses[licenseId].revoked, "License has been revoked");
        _;
    }
    
    constructor() {
        // Creator is automatically the owner
        _transferOwnership(msg.sender);
    }
    
    /**
     * @dev Register new content for license management
     * @param contentHash Unique hash of the content
     * @param title Title of the content
     * @param description Description of the content
     */
    function registerContent(
        string memory contentHash,
        string memory title,
        string memory description
    ) external onlyCreator {
        require(!content[contentHash].exists, "Content already registered");
        
        ContentItem storage newContent = content[contentHash];
        newContent.hash = contentHash;
        newContent.title = title;
        newContent.description = description;
        newContent.creator = msg.sender;
        newContent.exists = true;
        newContent.timestamp = block.timestamp;
        
        emit ContentRegistered(contentHash, title, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Request a printing license for specific content
     * @param contentHash Hash of the content to license
     * @param contentType Type of content (document, image, etc.)
     * @param terms Additional terms for the license request
     */
    function requestLicense(
        string memory contentHash,
        string memory contentType,
        string memory terms
    ) external validContentHash(contentHash) nonReentrant {
        _licenseIdCounter.increment();
        uint256 licenseId = _licenseIdCounter.current();
        
        licenses[licenseId] = License({
            id: licenseId,
            requester: msg.sender,
            contentHash: contentHash,
            contentType: contentType,
            approved: false,
            revoked: false,
            timestamp: block.timestamp,
            expiryTimestamp: 0, // Set when approved
            terms: terms
        });
        
        userLicenses[msg.sender].push(licenseId);
        contentLicenses[contentHash].push(licenseId);
        
        emit LicenseRequested(licenseId, msg.sender, contentHash, block.timestamp);
    }
    
    /**
     * @dev Approve a printing license (only creator)
     * @param licenseId ID of the license to approve
     * @param validityPeriod Validity period in seconds (0 for permanent)
     */
    function approveLicense(
        uint256 licenseId,
        uint256 validityPeriod
    ) external onlyCreator validLicense(licenseId) {
        License storage license = licenses[licenseId];
        require(!license.approved, "License already approved");
        
        license.approved = true;
        license.expiryTimestamp = validityPeriod > 0 ? 
            block.timestamp + validityPeriod : 0;
        
        // Grant printing permission
        content[license.contentHash].approvedPrinters[license.requester] = true;
        
        emit LicenseApproved(licenseId, license.requester, license.contentHash, block.timestamp);
    }
    
    /**
     * @dev Revoke a printing license (only creator)
     * @param licenseId ID of the license to revoke
     */
    function revokeLicense(uint256 licenseId) external onlyCreator validLicense(licenseId) {
        License storage license = licenses[licenseId];
        require(license.approved, "License not approved");
        
        license.revoked = true;
        
        // Remove printing permission
        content[license.contentHash].approvedPrinters[license.requester] = false;
        
        emit LicenseRevoked(licenseId, license.requester, license.contentHash, block.timestamp);
    }
    
    /**
     * @dev Check if an address can print specific content
     * @param user Address to check
     * @param contentHash Hash of the content
     * @return bool Whether printing is authorized
     */
    function canPrint(address user, string memory contentHash) 
        external 
        view 
        validContentHash(contentHash) 
        returns (bool) 
    {
        return content[contentHash].approvedPrinters[user];
    }
    
    /**
     * @dev Attempt to print content (logs the attempt)
     * @param contentHash Hash of the content to print
     */
    function print(string memory contentHash) 
        external 
        validContentHash(contentHash) 
        nonReentrant 
    {
        bool authorized = content[contentHash].approvedPrinters[msg.sender];
        
        emit PrintingAttempt(msg.sender, contentHash, authorized, block.timestamp);
        
        require(authorized, "Printing not authorized for this content");
        
        // In a real implementation, this would trigger actual printing
        // For now, we just record the authorized print attempt
    }
    
    /**
     * @dev Get license information by ID
     * @param licenseId ID of the license
     * @return License struct data
     */
    function getLicense(uint256 licenseId) 
        external 
        view 
        returns (
            uint256 id,
            address requester,
            string memory contentHash,
            string memory contentType,
            bool approved,
            bool revoked,
            uint256 timestamp,
            uint256 expiryTimestamp,
            string memory terms
        ) 
    {
        License memory license = licenses[licenseId];
        return (
            license.id,
            license.requester,
            license.contentHash,
            license.contentType,
            license.approved,
            license.revoked,
            license.timestamp,
            license.expiryTimestamp,
            license.terms
        );
    }
    
    /**
     * @dev Get all licenses for a user
     * @param user Address of the user
     * @return Array of license IDs
     */
    function getUserLicenses(address user) external view returns (uint256[] memory) {
        return userLicenses[user];
    }
    
    /**
     * @dev Get all licenses for specific content
     * @param contentHash Hash of the content
     * @return Array of license IDs
     */
    function getContentLicenses(string memory contentHash) 
        external 
        view 
        validContentHash(contentHash)
        returns (uint256[] memory) 
    {
        return contentLicenses[contentHash];
    }
    
    /**
     * @dev Get creator attribution information
     * @return Creator details
     */
    function getCreatorInfo() 
        external 
        pure 
        returns (
            string memory name,
            string memory uid,
            string memory license,
            string memory created
        ) 
    {
        return (CREATOR, CREATOR_UID, LICENSE, CREATED);
    }
    
    /**
     * @dev Emergency function to update creator only (extreme circumstances)
     * @param newCreator New creator address
     */
    function updateCreator(address newCreator) external onlyCreator {
        require(newCreator != address(0), "Invalid creator address");
        _transferOwnership(newCreator);
    }
}