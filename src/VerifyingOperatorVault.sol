// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { IRealEstateRegistry } from "./interfaces/IRealEstateRegistry.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract VerifyingOperatorVault is Initializable, UUPSUpgradeable, AccessControlUpgradeable {
    using SafeERC20 for IERC20;

    // errors
    error VerifyingOperatorVault__AutoUpdateEnabled();
    error VerifyingOperatorVault__InvalidImplementation();
    error VerifyingOperatorVault__VaultNotEnabled();
    error VerifyingOperatorVault__NotAuthorized();
    error VerifyingOperatorVault__PendingDepositsNotUnlocked();
    error VerifyingOperatorVault__WithdrawDeadlineNotReached();

    // structs
    struct UserDepositInfo {
        uint256 amountDeposited;
        uint256 pendingAmount;
        uint256 pendingAmountInclusionTime;
        uint256 rewardClaimedPerToken;
    }

    struct UserWithdrawInfo {
        uint256 amount;
        uint256 deadline;
    }

    // variables
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    address private s_operator;
    address private s_registry;
    address private s_token;
    bool private s_isAutoUpdateEnabled;
    address private immutable i_thisContract;

    mapping(address user => UserDepositInfo) private s_userDepositInfo;
    mapping(address user => uint256 claim) private s_userClaimableReward;
    mapping(address user => UserWithdrawInfo) private s_userWithdrawInfo;
    uint256 private s_totalStakedDeposit;
    uint256 private rewardPerTokenStored;
    uint256 private s_stakeDelay;

    // events
    event StakeDelayUpdated(uint256 newStakedDelay);
    event AutoUpdateToggled(bool isEnabled);
    event CollateralStakedInPending(uint256 _amount, uint256 _inclusionTimestamp);
    event PendingStakeConsolidated(uint256 amount);
    event WithdrawPending(uint256 amount, uint256 deadline);
    event StakeWithdrawn(uint256 amount);
    event RewardClaimed(address user, uint256 amount);

    // modifiers
    modifier vaultEnabled() {
        require(IRealEstateRegistry(s_registry).getIsVaultApproved(s_operator), VerifyingOperatorVault__VaultNotEnabled());
        _;
    }

    modifier requireRoleFromRegistry(bytes32 _role, address _user) {
        require(IRealEstateRegistry(s_registry).hasRole(_role, _user), VerifyingOperatorVault__NotAuthorized());
        _;
    }

    modifier updateUserRewards(address _user) {
        UserDepositInfo memory _info = s_userDepositInfo[_user];
        uint256 claimableBalance = (rewardPerTokenStored - _info.rewardClaimedPerToken) * _info.amountDeposited;
        s_userClaimableReward[_user] += claimableBalance;
        s_userDepositInfo[_user].rewardClaimedPerToken = rewardPerTokenStored;
        _;
    }

    // constructor
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        i_thisContract = address(this);
        _disableInitializers();
    }

    function initialize(address _operator, address _registry, address _token, bool _isAutoUpdateEnabled) public initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        s_operator = _operator;
        s_registry = _registry;
        s_token = _token;
        s_isAutoUpdateEnabled = _isAutoUpdateEnabled;
        s_stakeDelay = 1 weeks;
        _grantRole(DEFAULT_ADMIN_ROLE, _operator);
        _grantRole(UPGRADER_ROLE, _operator);
        _grantRole(UPGRADER_ROLE, _registry);
    }

    function _authorizeUpgrade(address newImplementation) internal view override vaultEnabled onlyRole(UPGRADER_ROLE) {
        address _currentImp = IRealEstateRegistry(s_registry).getOperatorVaultImplementation();
        require(_currentImp == newImplementation && newImplementation != i_thisContract, VerifyingOperatorVault__InvalidImplementation());
        require(!s_isAutoUpdateEnabled, VerifyingOperatorVault__AutoUpdateEnabled());
    }

    function toggleAutoUpdate() external vaultEnabled onlyRole(DEFAULT_ADMIN_ROLE) {
        if (s_isAutoUpdateEnabled) {
            address _currentImp = IRealEstateRegistry(s_registry).getOperatorVaultImplementation();
            if (_currentImp != i_thisContract) {
                StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _currentImp;
            }
        }

        s_isAutoUpdateEnabled = !s_isAutoUpdateEnabled;
        emit AutoUpdateToggled(s_isAutoUpdateEnabled);
    }

    function setStakeDelay(uint256 _newStakeDelay) external requireRoleFromRegistry(DEFAULT_ADMIN_ROLE, msg.sender) {
        s_stakeDelay = _newStakeDelay;
        emit StakeDelayUpdated(_newStakeDelay);
    }

    function stakeCollateral(uint256 _amount) external vaultEnabled {
        require(_amount > 0, "Amount must be greater than 0");
        _unlockPendingDeposits(msg.sender, false);

        UserDepositInfo storage _info = s_userDepositInfo[msg.sender];
        _info.pendingAmount += _amount;
        _info.pendingAmountInclusionTime = block.timestamp + s_stakeDelay;

        emit CollateralStakedInPending(_amount, _info.pendingAmountInclusionTime);
        IERC20(s_token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    // @todo
    function receiveRewards() external {
        // the token the rewards will be received in
        // but the vault deals with a specific token, required to be swap
        // 40% to operator - make it available to operator
        // 60% among users - make it available here in this contract by updaing rewardPerTokenStored
    }

    function withdrawStake(uint256 _amount) external vaultEnabled {
        _unlockPendingDeposits(msg.sender, false);
        UserDepositInfo storage _depositInfo = s_userDepositInfo[msg.sender];
        UserWithdrawInfo storage _withdrawInfo = s_userWithdrawInfo[msg.sender];

        _depositInfo.amountDeposited -= _amount;
        s_totalStakedDeposit -= _amount;
        _withdrawInfo.amount += _amount;
        _withdrawInfo.deadline = block.timestamp + s_stakeDelay;
        emit WithdrawPending(_amount, _withdrawInfo.deadline);
    }

    function withdrawFromPending() external vaultEnabled {
        UserWithdrawInfo storage _withdrawInfo = s_userWithdrawInfo[msg.sender];
        require(block.timestamp >= _withdrawInfo.deadline, VerifyingOperatorVault__WithdrawDeadlineNotReached());

        uint256 _amount = _withdrawInfo.amount;
        delete _withdrawInfo.amount;

        emit StakeWithdrawn(_amount);
        IERC20(s_token).safeTransfer(msg.sender, _amount);
    }

    function claimRewardFromStaking() external updateUserRewards(msg.sender) {
        uint256 _amount = s_userClaimableReward[msg.sender];
        delete s_userClaimableReward[msg.sender];

        require(_amount > 0, "Amount must be greater than 0");

        emit RewardClaimed(msg.sender, _amount);
        IERC20(s_token).transfer(msg.sender, _amount);
    }

    function unlockPendingDeposits() external vaultEnabled {
        _unlockPendingDeposits(msg.sender, true);
    }


    function _unlockPendingDeposits(address _user, bool _toRevert) internal updateUserRewards(_user) {
        UserDepositInfo storage _info = s_userDepositInfo[_user];
        if (block.timestamp >= _info.pendingAmountInclusionTime) {
            emit PendingStakeConsolidated(_info.pendingAmount);
            _info.amountDeposited += _info.pendingAmount;
            s_totalStakedDeposit += _info.pendingAmount;
            delete _info.pendingAmount;
        }
        else if (_toRevert) {
            revert VerifyingOperatorVault__PendingDepositsNotUnlocked();
        }
    }

    function isAutoUpdateEnabled() external view returns (bool) {
        return s_isAutoUpdateEnabled;
    }

    function getRealEstateRegistry() external view returns (address) {
        return s_registry;
    }

    function getAllDelegates() external view returns (address[] memory) {
        return IRealEstateRegistry(s_registry).getDelegates(s_operator);
    }

    function getRewards() external view returns (uint256) {
        UserDepositInfo memory _info = s_userDepositInfo[msg.sender];
        uint256 accumualated = (rewardPerTokenStored - _info.rewardClaimedPerToken) * _info.amountDeposited;
        return s_userClaimableReward[msg.sender] + accumualated;
    }
}