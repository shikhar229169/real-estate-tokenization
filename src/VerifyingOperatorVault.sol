// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { IRealEstateRegistry } from "./interfaces/IRealEstateRegistry.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { ISwapRouter } from "./interfaces/ISwapRouter.sol";
import { console } from "forge-std/Test.sol";

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

contract VerifyingOperatorVault is Initializable, UUPSUpgradeable, AccessControlUpgradeable {
    using SafeERC20 for IERC20;

    // errors
    error VerifyingOperatorVault__AutoUpdateEnabled();
    error VerifyingOperatorVault__InvalidImplementation();
    error VerifyingOperatorVault__VaultNotEnabled();
    error VerifyingOperatorVault__NotAuthorized();
    error VerifyingOperatorVault__PendingDepositsNotUnlocked();
    error VerifyingOperatorVault__WithdrawDeadlineNotReached();
    error VerifyingOperatorVault__InvalidToken();
    error VerifyingOperatorVault__IncorrectSlippage();

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
    address[] private s_tokenizedRealEstateAddresses;
    bool private s_isSlashed;

    mapping(address user => UserDepositInfo) private s_userDepositInfo;
    mapping(address user => uint256 claim) private s_userClaimableReward;
    mapping(address user => UserWithdrawInfo) private s_userWithdrawInfo;
    uint256 private s_totalStakedDeposit;
    uint256 private rewardPerTokenStored;
    uint256 private s_stakeDelay;
    uint256 private s_maxSlippage;
    uint256 private HUNDRED_PC = 100e18;
    uint256 private constant SWAP_DEADLINE_DELAY = 10 minutes;
    uint24 private constant FEE = 3000;

    // events
    event StakeDelayUpdated(uint256 newStakedDelay);
    event AutoUpdateToggled(bool isEnabled);
    event CollateralStakedInPending(uint256 _amount, uint256 _inclusionTimestamp);
    event PendingStakeConsolidated(uint256 amount);
    event WithdrawPending(uint256 amount, uint256 deadline);
    event StakeWithdrawn(uint256 amount);
    event RewardClaimed(address user, uint256 amount);
    event SlippageUpdated(uint256 newSlippage);
    event TokenizedRealEstateAdded(address tokenizedRealEstate);

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

    modifier onlyOperator() {
        require(msg.sender == s_operator, VerifyingOperatorVault__NotAuthorized());
        _;
    }

    modifier onlyTokenizationManager {
        require(msg.sender == IRealEstateRegistry(s_registry).getAssetTokenizationManager(), VerifyingOperatorVault__NotAuthorized());
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
        s_maxSlippage = 3e18;
        _grantRole(DEFAULT_ADMIN_ROLE, _operator);
        _grantRole(UPGRADER_ROLE, _operator);
        _grantRole(UPGRADER_ROLE, _registry);
    }

    function _authorizeUpgrade(address newImplementation) internal view override vaultEnabled onlyRole(UPGRADER_ROLE) {
        address _currentImp = IRealEstateRegistry(s_registry).getOperatorVaultImplementation();
        require(_currentImp == newImplementation && newImplementation != i_thisContract, VerifyingOperatorVault__InvalidImplementation());
        require(!s_isAutoUpdateEnabled, VerifyingOperatorVault__AutoUpdateEnabled());
    }

    function slashVault() external {
        require(msg.sender == s_registry, VerifyingOperatorVault__NotAuthorized());
        s_isSlashed = true;
    } 

    function toggleAutoUpdate() external vaultEnabled onlyRole(DEFAULT_ADMIN_ROLE) {
        if (s_isAutoUpdateEnabled) {
            address _currentImp = IRealEstateRegistry(s_registry).getOperatorVaultImplementation();
            StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _currentImp;
        }

        s_isAutoUpdateEnabled = !s_isAutoUpdateEnabled;
        emit AutoUpdateToggled(s_isAutoUpdateEnabled);
    }

    function setStakeDelay(uint256 _newStakeDelay) external requireRoleFromRegistry(DEFAULT_ADMIN_ROLE, msg.sender) {
        s_stakeDelay = _newStakeDelay;
        emit StakeDelayUpdated(_newStakeDelay);
    }

    function setMaxSlippage(uint256 _newSlippage) external onlyOperator {
        require(_newSlippage <= HUNDRED_PC, VerifyingOperatorVault__IncorrectSlippage());
        s_maxSlippage = _newSlippage;
        emit SlippageUpdated(_newSlippage);
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

    /**
     * @dev the respective tokenized real estate contract approves this contract to spend the reward tokens
     * @return utilizedAmount The amount of reward token utilized (ensuring TRE uses them back for incentive pool of real estate token holders)
     */
    function receiveRewards(address _rewardToken, uint256 _amount) external onlyTokenizationManager returns (uint256 utilizedAmount) {
        uint256 _receivedAmount;
        uint256 _receivedAmountVaultNative;

        if (s_totalStakedDeposit > 0) {
            _receivedAmount = _amount;
        }
        else {
            _receivedAmount = (40e18 * _amount) / HUNDRED_PC;
        }

        IERC20(_rewardToken).safeTransferFrom(msg.sender, address(this), _receivedAmount);

        if (_rewardToken != s_token) {
            uint256 vaultNativeTokenPrice = getPriceFromTokenToAnotherToken(_rewardToken, s_token, _receivedAmount);
            uint256 minReceived = ((HUNDRED_PC - s_maxSlippage) * vaultNativeTokenPrice) / HUNDRED_PC;
            _receivedAmountVaultNative = _performSwap(_rewardToken, s_token, _receivedAmount, minReceived);
        }
        else {
            _receivedAmountVaultNative = _receivedAmount;
        }

        if (s_totalStakedDeposit > 0) {
            // 40% to operator, rest 60% among collateral stakers
            uint256 operatorClaimable = (40e18 * _receivedAmountVaultNative) / HUNDRED_PC;
            uint256 toDistributeAmongStakers = _receivedAmountVaultNative - operatorClaimable;
            uint256 decimalsAdjusted = 10 ** IERC20Decimals(s_token).decimals();

            s_userClaimableReward[s_operator] += operatorClaimable;
            rewardPerTokenStored += (toDistributeAmongStakers * decimalsAdjusted) / s_totalStakedDeposit;
        }
        else {
            // no collateral staked by users, then 40% go to operator
            /// @dev the rest 60% is not transferred in here, and it will be added to the real estate token holders incetive pool
            s_userClaimableReward[s_operator] += _receivedAmountVaultNative;
        }

        return _receivedAmount;
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

    function addNewTokenizedRealEstate(address _tokenizedRealEstate) external onlyTokenizationManager {
        s_tokenizedRealEstateAddresses.push(_tokenizedRealEstate);
        emit TokenizedRealEstateAdded(_tokenizedRealEstate);
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

    function getPriceFromTokenToAnotherToken(address _tokenA, address _tokenB, uint256 _tokenAmountA) public view returns (uint256) {
        AggregatorV3Interface pfA = AggregatorV3Interface(IRealEstateRegistry(s_registry).getDataFeedForToken(_tokenA));
        AggregatorV3Interface pfB = AggregatorV3Interface(IRealEstateRegistry(s_registry).getDataFeedForToken(_tokenB));

        require(address(pfA) != address(0) && address(pfB) != address(0), VerifyingOperatorVault__InvalidToken());

        uint256 aDecimals;
        uint256 bDecimals;

        if (_tokenA == address(0)) {
            aDecimals = 18;
        }
        else {
            aDecimals = IERC20Decimals(_tokenA).decimals();
        }

        if (_tokenB == address(0)) {
            bDecimals = 18;
        }
        else {
            bDecimals = IERC20Decimals(_tokenB).decimals();
        }

        (, int256 priceA, , , ) = pfA.latestRoundData();
        (, int256 priceB, , , ) = pfB.latestRoundData();
        uint8 decimalsPfA = pfA.decimals();
        uint8 decimalsPfB = pfB.decimals();

        // 1 A = x usd
        // 1 B = y usd
        // y usd = 1 B
        // x usd = x / y B
        // 1 A = x / y B
        // k A = (k * x) / y B
        // num -> decPfB + decB
        // dem -> decPfA + decA

        uint256 num = 10 ** (bDecimals + decimalsPfB);
        uint256 den = 10 ** (aDecimals + decimalsPfA);
        uint256 amountB = (_tokenAmountA * uint256(priceA) * num) / (uint256(priceB) * den);
        return amountB;
    }

    function _performSwap(address _inToken, address _outToken, uint256 _amount, uint256 _minOut) internal returns (uint256 _amountOut) {
        // if (_inToken == address(0)) IWETH(weth).deposit{value: _amount}();
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: _inToken,
            tokenOut: _outToken,
            fee: FEE,        // @todo decide fees on the basis of priority
            recipient: address(this),
            deadline: block.timestamp + SWAP_DEADLINE_DELAY,
            amountIn: _amount,
            amountOutMinimum: _minOut,
            sqrtPriceLimitX96: 0
        });

        address _swapRouter = IRealEstateRegistry(s_registry).getSwapRouter();

        IERC20(_inToken).approve(_swapRouter, params.amountIn);
        _amountOut = ISwapRouter(_swapRouter).exactInputSingle(params);

        // if (_outToken == NATIVE) {
        //     IWETH(weth).withdraw(_amountOut);
        // }
    }

    function isAutoUpdateEnabled() external view returns (bool) {
        return s_isAutoUpdateEnabled;
    }

    function getRealEstateRegistry() external view returns (address) {
        return s_registry;
    }

    function getRewards() external view returns (uint256) {
        UserDepositInfo memory _info = s_userDepositInfo[msg.sender];
        uint256 accumualated = (rewardPerTokenStored - _info.rewardClaimedPerToken) * _info.amountDeposited;
        return s_userClaimableReward[msg.sender] + accumualated;
    }

    function getIsSlashed() external view returns (bool) {
        return s_isSlashed;
    }
}