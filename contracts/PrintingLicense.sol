// SPDX-License-Identifier: UCL-∞
pragma solidity ^0.8.20;

/**
 * PrintingLicense Contract
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * Contact: allcatch37@gmail.com
 * 
 * Manages printing and reproduction licenses for VIOLET-AF content
 */

import "./PoAIRegistry.sol";

contract PrintingLicense {
    string public constant CREATOR_UID = "ALC-ROOT-1010-1111-XCOV\u221E";
    address public constant CREATOR_ADDRESS = 0x742E464Ea2dA75fBdCc1B76f4a7d625F2d96A222;
    
    PoAIRegistry public immutable poaiRegistry;
    
    struct License {
        bytes32 proofId;      // PoAI proof ID
        string contentHash;   // IPFS or content hash
        address licensee;     // Licensed entity
        uint256 printLimit;   // Maximum prints allowed
        uint256 printCount;   // Current print count
        uint256 royaltyBps;   // Royalty in basis points (100 = 1%)
        uint256 expiry;       // License expiry timestamp
        bool active;          // License status
        string licenseType;   // Type: commercial, academic, personal
    }
    
    mapping(bytes32 => License) public licenses;
    mapping(address => bytes32[]) public licenseeToLicenses;
    mapping(bytes32 => uint256) public royaltiesCollected;
    
    uint256 public totalRoyaltiesCollected;
    
    event LicenseIssued(
        bytes32 indexed licenseId,
        bytes32 indexed proofId,
        address indexed licensee,
        string licenseType
    );
    
    event PrintAuthorized(
        bytes32 indexed licenseId,
        address indexed printer,
        uint256 printNumber
    );
    
    event RoyaltyPaid(
        bytes32 indexed licenseId,
        uint256 amount,
        address payer
    );
    
    modifier onlyCreator() {
        require(msg.sender == CREATOR_ADDRESS, "Only creator can perform this action");
        _;
    }
    
    modifier validLicense(bytes32 licenseId) {
        require(licenses[licenseId].active, "License not active");
        require(licenses[licenseId].expiry > block.timestamp, "License expired");
        _;
    }
    
    constructor(address _poaiRegistry) {
        poaiRegistry = PoAIRegistry(_poaiRegistry);
    }
    
    /**
     * Issue a new printing license
     */
    function issueLicense(
        bytes32 proofId,
        string memory contentHash,
        address licensee,
        uint256 printLimit,
        uint256 royaltyBps,
        uint256 duration,
        string memory licenseType
    ) external onlyCreator returns (bytes32 licenseId) {
        // Verify PoAI proof exists
        require(poaiRegistry.verifyProof(proofId), "Invalid PoAI proof");
        
        // Generate license ID
        licenseId = keccak256(abi.encodePacked(
            proofId, contentHash, licensee, block.timestamp
        ));
        
        // Create license
        licenses[licenseId] = License({
            proofId: proofId,
            contentHash: contentHash,
            licensee: licensee,
            printLimit: printLimit,
            printCount: 0,
            royaltyBps: royaltyBps,
            expiry: block.timestamp + duration,
            active: true,
            licenseType: licenseType
        });
        
        // Index by licensee
        licenseeToLicenses[licensee].push(licenseId);
        
        emit LicenseIssued(licenseId, proofId, licensee, licenseType);
        
        return licenseId;
    }
    
    /**
     * Authorize a print (with royalty payment)
     */
    function authorizePrint(bytes32 licenseId) 
        external 
        payable 
        validLicense(licenseId) 
        returns (uint256 printNumber) 
    {
        License storage license = licenses[licenseId];
        
        // Check print limit
        require(license.printCount < license.printLimit, "Print limit exceeded");
        
        // Calculate required royalty
        uint256 requiredRoyalty = calculateRoyalty(licenseId);
        require(msg.value >= requiredRoyalty, "Insufficient royalty payment");
        
        // Increment print count
        license.printCount++;
        printNumber = license.printCount;
        
        // Track royalties
        royaltiesCollected[licenseId] += msg.value;
        totalRoyaltiesCollected += msg.value;
        
        emit PrintAuthorized(licenseId, msg.sender, printNumber);
        emit RoyaltyPaid(licenseId, msg.value, msg.sender);
        
        return printNumber;
    }
    
    /**
     * Calculate royalty for a print
     */
    function calculateRoyalty(bytes32 licenseId) public view returns (uint256) {
        License memory license = licenses[licenseId];
        
        // Base royalty calculation (can be enhanced)
        uint256 basePrice = 0.01 ether; // 0.01 ETH base price
        return (basePrice * license.royaltyBps) / 10000;
    }
    
    /**
     * Deactivate a license
     */
    function deactivateLicense(bytes32 licenseId) external onlyCreator {
        licenses[licenseId].active = false;
    }
    
    /**
     * Withdraw royalties
     */
    function withdrawRoyalties() external onlyCreator {
        uint256 balance = address(this).balance;
        require(balance > 0, "No royalties to withdraw");
        
        (bool success, ) = CREATOR_ADDRESS.call{value: balance}("");
        require(success, "Royalty withdrawal failed");
    }
    
    /**
     * Get license details
     */
    function getLicense(bytes32 licenseId) external view returns (License memory) {
        return licenses[licenseId];
    }
    
    /**
     * Get licenses for an address
     */
    function getLicensesForAddress(address licensee) external view returns (bytes32[] memory) {
        return licenseeToLicenses[licensee];
    }
    
    /**
     * Check if print is authorized
     */
    function isPrintAuthorized(bytes32 licenseId) external view returns (bool) {
        License memory license = licenses[licenseId];
        return license.active && 
               license.expiry > block.timestamp && 
               license.printCount < license.printLimit;
    }
    
    /**
     * Get remaining prints for license
     */
    function getRemainingPrints(bytes32 licenseId) external view returns (uint256) {
        License memory license = licenses[licenseId];
        if (!license.active || license.expiry <= block.timestamp) {
            return 0;
        }
        return license.printLimit - license.printCount;
    }
    
    /**
     * Emergency stop
     */
    function emergencyStop() external onlyCreator {
        // Can pause all licensing activities
    }
}