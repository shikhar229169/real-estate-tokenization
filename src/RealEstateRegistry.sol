// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC1967ProxyAutoUp } from "./ERC1967ProxyAutoUp.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IVerifyingOperatorVault } from "./interfaces/IVerifyingOperatorVault.sol";

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

/// @notice This is the on-chain registry and manages the operators and atm
contract RealEstateRegistry is AccessControl {
    // libraries
    using SafeERC20 for IERC20;

    // errors
    error RealEstateRegistry__InvalidCollateral();
    error RealEstateRegistry__InsufficientCollateral();
    error RealEstateRegistry__InvalidDataFeeds();
    error RealEstateRegistry__InvalidToken();
    error RealEstateRegistry__TransferFailed();
    error RealEstateRegistry__OperatorAlreadyExist();
    error RealEstateRegistry__InvalidDelegates();
    error RealEstateRegistry__ENSNameAlreadyExist();
    error RealEstateRegistry__InvalidENSName();
    error RealEstateRegistry__NativeNotRequired();

    // structs
    struct OperatorInfo {
        address vault;
        address[] delegates;
        string ensName;
        uint256 stakedCollateralInFiat;
        uint256 stakedCollateralInToken;
        address token;
        uint256 timestamp;
        bool isApproved;
    }

    // variables
    bytes32 public constant SLASHER_ROLE = keccak256("SLASHER_ROLE");
    bytes32 public constant SETTER_ROLE = keccak256("SETTER_ROLE");
    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");

    uint256 private constant MIN_OP_FIAT_COLLATERAL = 40_000;
    uint256 private constant MAX_OP_FIAT_COLLATERAL = 1_20_000;
    uint256 private s_fiatCollateralRequiredForOperator;
    mapping(address => OperatorInfo) private s_operators;
    mapping(string => address) private s_ensToOperator;
    uint256 private s_minDelegates;
    uint256 private s_maxDelegates;
    mapping(address token => address dataFeed) private s_tokenToDataFeeds;
    address[] private s_acceptedTokens;
    address private s_verifyingOpVaultImplementation;
    mapping(address => bool) private s_usedDelegatesMap;

    // events
    event CollateralUpdated(uint256 newCollateral);
    event OperatorVaultRegistered(address operator, address vault);
    event OperatorVaultApproved(address approver, address operator);

    // modifiers
    modifier onlyAcceptedToken(address _token) {
        require(s_tokenToDataFeeds[_token] != address(0), RealEstateRegistry__InvalidToken());
        _;
    }

    // constructor
    constructor(address _slasher, uint256 _collateralReqInFiat, address[] memory _acceptedTokens, address[] memory _dataFeeds, uint256 _minDelegates, uint256 _maxDelegates, address _verifyingOpVaultImplementation) {
        require(_acceptedTokens.length == _dataFeeds.length, RealEstateRegistry__InvalidDataFeeds());

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SLASHER_ROLE, msg.sender);
        _grantRole(SLASHER_ROLE, _slasher);
        _grantRole(SETTER_ROLE, msg.sender);
        _grantRole(APPROVER_ROLE, msg.sender);

        s_fiatCollateralRequiredForOperator = _collateralReqInFiat;
        s_minDelegates = _minDelegates;
        s_maxDelegates = _maxDelegates;
        s_verifyingOpVaultImplementation = _verifyingOpVaultImplementation;
        for (uint256 i; i < _acceptedTokens.length; i++) {
            s_acceptedTokens.push(_acceptedTokens[i]);
            s_tokenToDataFeeds[_acceptedTokens[i]] = _dataFeeds[i];
        }
    }


    // functions
    function setCollateralRequiredForOperator(uint256 _newOperatorCollateral) external onlyRole(SETTER_ROLE) {
        require(_newOperatorCollateral >= MIN_OP_FIAT_COLLATERAL && _newOperatorCollateral <= MAX_OP_FIAT_COLLATERAL, RealEstateRegistry__InvalidCollateral());
        s_fiatCollateralRequiredForOperator = _newOperatorCollateral;
        emit CollateralUpdated(_newOperatorCollateral);
    }

    function addCollateralToken(address _newToken, address _dataFeed) external onlyRole(SETTER_ROLE) {
        s_acceptedTokens.push(_newToken);
        s_tokenToDataFeeds[_newToken] = _dataFeed;
    }

    function updateVOVImplementation(address _newVerifyingOpVaultImplementation) external onlyRole(SETTER_ROLE) {
        s_verifyingOpVaultImplementation = _newVerifyingOpVaultImplementation;
    }

    /**
     * 
     * @param _paymentToken The payment token in which collateral will be collected, address(0) for native token
     */
    function depositCollateralAndRegisterVault(address[] memory _delegates, string memory _ensName, address _paymentToken, bool _autoUpdateEnabled) external onlyAcceptedToken(_paymentToken) payable {
        require(!_isOperatorExist(msg.sender), RealEstateRegistry__OperatorAlreadyExist());
        require(_delegates.length >= s_minDelegates && _delegates.length <= s_maxDelegates, RealEstateRegistry__InvalidDelegates());
        require(s_ensToOperator[_ensName] == address(0), RealEstateRegistry__ENSNameAlreadyExist());
        require(bytes(_ensName).length > 0, RealEstateRegistry__InvalidENSName());
        _revertIfContainsDup(_delegates);

        uint256 tokenAmountRequired = _getAmountRequiredForToken(_paymentToken);
        uint256 refundAmount;

        if (_paymentToken == address(0)) {
            require(msg.value >= tokenAmountRequired, RealEstateRegistry__InsufficientCollateral());
            refundAmount = msg.value - tokenAmountRequired;
        }
        else {
            require(msg.value == 0, RealEstateRegistry__NativeNotRequired());
            IERC20(_paymentToken).safeTransferFrom(msg.sender, address(this), tokenAmountRequired);
        }

        s_ensToOperator[_ensName] = msg.sender;

        bytes32 _deploySalt = bytes32(uint256(uint160(msg.sender)));
        bytes memory _deployInitData = abi.encodeWithSelector(IVerifyingOperatorVault.initialize.selector, msg.sender, address(this), _paymentToken, _autoUpdateEnabled);
        ERC1967ProxyAutoUp _vaultProxy = new ERC1967ProxyAutoUp{ salt: _deploySalt }(s_verifyingOpVaultImplementation, _deployInitData);

        emit OperatorVaultRegistered(msg.sender, address(_vaultProxy));

        s_operators[msg.sender] = OperatorInfo({
            vault: address(_vaultProxy),
            delegates: _delegates,
            ensName: _ensName,
            stakedCollateralInFiat: s_fiatCollateralRequiredForOperator,
            stakedCollateralInToken: tokenAmountRequired,
            token: _paymentToken,
            timestamp: block.timestamp,
            isApproved: false
        });

        if (refundAmount > 0) {
            (bool s, ) = payable(msg.sender).call{ value: refundAmount }("");
            require(s, RealEstateRegistry__TransferFailed());
        }
    }

    function approveOperatorVault(string memory _operatorVaultEns) external onlyRole(APPROVER_ROLE) {
        address _operator = s_ensToOperator[_operatorVaultEns];
        require(_operator != address(0), RealEstateRegistry__InvalidENSName());
        s_operators[_operator].isApproved = true;
        emit OperatorVaultApproved(msg.sender, _operator);
    }

    function forceUpdateOperatorVault(string memory _operatorVaultEns) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address _operator = s_ensToOperator[_operatorVaultEns];
        require(_operator != address(0), RealEstateRegistry__InvalidENSName());
        IVerifyingOperatorVault(_operator).upgradeToAndCall(s_verifyingOpVaultImplementation, "");
    }

    // @todo implement
    function fixCollateral() external payable {

    }

    function slashOperatorVault(string memory _ensName) external onlyRole(SLASHER_ROLE) {
        
    }

    function _getAmountRequiredForToken(address _token) internal view returns(uint256 requiredAmount) {
        AggregatorV3Interface _dataFeed = AggregatorV3Interface(s_tokenToDataFeeds[_token]);

        (, int256 answer, , , ) = _dataFeed.latestRoundData();
        uint256 feedDecimals = _dataFeed.decimals();

        uint256 tokenDecimals;
        if (_token == address(0)) {
            tokenDecimals = 18;
        }
        else {
            tokenDecimals = IERC20Decimals(_token).decimals();
        }

        requiredAmount = s_fiatCollateralRequiredForOperator * (10 ** (tokenDecimals + feedDecimals)) / uint256(answer);
    }

    function _isOperatorExist(address _operator) internal view returns (bool) {
        return s_operators[_operator].vault != address(0);
    }

    function emergencyWithdrawToken(address _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_token == address(0)) {
            (bool s, ) = payable(msg.sender).call{ value: address(this).balance }("");
            require(s, RealEstateRegistry__TransferFailed());
        }
        else {
            IERC20(_token).safeTransfer(msg.sender, IERC20(_token).balanceOf(address(this)));
        }
    }

    function _revertIfContainsDup(address[] memory _delegates) internal {
        for (uint256 i; i < _delegates.length; i++) {
            require(!s_usedDelegatesMap[_delegates[i]], RealEstateRegistry__InvalidDelegates());
            s_usedDelegatesMap[_delegates[i]] = true;
        }
    }

    function getOperatorVaultImplementation() external view returns (address) {
        return s_verifyingOpVaultImplementation;
    }

    function getFiatCollateralRequiredForOperator() external view returns (uint256) {
        return s_fiatCollateralRequiredForOperator;
    }

    function getOperatorInfo(address _operator) external view returns (OperatorInfo memory) {
        return s_operators[_operator];
    }

    function getDataFeedForToken(address _token) external view returns (address) {
        return s_tokenToDataFeeds[_token];
    }

    function getAcceptedTokens() external view returns (address[] memory) {
        return s_acceptedTokens;
    }

    function getDelegates(address _operator) external view returns (address[] memory) {
        return s_operators[_operator].delegates;
    }

    function getOperatorVault(address _operator) external view returns (address) {
        return s_operators[_operator].vault;
    }

    function getIsVaultApproved(address _operator) external view returns (bool) {
        return s_operators[_operator].isApproved;
    }

    function getOperatorENSName(address _operator) external view returns (string memory) {
        return s_operators[_operator].ensName;
    }

    function getOperatorFromEns(string memory _ensName) external view returns (address) {
        return s_ensToOperator[_ensName];
    }

    function getMinDelegates() external view returns (uint256) {
        return s_minDelegates;
    }

    function getMaxDelegates() external view returns (uint256) {
        return s_maxDelegates;
    }

    function getMinOpFiatCollateral() external pure returns (uint256) {
        return MIN_OP_FIAT_COLLATERAL;
    }

    function getMaxOpFiatCollateral() external pure returns (uint256) {
        return MAX_OP_FIAT_COLLATERAL;
    }
}