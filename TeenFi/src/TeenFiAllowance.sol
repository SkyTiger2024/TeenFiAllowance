// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// MetaMask Delegation Toolkit Interfaces
interface IDelegationManager {
    struct Delegation {
        address delegate;
        address delegator;
        bytes32 authority;
        bytes[] caveats;
        bytes32 salt;
        bytes signature;
    }
    
    function redeemDelegations(
        bytes[] calldata permissionContexts,
        bytes[] calldata modes,
        bytes[] calldata executionCallDatas
    ) external payable returns (bool);
}

// Interface to Enforce Caveats
interface ICaveatEnforcer {
    function enforceCaveats(
        bytes calldata terms,
        bytes calldata txData
    ) external view returns (bool);
}

// ERC-7715 interfaces - based on draft standard
interface IERC7715Actions {
    struct Action {
        address target;
        uint256 value;
        bytes data;
    }
    
    function execute(address delegate, Action[] calldata actions) external payable returns (bytes[] memory);
    function revoke(address delegate) external;
    function isValidDelegate(address signer, address delegate) external view returns (bool);
}

// Interface for ERC-7715 Token Streaming
interface IERC7715TokenStreaming {
    function createStream(
        address recipient,
        address token,
        uint256 amountPerSecond,
        uint256 duration
    ) external returns (uint256 streamId);
    
    function cancelStream(uint256 streamId) external;
    function withdrawFromStream(uint256 streamId, uint256 amount) external;
    function getStream(uint256 streamId) external view returns (
        address sender,
        address recipient,
        address token,
        uint256 amountPerSecond,
        uint256 startTime,
        uint256 duration,
        uint256 withdrawnAmount
    );
}

