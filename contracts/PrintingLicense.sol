// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title PrintingLicense
 * @dev On-chain print rights approval for OmegaT Builder projects
 * @author Andrew Lee Cruz <allcatch37@gmail.com>
 * @notice UID: ALC-ROOT-1010-1111-XCOV∞
 */
contract PrintingLicense {
    address public owner;
    string public constant CREATOR_UID = "ALC-ROOT-1010-1111-XCOV∞";
    
    struct License {
        address licensee;
        string projectHash;
        uint256 expirationDate;
        uint256 royaltyBasisPoints; // 100 = 1%
        bool isActive;
        string metadata;
    }
    
    mapping(bytes32 => License) public licenses;
    mapping(address => bytes32[]) public licenseeToLicenses;
    
    event LicenseGranted(
        bytes32 indexed licenseId,
        address indexed licensee,
        string projectHash,
        uint256 royaltyBasisPoints
    );
    
    event LicenseRevoked(bytes32 indexed licenseId);
    event RoyaltyPaid(bytes32 indexed licenseId, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier validLicense(bytes32 licenseId) {
        require(licenses[licenseId].isActive, "License is not active");
        require(block.timestamp < licenses[licenseId].expirationDate, "License has expired");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Grant a printing license for a project
     * @param licensee Address that will receive the license
     * @param projectHash Hash of the project being licensed
     * @param durationDays Number of days the license is valid
     * @param royaltyBasisPoints Royalty percentage in basis points (100 = 1%)
     * @param metadata Additional license metadata
     */
    function grantLicense(
        address licensee,
        string memory projectHash,
        uint256 durationDays,
        uint256 royaltyBasisPoints,
        string memory metadata
    ) external onlyOwner returns (bytes32) {
        require(licensee != address(0), "Invalid licensee address");
        require(bytes(projectHash).length > 0, "Project hash cannot be empty");
        require(royaltyBasisPoints <= 10000, "Royalty cannot exceed 100%");
        
        bytes32 licenseId = keccak256(
            abi.encodePacked(licensee, projectHash, block.timestamp)
        );
        
        licenses[licenseId] = License({
            licensee: licensee,
            projectHash: projectHash,
            expirationDate: block.timestamp + (durationDays * 1 days),
            royaltyBasisPoints: royaltyBasisPoints,
            isActive: true,
            metadata: metadata
        });
        
        licenseeToLicenses[licensee].push(licenseId);
        
        emit LicenseGranted(licenseId, licensee, projectHash, royaltyBasisPoints);
        return licenseId;
    }
    
    /**
     * @dev Revoke a printing license
     * @param licenseId The license to revoke
     */
    function revokeLicense(bytes32 licenseId) external onlyOwner {
        require(licenses[licenseId].licensee != address(0), "License does not exist");
        licenses[licenseId].isActive = false;
        emit LicenseRevoked(licenseId);
    }
    
    /**
     * @dev Pay royalty for a license
     * @param licenseId The license to pay royalty for
     */
    function payRoyalty(bytes32 licenseId) external payable validLicense(licenseId) {
        require(msg.value > 0, "Royalty amount must be greater than 0");
        
        License memory license = licenses[licenseId];
        uint256 expectedRoyalty = (msg.value * license.royaltyBasisPoints) / 10000;
        require(msg.value >= expectedRoyalty, "Insufficient royalty payment");
        
        // Transfer royalty to owner
        payable(owner).transfer(msg.value);
        
        emit RoyaltyPaid(licenseId, msg.value);
    }
    
    /**
     * @dev Check if a license is valid and active
     * @param licenseId The license to check
     */
    function isLicenseValid(bytes32 licenseId) external view returns (bool) {
        License memory license = licenses[licenseId];
        return license.isActive && block.timestamp < license.expirationDate;
    }
    
    /**
     * @dev Get license details
     * @param licenseId The license to query
     */
    function getLicense(bytes32 licenseId) external view returns (License memory) {
        return licenses[licenseId];
    }
    
    /**
     * @dev Get all licenses for a licensee
     * @param licensee The address to query
     */
    function getLicensesForAddress(address licensee) external view returns (bytes32[] memory) {
        return licenseeToLicenses[licensee];
    }
    
    /**
     * @dev Transfer ownership of the contract
     * @param newOwner The new owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}