// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

interface IVerifyingOperatorVault {
    error AccessControlBadConfirmation();
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error AddressEmptyCode(address target);
    error ERC1967InvalidImplementation(address implementation);
    error ERC1967NonPayable();
    error FailedCall();
    error InvalidInitialization();
    error NotInitializing();
    error SafeERC20FailedOperation(address token);
    error UUPSUnauthorizedCallContext();
    error UUPSUnsupportedProxiableUUID(bytes32 slot);
    error VerifyingOperatorVault__AutoUpdateEnabled();
    error VerifyingOperatorVault__IncorrectSlippage();
    error VerifyingOperatorVault__InvalidImplementation();
    error VerifyingOperatorVault__InvalidToken();
    error VerifyingOperatorVault__NotAuthorized();
    error VerifyingOperatorVault__PendingDepositsNotUnlocked();
    error VerifyingOperatorVault__VaultNotEnabled();
    error VerifyingOperatorVault__WithdrawDeadlineNotReached();

    event AutoUpdateToggled(bool isEnabled);
    event CollateralStakedInPending(uint256 _amount, uint256 _inclusionTimestamp);
    event Initialized(uint64 version);
    event PendingStakeConsolidated(uint256 amount);
    event RewardClaimed(address user, uint256 amount);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event SlippageUpdated(uint256 newSlippage);
    event StakeDelayUpdated(uint256 newStakedDelay);
    event StakeWithdrawn(uint256 amount);
    event TokenizedRealEstateAdded(address tokenizedRealEstate);
    event Upgraded(address indexed implementation);
    event WithdrawPending(uint256 amount, uint256 deadline);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function UPGRADER_ROLE() external view returns (bytes32);
    function UPGRADE_INTERFACE_VERSION() external view returns (string memory);
    function addNewTokenizedRealEstate(address _tokenizedRealEstate) external;
    function claimRewardFromStaking() external;
    function getPriceFromTokenToAnotherToken(address _tokenA, address _tokenB, uint256 _tokenAmountA)
        external
        view
        returns (uint256);
    function getRealEstateRegistry() external view returns (address);
    function getRewards() external view returns (uint256);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function initialize(address _operator, address _registry, address _token, bool _isAutoUpdateEnabled) external;
    function isAutoUpdateEnabled() external view returns (bool);
    function proxiableUUID() external view returns (bytes32);
    function receiveRewards(address _rewardToken, uint256 _amount) external returns (uint256 utilizedAmount);
    function renounceRole(bytes32 role, address callerConfirmation) external;
    function revokeRole(bytes32 role, address account) external;
    function setMaxSlippage(uint256 _newSlippage) external;
    function setStakeDelay(uint256 _newStakeDelay) external;
    function stakeCollateral(uint256 _amount) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function toggleAutoUpdate() external;
    function unlockPendingDeposits() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
    function withdrawFromPending() external;
    function withdrawStake(uint256 _amount) external;
    function slashVault() external;
}