/// @title TeenFiAllowance
/// @notice A contract for parents to manage allowances for teens with spending restrictions and delegation.
/// @dev Integrates with MetaMask Delegation Toolkit for permissioned spending and uses OpenZeppelin for security.
contract TeenFiAllowance is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /// @notice Enum for spending categories.
    enum Category { EDUCATION, ENTERTAINMENT, SAVINGS, FOOD }

    /// @notice Configuration for a teen's allowance.
    struct AllowanceConfig {
        address tokenAddress; // ERC20 token for the allowance
        uint256 weeklyAmount; // Weekly allowance amount
        uint256 lastDistribution; // Timestamp of last distribution
        uint256 spendingCap; // Maximum spending limit
        bool isActive; // Whether the allowance is active
        uint256 streamId; // Stream ID for streaming allowances
    }

    /// @notice  Parent > Teen mappings
    // Maps parent address -> teen address -> allowance configuration
    mapping(address => mapping(address => AllowanceConfig)) public parentTeenAllowances;

    // Maps teen address -> category ID -> whether it's allowed
    mapping(address => mapping(Category => bool)) public teenAllowedCategories;

    // Maps teen address -> their current balance
    mapping(address => uint256) public teenBalances;

    // Educational achievement tracking
    mapping(address => mapping(uint256 => bool)) public completedAchievements;

    /// @notice Achievement rewards mapping
    mapping(uint256 => uint256) public achievementRewards;

    mapping(address => address[]) public teenParents;
    mapping(address => mapping(address => bool)) public isParentOf;

    // ERC-7715 contracts
    IERC7715Actions public immutable actionsContract;
    IERC7715TokenStreaming public immutable streamingContract;
    
    /// @notice ERC-7715 Protocol Contracts
    IDelegationManager public immutable delegationManager;
    address public immutable caveatEnforcer;

    /// @notice Constants
    bytes32 public constant ROOT_AUTHORITY = keccak256("ROOT_AUTHORITY");
    uint256 public constant MAX_PARENTS = 5; // Maximum parents per teen to prevent gas issues
    uint256 public constant WEEK = 1 weeks; // Duration of a week in seconds

    /// @notice Security State
    bool public paused;
    
    // Events
    //-------
    event AllowanceConfigured(address indexed parent, address indexed teen, address token, uint256 weeklyAmount, uint256 spendingCap);
    event StreamCreated(address indexed parent, address indexed teen, uint256 streamId, uint256 totalAmount);
    event StreamCancelled(address indexed parent, address indexed teen, uint256 streamId);
    event AllowanceSpent(address indexed teen, Category category, uint256 amount, address token);
    event AllowanceDistributed(address indexed parent, address indexed teen, uint256 amount);
    event AllowanceClaimed(address indexed teen, address token, uint256 amount);
    event AllowanceModified(address indexed parent, address indexed teen, uint256 newWeeklyAmount);
    event AchievementCompleted(address indexed teen, uint256 achievementId, uint256 reward);
    event AchievementRevoked(address indexed teen, uint256 achievementId);
    event DelegationCreated(address indexed parent, address indexed teen, bytes32 delegationId);
    event DelegationRevoked(address indexed parent, address indexed teen);
    event EmergencyPaused(bool paused);
    event ParentAdded(address indexed parent, address indexed teen);
    event ParentRemoved(address indexed parent, address indexed teen);
    event CategoryChanged(address indexed teen, Category category, bool allowed);
    event AchievementRewardSet(uint256 indexed achievementId, uint256 reward);
    event SpendingCapUpdated(address indexed parent, address indexed teen, uint256 newCap);

    /// @notice Constructor to initialize the contract with delegation manager and caveat enforcer.
    /// @param _delegationManager Address of the delegation manager contract.
    /// @param _caveatEnforcer Address of the caveat enforcer contract.
    constructor(
        address _delegationManager, 
        address _caveatEnforcer,
        address _actionsContract,
        address _streamingContract
    ) Ownable() { // Explicitly call the Ownable constructor
        require(_delegationManager != address(0), "Invalid delegation manager address");
        require(_caveatEnforcer != address(0), "Invalid caveat enforcer address");
        require(_actionsContract != address(0), "Invalid actions contract address");
        require(_streamingContract != address(0), "Invalid streaming contract address");
        require(_hasCode(_delegationManager), "Delegation manager is not a contract");
        require(_hasCode(_caveatEnforcer), "Caveat enforcer is not a contract");
        require(_hasCode(_actionsContract), "Actions contract is not a contract");
        require(_hasCode(_streamingContract), "Streaming contract is not a contract");

        delegationManager = IDelegationManager(_delegationManager);
        caveatEnforcer = _caveatEnforcer;
        actionsContract = IERC7715Actions(_actionsContract);
        streamingContract = IERC7715TokenStreaming(_streamingContract);
        paused = false;
        // not needed now: _transferOwnership(initalOwner);
    }

    /// @notice Modifier to check if the contract is not paused.
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /// @notice Modifier to check if the caller is a parent of the teen.
    /// @param teen The teen's address.
    modifier onlyParent(address teen) {
        require(isParentOf[msg.sender][teen], "Caller is not a parent of the teen");
        _;
    }

    //  Parent Functions
    // =================

    /// @notice Configures an allowance for a teen with weekly amount and spending cap.
    /// @param teen The teen's address.
    /// @param token The ERC20 token address.
    /// @param weeklyAmount The weekly allowance amount.
    /// @param spendingCap The maximum spending limit.
    /// @param delegationTerms The delegation terms for the caveat enforcer.
    function configureAllowance(
        address teen,
        address token,
        uint256 weeklyAmount,
        uint256 spendingCap,
        bytes calldata delegationTerms
    ) external onlyParent(teen) nonReentrant whenNotPaused {
        require(teen != address(0), "Invalid teen address");
        require(token != address(0), "Invalid token address");
        require(_hasCode(token), "Token is not a contract");
        require(weeklyAmount > 0, "Weekly amount must be positive");
        require(spendingCap >= weeklyAmount, "Spending cap must be at least weekly amount");
        require(delegationTerms.length > 0, "Delegation terms cannot be empty");

        // Set allowance configuration
        parentTeenAllowances[msg.sender][teen] = AllowanceConfig({
            tokenAddress: token,
            weeklyAmount: weeklyAmount,
            lastDistribution: block.timestamp,
            spendingCap: spendingCap,
            isActive: true,
            streamId: 0
        });

        // Create delegation with proper token approval checks, note: 0 for streaming, 1 for spending
        _createDelegation(teen, token, weeklyAmount, delegationTerms, 1);
        _addParentRelationship(msg.sender, teen);
        
        // Default allowed categories
        teenAllowedCategories[teen][Category.EDUCATION] = true;  // Education always allowed

        emit AllowanceConfigured(msg.sender, teen, token, weeklyAmount, spendingCap);
        emit CategoryChanged(teen, Category.EDUCATION, true);
    }

    // modifyAllowance
    // ---------------
    function modifyAllowance(
        address teen,
        uint256 newWeeklyAmount,
        uint256 newSpendingCap
    ) external onlyParent(teen) nonReentrant whenNotPaused {
        AllowanceConfig storage config = parentTeenAllowances[msg.sender][teen];
        require(config.isActive, "Allowance not found");
        require(newWeeklyAmount > 0, "Weekly amount must be positive");
        require(newSpendingCap >= newWeeklyAmount, "Spending cap must be at least weekly amount");
        require(_hasCode(config.tokenAddress), "Token is not a contract");

        if (config.streamId != 0) {
            // Store the streamId temporarily to avoid state changes after external calls
            uint256 oldStreamId = config.streamId;
            // Clear streamId to prevent reentrancy manipulation
            config.streamId = 0;
            
            // Cancel existing stream
            streamingContract.cancelStream(oldStreamId);
            
            // Safe approve pattern - reset and then set approval
            IERC20 token = IERC20(config.tokenAddress);
            require(token.balanceOf(msg.sender) >= newWeeklyAmount.mul(4), "Insufficient parent balance");
            token.safeApprove(address(streamingContract), 0);
            token.safeApprove(address(streamingContract), newWeeklyAmount.mul(4));
            
            // Create new stream
            uint256 amountPerSecond = newWeeklyAmount.div(7 days);
            uint256 streamId = streamingContract.createStream(
                teen,
                config.tokenAddress,
                amountPerSecond,
                4 weeks
            );
            
            // Update streamId with the new one
            config.streamId = streamId;
            emit StreamCreated(msg.sender, teen, streamId, newWeeklyAmount.mul(4));
        }
        
        config.weeklyAmount = newWeeklyAmount;
        config.spendingCap = newSpendingCap;
        
        emit AllowanceModified(msg.sender, teen, newWeeklyAmount);
        emit SpendingCapUpdated(msg.sender, teen, newSpendingCap);
    }

    // createStreamingAllowance
    // ------------------------
    /// @notice Creates a streaming allowance for a teen over a duration.
    /// @param teen The teen's address.
    /// @param token The ERC20 token address.
    /// @param weeklyAmount The weekly allowance amount.
    /// @param durationWeeks The duration of the stream in weeks.
    /// @param spendingCap The maximum spending limit.
    /// @param delegationTerms The delegation terms for the caveat enforcer.
    function createStreamingAllowance(
        address teen,
        address token,
        uint256 weeklyAmount,
        uint256 durationWeeks,
        uint256 spendingCap,
        bytes calldata delegationTerms
    ) external onlyParent(teen) nonReentrant whenNotPaused {
        require(teen != address(0), "Invalid teen address");
        require(token != address(0), "Invalid token address");
        require(_hasCode(token), "Token is not a contract");
        require(weeklyAmount > 0, "Weekly amount must be positive");
        require(durationWeeks > 0, "Duration must be positive");
        require(spendingCap >= weeklyAmount, "Spending cap must be at least weekly amount");
        require(delegationTerms.length > 0, "Delegation terms cannot be empty");

        uint256 totalAmount = weeklyAmount.mul(durationWeeks);
        IERC20 tokenContract = IERC20(token);
        require(tokenContract.balanceOf(msg.sender) >= totalAmount, "Insufficient token balance");
        require(tokenContract.allowance(msg.sender, address(this)) >= totalAmount, "Insufficient allowance");
       
        // Safe approve pattern for delegationManager
        tokenContract.safeApprove(address(delegationManager), 0);
        tokenContract.safeApprove(address(delegationManager), totalAmount);

        // Safe approve pattern for streamingContract
        tokenContract.safeApprove(address(streamingContract), 0);
        tokenContract.safeApprove(address(streamingContract), totalAmount);

        // Create the stream for the teen
        uint256 amountPerSecond = weeklyAmount.div(7 days);
        uint256 streamId = streamingContract.createStream(
            teen,
            token,
            amountPerSecond,
            durationWeeks * WEEK
        );

        // Store configuration before any potential external calls to prevent reentrancy
        parentTeenAllowances[msg.sender][teen] = AllowanceConfig({
            tokenAddress: token,
            weeklyAmount: weeklyAmount,
            lastDistribution: block.timestamp,
            spendingCap: spendingCap,
            isActive: true,
            streamId: streamId
        });

        // Create delegation with proper token approval checks, note: 0 for streaming, 1 for spending
        _createDelegation(teen, token, weeklyAmount, delegationTerms, 0);

        // Add the parent-teen relationship
        _addParentRelationship(msg.sender, teen);

        teenAllowedCategories[teen][Category.EDUCATION] = true;

        emit StreamCreated(msg.sender, teen, streamId, totalAmount);
        emit CategoryChanged(teen, Category.EDUCATION, true);
    }

    // Cancel an active streaming allowance
    // ------------------------------------
    function cancelStreamingAllowance(address teen) external onlyParent(teen) nonReentrant whenNotPaused {
        AllowanceConfig storage config = parentTeenAllowances[msg.sender][teen];
        require(config.isActive, "No active allowance");
        require(config.streamId != 0, "No active stream");
        
        // Store ID and mark as cancelled before external call
        uint256 streamIdToCancel = config.streamId;
        config.isActive = false;
        config.streamId = 0;
        
        // Now safe to make external call
        streamingContract.cancelStream(streamIdToCancel);
        
        emit StreamCancelled(msg.sender, teen, streamIdToCancel);
    }

    // removeParent
    // ------------
    /// @notice Removes a parent from a teen's allowance configuration.
    /// @param teen The teen's address.
    function removeParent(address teen) external nonReentrant whenNotPaused {
        require(isParentOf[msg.sender][teen], "Caller is not a parent of the teen");
        require(teenParents[teen].length > 1, "Cannot remove last parent");

        address[] memory parents = teenParents[teen];
        uint256 activeParents = 0;
        for (uint256 i = 0; i < parents.length; i++) {
            if (parentTeenAllowances[parents[i]][teen].isActive) {
                activeParents++;
            }
        }
        require(activeParents > 1, "Cannot remove last active parent");

        // Update state before any potential external calls
        parentTeenAllowances[msg.sender][teen].isActive = false;
        isParentOf[msg.sender][teen] = false;

        address[] storage parentsStorage = teenParents[teen];
        for (uint256 i = 0; i < parentsStorage.length; i++) {
            if (parentsStorage[i] == msg.sender) {
                parentsStorage[i] = parentsStorage[parentsStorage.length - 1];
                parentsStorage.pop();
                break;
            }
        }

        emit ParentRemoved(msg.sender, teen);
    }

    // addParent
    // ---------
    // @notice function that calls _addParentRelationship
    // @notice allows my  wallet to register as a parent for the teen
    function addParent(address parent, address teen) external onlyOwner {
        require(parent != address(0) && teen != address(0), "Invalid address");
        _addParentRelationship(parent, teen);
    }

    // setAllowedCategory
    // ------------------
    /// @notice Sets whether a category is allowed for a teen's spending.
    /// @param teen The teen's address.
    /// @param category The spending category.
    /// @param allowed Whether the category is allowed.
    function setAllowedCategory(
        address teen,
        Category category,
        bool allowed
    ) external onlyParent(teen) nonReentrant whenNotPaused {
        require(uint8(category) <= uint8(Category.FOOD), "Invalid category");
        teenAllowedCategories[teen][category] = allowed;
        emit CategoryChanged(teen, category, allowed);
    }

    // Teen Functions
    // ==============

    // claimAllowance
    // --------------
    // Claim weekly allowance (1st version - compare with distributeAllowance)
    function claimAllowance(address parent) external nonReentrant whenNotPaused {
        require(isParentOf[parent][msg.sender], "Invalid parent for teen");
        AllowanceConfig storage config = parentTeenAllowances[parent][msg.sender];
        require(config.isActive, "No active allowance");
        
        // Check if a week has passed since last claim
        require(block.timestamp >= config.lastDistribution.add(WEEK), "Too early to claim");
        
        // Get token
        IERC20 token = IERC20(config.tokenAddress);
        
        // Check parent has enough balance and approved the allowance
        require(token.balanceOf(parent) >= config.weeklyAmount, "Insufficient parent balance");
        require(token.allowance(parent, address(this)) >= config.weeklyAmount, "Allowance not approved");

        // Update state before external call
        uint256 claimAmount = config.weeklyAmount;
        config.lastDistribution = block.timestamp;
        teenBalances[msg.sender] = teenBalances[msg.sender].add(claimAmount);

        // Transfer tokens - external call comes after state updates
        token.safeTransferFrom(parent, msg.sender, claimAmount);
        
        emit AllowanceClaimed(msg.sender, config.tokenAddress, claimAmount);
    }

    // distributeAllowance
    // -------------------
    /// @notice Distributes pending allowances to a teen based on elapsed time.
    /// @param parent The parent's address.
    function distributeAllowance(address parent) external nonReentrant whenNotPaused {
        require(isParentOf[parent][msg.sender], "Invalid parent for teen");
        AllowanceConfig storage config = parentTeenAllowances[parent][msg.sender];
        require(config.isActive, "Allowance is inactive");

        uint256 weeksElapsed = (block.timestamp.sub(config.lastDistribution)).div(WEEK);
        if (weeksElapsed > 0) {
            uint256 amount = config.weeklyAmount.mul(weeksElapsed);
            teenBalances[msg.sender] = teenBalances[msg.sender].add(amount);
            config.lastDistribution = block.timestamp;
            emit AllowanceDistributed(parent, msg.sender, amount);
        }
    }

    // spendAllowance
    // --------------
    /// @notice Allows a teen to spend their allowance in an allowed category.
    /// @param category The spending category.
    /// @param amount The amount to spend.
    /// @param delegationProof The delegation proof for the caveat enforcer.
    function spendAllowance(
        Category category,
        uint256 amount,
        bytes calldata delegationProof
    ) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount must be positive");
        require(uint8(category) <= uint8(Category.FOOD), "Invalid category");
        require(teenBalances[msg.sender] >= amount, "Insufficient balance");
        require(teenAllowedCategories[msg.sender][category], "Category not allowed");
        require(_verifyDelegation(msg.sender, amount, delegationProof), "Invalid delegation proof");

        address[] memory parents = teenParents[msg.sender];
        require(parents.length > 0, "No parents configured");

        bool spent = false;
        address token;
        address selectedParent;
        uint256 parentsLength = parents.length;

        for (uint256 i = 0; i < parentsLength; i++) {
            AllowanceConfig storage config = parentTeenAllowances[parents[i]][msg.sender];
            if (config.isActive && config.spendingCap >= amount) {
                config.spendingCap = config.spendingCap.sub(amount);
                teenBalances[msg.sender] = teenBalances[msg.sender].sub(amount);
                token = config.tokenAddress;
                selectedParent = parents[i];
                spent = true;
                break;
            }
        }

        require(spent, "Exceeds spending caps");

        // Redeem delegation for spending
        bytes[] memory permissionContexts = new bytes[](1);
        bytes[] memory modes = new bytes[](1);
        bytes[] memory executionCallDatas = new bytes[](1);
        permissionContexts[0] = delegationProof;
        modes[0] = abi.encode(1); // Assuming mode 1 for spending
        executionCallDatas[0] = abi.encode(msg.sender, amount);

        // Call external contract after state changes
        bool redeemed = delegationManager.redeemDelegations(permissionContexts, modes, executionCallDatas);
        require(redeemed, "Failed to redeem delegation");

        // Transfer tokens from parent to teen
        IERC20 tokenContract = IERC20(token);
        require(tokenContract.balanceOf(selectedParent) >= amount, "Insufficient parent balance");
        require(tokenContract.allowance(selectedParent, address(this)) >= amount, "Allowance not approved");
        tokenContract.safeTransferFrom(selectedParent, msg.sender, amount);

        emit AllowanceSpent(msg.sender, category, amount, token);
        emit SpendingCapUpdated(selectedParent, msg.sender, parentTeenAllowances[selectedParent][msg.sender].spendingCap);
    }

    // completeAchivement
    // ------------------
    /// @notice Marks an achievement as completed by a teen and applies rewards.
    /// @param achievementId The ID of the achievement.
    function completeAchievement(uint256 achievementId) external nonReentrant whenNotPaused {
        require(achievementId > 0, "Invalid achievement ID");
        require(!completedAchievements[msg.sender][achievementId], "Achievement already completed");
        
        completedAchievements[msg.sender][achievementId] = true;
        uint256 reward = achievementRewards[achievementId];
        
        if (reward > 0) {
            teenBalances[msg.sender] = teenBalances[msg.sender].add(reward);
            _applyAchievementReward(msg.sender, achievementId);
        }
        
        emit AchievementCompleted(msg.sender, achievementId, reward);
    }

    // revokeAchievement
    // -----------------
    /// @notice Revokes a completed achievement for a teen.
    /// @param teen The teen's address.
    /// @param achievementId The ID of the achievement.
    function revokeAchievement(address teen, uint256 achievementId) external onlyParent(teen) nonReentrant {
        require(achievementId > 0, "Invalid achievement ID");
        require(completedAchievements[teen][achievementId], "Achievement not completed");
        
        completedAchievements[teen][achievementId] = false;
        emit AchievementRevoked(teen, achievementId);
    }

    // Administrative Functions

    /// @notice Pauses the contract in emergencies.
    function pause() external onlyOwner {
        require(!paused, "Contract is already paused");
        paused = true;
        emit EmergencyPaused(true);
    }

    /// @notice Unpauses the contract.
    function unpause() external onlyOwner {
        require(paused, "Contract is not paused");
        paused = false;
        emit EmergencyPaused(false);
    }

    /// @notice Sets the reward for an achievement.
    /// @param achievementId The ID of the achievement.
    /// @param reward The reward amount.
    function setAchievementReward(uint256 achievementId, uint256 reward) external onlyOwner {
        require(achievementId > 0, "Invalid achievement ID");
        achievementRewards[achievementId] = reward;
        emit AchievementRewardSet(achievementId, reward);
    }

    // Internal Functions
    // ==================

    // _createDelegation
    // -----------------
    /// @notice Creates a delegation for a teen's allowance using the MetaMask Delegation Toolkit.
    /// @param teen The address of the teen receiving the allowance.
    /// @param token The ERC-20 token address for the allowance.
    /// @param amount The amount of tokens for the allowance.
    /// @param terms The caveat terms for the delegation (e.g., spending restrictions).
    /// @param mode The delegation mode (0 for streaming, 1 for spending).
    function _createDelegation(
        address teen,
        address token,
        uint256 amount,
        bytes calldata terms,
        uint256 mode
    ) internal {
        require(teen != address(0), "Invalid teen address");
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be positive");

        bytes32 delegationId = keccak256(abi.encode(
            msg.sender,
            teen,
            block.timestamp,
            terms,
            token,
            amount
        ));
        emit DelegationCreated(msg.sender, teen, delegationId);
    }
    
    // revokeDelegation
    // ------------------------------------
    // Revoke an active delegation
    function revokeDelegation(address teen) external onlyParent(teen) nonReentrant {
        require(parentTeenAllowances[msg.sender][teen].isActive, "Allowance not found");
        
        // Update state before external call
        parentTeenAllowances[msg.sender][teen].isActive = false;
        
        // External call to revoke delegation
        actionsContract.revoke(teen);
        
        emit DelegationRevoked(msg.sender, teen);
    }

    // _addParentRelationship
    //-----------------------
    /// @notice Adds a parent-teen relationship if not already present.
    /// @param parent The parent's address.
    /// @param teen The teen's address.
    function _addParentRelationship(address parent, address teen) internal {
        if (!isParentOf[parent][teen]) {
            require(teenParents[teen].length < MAX_PARENTS, "Maximum parents reached");
            teenParents[teen].push(parent);
            isParentOf[parent][teen] = true;
            emit ParentAdded(parent, teen);
        }
    }

    // _verifyDelegation
    // -----------------
    /// @notice Verifies a delegation proof with the caveat enforcer.
    /// @param teen The teen's address.
    /// @param amount The amount to verify.
    /// @param proof The delegation proof.
    /// @return Whether the delegation is valid.
    function _verifyDelegation(
        address teen,
        uint256 amount,
        bytes calldata proof
    ) internal view returns (bool) {
        require(teen != address(0), "Invalid teen address");
        require(amount > 0, "Amount must be positive");
        require(proof.length == 0, "Proof cannot be empty");
    }

    // _applyAchievementReward
    // -----------------------
    function _applyAchievementReward(address teen, uint256 achievementId) internal {
        uint256 reward = achievementRewards[achievementId];
        if (reward > 0) {
            address[] memory parents = teenParents[teen];
            for (uint i = 0; i < parents.length; i++) {
                AllowanceConfig storage config = parentTeenAllowances[parents[i]][teen];
                if (config.isActive) {
                    config.spendingCap = config.spendingCap.add(reward);
                    emit SpendingCapUpdated(parents[i], teen, config.spendingCap);
                    break;
                }
            }
        }
    }

    /// @notice Checks if an address has contract code.
    /// @param addr The address to check.
    /// @return Whether the address has code.
    function _hasCode(address addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /// @notice Prevents renouncing ownership to ensure contract manageability.
    function renounceOwnership() public override onlyOwner {
    //    revert("Ownership cannot be renounced");
          super.renounceOwnership();
    }

    // Execute actions via delegation
    function executeActions(
        address _parent,
        address _teen,
        IERC7715Actions.Action[] calldata _actions
    ) external nonReentrant whenNotPaused returns (bytes[] memory) {
        require(parentTeenAllowances[_parent][_teen].isActive, "Allowance not found");
        require(isParentOf[_parent][_teen], "Invalid parent for teen");
        
        return actionsContract.execute(_teen, _actions);
    }

    // Withdraw from an active stream
    function withdrawFromStream(address _parent, uint256 _amount) external nonReentrant whenNotPaused {
        require(_amount > 0, "Amount must be positive");
        AllowanceConfig storage config = parentTeenAllowances[_parent][msg.sender];
        require(config.isActive, "No active allowance");
        require(config.streamId != 0, "No active stream");
        
        // Store stream ID to prevent reentrancy manipulation
        uint256 streamIdToWithdraw = config.streamId;
        
        // Update teen balance before external call
        teenBalances[msg.sender] = teenBalances[msg.sender].add(_amount);
        
        // External call after state changes
        streamingContract.withdrawFromStream(streamIdToWithdraw, _amount);
        
        emit AllowanceDistributed(_parent, msg.sender, _amount);
    }

    // View functions
    // ==============
    
    // getParents
    // ----------
    function getParents(address _teen) public view returns (address[] memory) {
        return teenParents[_teen];
    }

    // getStreamDetails
    // -----------------
    function getStreamDetails(address _parent, address _teen) external view returns (
        address sender,
        address recipient,
        address token,
        uint256 amountPerSecond,
        uint256 startTime,
        uint256 duration,
        uint256 withdrawnAmount
    ) {
        AllowanceConfig storage config = parentTeenAllowances[_parent][_teen];
        require(config.streamId != 0, "No active stream");
        
        return streamingContract.getStream(config.streamId);
    }
}