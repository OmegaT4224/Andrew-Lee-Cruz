// SPDX-License-Identifier: UCL-∞
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title PoAIRegistry
 * @dev Registry contract for VIOLET-AF Proof-of-AI submissions with royalty distribution
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */
contract PoAIRegistry is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    string public constant CREATOR_UID = "ALC-ROOT-1010-1111-XCOV∞";
    string public constant CREATOR_EMAIL = "allcatch37@gmail.com";
    string public constant CREATOR_ORCID = "0009-0000-3695-1084";

    struct PoAISubmission {
        string uid;
        string deviceId;
        bytes32 digest;
        uint256 timestamp;
        address submitter;
        bool verified;
        uint256 blockHeight;
    }

    struct RoyaltyDistribution {
        address recipient;
        uint256 percentage; // Basis points (10000 = 100%)
        uint256 totalAccrued;
        uint256 totalWithdrawn;
    }

    // Events
    event Submitted(
        string indexed uid,
        string indexed deviceId,
        bytes32 indexed digest,
        uint256 timestamp,
        address submitter,
        uint256 blockHeight
    );

    event RoyaltyDistributed(
        address indexed recipient,
        uint256 amount,
        uint256 blockHeight
    );

    event RoyaltyWithdrawn(
        address indexed recipient,
        uint256 amount
    );

    event SubmissionVerified(
        bytes32 indexed digest,
        bool verified
    );

    // State variables
    mapping(bytes32 => PoAISubmission) public submissions;
    mapping(address => RoyaltyDistribution) public royaltyDistributions;
    
    bytes32[] public submissionHashes;
    address[] public royaltyRecipients;
    
    uint256 public totalSubmissions;
    uint256 public totalRoyaltiesDistributed;
    uint256 public currentBlockHeight;
    
    // Energy policy parameters
    uint256 public minBatteryLevel = 70;
    bool public requireChargingOrHighBattery = true;
    uint256 public maxCpuTemperature = 45; // Celsius
    
    modifier onlyValidUID(string memory uid) {
        require(
            keccak256(abi.encodePacked(uid)) == keccak256(abi.encodePacked(CREATOR_UID)),
            "Invalid creator UID"
        );
        _;
    }

    constructor(address initialOwner) Ownable(initialOwner) {
        // Set initial royalty distribution (example)
        _setRoyaltyDistribution(initialOwner, 5000); // 50% to owner
        _setRoyaltyDistribution(address(0x0), 5000); // 50% to treasury (address 0 for now)
    }

    /**
     * @dev Submit a PoAI computation result
     */
    function submit(
        string memory uid,
        string memory deviceId,
        bytes32 digest,
        uint256 timestamp
    ) external onlyValidUID(uid) {
        require(timestamp <= block.timestamp, "Future timestamp not allowed");
        require(digest != bytes32(0), "Invalid digest");
        require(bytes(deviceId).length > 0, "Invalid device ID");

        // Check for duplicate submissions
        require(submissions[digest].timestamp == 0, "Digest already submitted");

        // Create submission record
        PoAISubmission memory submission = PoAISubmission({
            uid: uid,
            deviceId: deviceId,
            digest: digest,
            timestamp: timestamp,
            submitter: msg.sender,
            verified: false,
            blockHeight: currentBlockHeight
        });

        submissions[digest] = submission;
        submissionHashes.push(digest);
        totalSubmissions = totalSubmissions.add(1);

        emit Submitted(uid, deviceId, digest, timestamp, msg.sender, currentBlockHeight);

        // Distribute royalties if there's a balance
        _distributeRoyalties();
    }

    /**
     * @dev Verify a PoAI submission (owner only)
     */
    function verifySubmission(bytes32 digest, bool verified) external onlyOwner {
        require(submissions[digest].timestamp != 0, "Submission not found");
        
        submissions[digest].verified = verified;
        
        emit SubmissionVerified(digest, verified);
    }

    /**
     * @dev Batch verify multiple submissions
     */
    function batchVerifySubmissions(bytes32[] memory digests, bool[] memory verifications) 
        external onlyOwner {
        require(digests.length == verifications.length, "Array length mismatch");
        
        for (uint256 i = 0; i < digests.length; i++) {
            verifySubmission(digests[i], verifications[i]);
        }
    }

    /**
     * @dev Update current block height (for tracking)
     */
    function updateBlockHeight(uint256 newHeight) external onlyOwner {
        require(newHeight > currentBlockHeight, "Height must increase");
        currentBlockHeight = newHeight;
    }

    /**
     * @dev Set royalty distribution for an address
     */
    function setRoyaltyDistribution(address recipient, uint256 percentage) 
        external onlyOwner {
        _setRoyaltyDistribution(recipient, percentage);
    }

    /**
     * @dev Distribute royalties to all recipients
     */
    function distributeRoyalties() external payable {
        require(msg.value > 0, "No value to distribute");
        _distributeRoyalties();
    }

    /**
     * @dev Withdraw accrued royalties
     */
    function withdrawRoyalties() external nonReentrant {
        RoyaltyDistribution storage distribution = royaltyDistributions[msg.sender];
        uint256 available = distribution.totalAccrued.sub(distribution.totalWithdrawn);
        
        require(available > 0, "No royalties available");
        
        distribution.totalWithdrawn = distribution.totalWithdrawn.add(available);
        
        (bool success, ) = payable(msg.sender).call{value: available}("");
        require(success, "Transfer failed");
        
        emit RoyaltyWithdrawn(msg.sender, available);
    }

    /**
     * @dev Get submission by hash
     */
    function getSubmission(bytes32 digest) 
        external view returns (PoAISubmission memory) {
        return submissions[digest];
    }

    /**
     * @dev Get recent submissions
     */
    function getRecentSubmissions(uint256 count) 
        external view returns (bytes32[] memory) {
        uint256 start = submissionHashes.length > count ? 
            submissionHashes.length - count : 0;
        uint256 length = submissionHashes.length - start;
        
        bytes32[] memory recent = new bytes32[](length);
        for (uint256 i = 0; i < length; i++) {
            recent[i] = submissionHashes[start + i];
        }
        
        return recent;
    }

    /**
     * @dev Get royalty information for an address
     */
    function getRoyaltyInfo(address recipient) 
        external view returns (uint256 percentage, uint256 accrued, uint256 withdrawn) {
        RoyaltyDistribution memory distribution = royaltyDistributions[recipient];
        return (distribution.percentage, distribution.totalAccrued, distribution.totalWithdrawn);
    }

    /**
     * @dev Check if submission meets energy policy
     */
    function meetsEnergyPolicy(
        uint256 batteryLevel,
        bool isCharging,
        uint256 cpuTemp
    ) external view returns (bool) {
        bool batteryOk = isCharging || batteryLevel >= minBatteryLevel;
        bool tempOk = cpuTemp <= maxCpuTemperature;
        
        return batteryOk && tempOk;
    }

    /**
     * @dev Update energy policy parameters (owner only)
     */
    function updateEnergyPolicy(
        uint256 _minBatteryLevel,
        bool _requireChargingOrHighBattery,
        uint256 _maxCpuTemperature
    ) external onlyOwner {
        minBatteryLevel = _minBatteryLevel;
        requireChargingOrHighBattery = _requireChargingOrHighBattery;
        maxCpuTemperature = _maxCpuTemperature;
    }

    // Internal functions

    function _setRoyaltyDistribution(address recipient, uint256 percentage) internal {
        require(percentage <= 10000, "Percentage too high");
        
        if (royaltyDistributions[recipient].percentage == 0) {
            royaltyRecipients.push(recipient);
        }
        
        royaltyDistributions[recipient].percentage = percentage;
    }

    function _distributeRoyalties() internal {
        uint256 totalBalance = address(this).balance;
        if (totalBalance == 0) return;
        
        for (uint256 i = 0; i < royaltyRecipients.length; i++) {
            address recipient = royaltyRecipients[i];
            RoyaltyDistribution storage distribution = royaltyDistributions[recipient];
            
            if (distribution.percentage > 0) {
                uint256 amount = totalBalance.mul(distribution.percentage).div(10000);
                distribution.totalAccrued = distribution.totalAccrued.add(amount);
                totalRoyaltiesDistributed = totalRoyaltiesDistributed.add(amount);
                
                emit RoyaltyDistributed(recipient, amount, currentBlockHeight);
            }
        }
    }

    /**
     * @dev Emergency withdrawal (owner only)
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Transfer failed");
    }

    // Receive function to accept ETH
    receive() external payable {
        _distributeRoyalties();
    }
}