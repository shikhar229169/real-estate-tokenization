// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC1967ProxyAutoUp } from "./ERC1967ProxyAutoUp.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IVerifyingOperatorVault } from "./interfaces/IVerifyingOperatorVault.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

/// @notice This is the on-chain registry and manages the operators and atm
contract RealEstateRegistry is AccessControl, EIP712 {
    // libraries
    using SafeERC20 for IERC20;

    // errors
    error RealEstateRegistry__InvalidCollateral();
    error RealEstateRegistry__InsufficientCollateral();
    error RealEstateRegistry__InvalidDataFeeds();
    error RealEstateRegistry__InvalidToken();
    error RealEstateRegistry__TransferFailed();
    error RealEstateRegistry__OperatorAlreadyExist();
    error RealEstateRegistry__ENSNameAlreadyExist();
    error RealEstateRegistry__InvalidENSName();
    error RealEstateRegistry__NativeNotRequired();
    error RealEstateRegistry__InvalidSignature();

    // structs
    struct OperatorInfo {
        address vault;
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
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    bytes32 private constant REGISTER_VAULT_TYPE_HASH = keccak256("REGISTER_VAULT(string ensName)");

    uint256 private constant MIN_OP_FIAT_COLLATERAL = 40_000;
    uint256 private constant MAX_OP_FIAT_COLLATERAL = 1_20_000;
    uint256 private s_fiatCollateralRequiredForOperator;
    address[] private s_allOperators;
    mapping(address => OperatorInfo) private s_operators;
    mapping(string => address) private s_ensToOperator;
    mapping(address token => address dataFeed) private s_tokenToDataFeeds;
    address[] private s_acceptedTokens;
    mapping(address tokenX => mapping(uint256 chainId => address tokenY)) private s_tokenOnAnotherChain;
    address private s_verifyingOpVaultImplementation;
    address private s_swapRouter;
    address private s_tokenizationManager;

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
    constructor(
        address _slasher,
        address _signer, 
        uint256 _collateralReqInFiat, 
        address[] memory _acceptedTokens, 
        address[] memory _dataFeeds, 
        address _verifyingOpVaultImplementation,
        address _swapRouter,
        address _tokenizationManager
    ) EIP712("RealEstateRegistry", "1.0.0") {
        require(_acceptedTokens.length == _dataFeeds.length, RealEstateRegistry__InvalidDataFeeds());

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SLASHER_ROLE, msg.sender);
        _grantRole(SLASHER_ROLE, _slasher);
        _grantRole(SETTER_ROLE, msg.sender);
        _grantRole(APPROVER_ROLE, msg.sender);
        _grantRole(SIGNER_ROLE, _signer);

        s_fiatCollateralRequiredForOperator = _collateralReqInFiat;
        s_verifyingOpVaultImplementation = _verifyingOpVaultImplementation;
        s_swapRouter = _swapRouter;
        s_tokenizationManager = _tokenizationManager;
        for (uint256 i; i < _acceptedTokens.length; i++) {
            s_acceptedTokens.push(_acceptedTokens[i]);
            s_tokenToDataFeeds[_acceptedTokens[i]] = _dataFeeds[i];
            s_tokenOnAnotherChain[_acceptedTokens[i]][block.chainid] = _acceptedTokens[i];
        }
    }


    // functions
    // @todo to remove
    function setCollateralRequiredForOperator(uint256 _newOperatorCollateral) external onlyRole(SETTER_ROLE) {
        require(_newOperatorCollateral >= MIN_OP_FIAT_COLLATERAL && _newOperatorCollateral <= MAX_OP_FIAT_COLLATERAL, RealEstateRegistry__InvalidCollateral());
        s_fiatCollateralRequiredForOperator = _newOperatorCollateral;
        emit CollateralUpdated(_newOperatorCollateral);
    }

    function setTokenForAnotherChain(address _tokenOnBaseChain, uint256 _chainId, address _tokenOnAnotherChain) external onlyRole(SETTER_ROLE) {
        require(s_tokenToDataFeeds[_tokenOnBaseChain] != address(0), RealEstateRegistry__InvalidToken());
        s_tokenOnAnotherChain[_tokenOnBaseChain][_chainId] = _tokenOnAnotherChain;
    }

    function addCollateralToken(address _newToken, address _dataFeed) external onlyRole(SETTER_ROLE) {
        s_acceptedTokens.push(_newToken);
        s_tokenToDataFeeds[_newToken] = _dataFeed;
    }

    function updateVOVImplementation(address _newVerifyingOpVaultImplementation) external onlyRole(SETTER_ROLE) {
        s_verifyingOpVaultImplementation = _newVerifyingOpVaultImplementation;
    }

    function setSwapRouter(address _swapRouter) external onlyRole(SETTER_ROLE) {
        s_swapRouter = _swapRouter;
    }

    /**
     * 
     * @param _paymentToken The payment token in which collateral will be collected, address(0) for native token
     */
    function depositCollateralAndRegisterVault(
        string memory _ensName, 
        address _paymentToken, 
        bytes memory _signature, 
        bool _autoUpdateEnabled
    ) external onlyAcceptedToken(_paymentToken) payable {
        require(!_isOperatorExist(msg.sender), RealEstateRegistry__OperatorAlreadyExist());
        require(s_ensToOperator[_ensName] == address(0), RealEstateRegistry__ENSNameAlreadyExist());
        require(bytes(_ensName).length > 0, RealEstateRegistry__InvalidENSName());

        _verifyHashWithRole(
            prepareRegisterVaultHash(_ensName), 
            _signature, 
            SIGNER_ROLE
        );

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
        s_allOperators.push(msg.sender);

        bytes32 _deploySalt = bytes32(uint256(uint160(msg.sender)));
        bytes memory _deployInitData = abi.encodeWithSelector(IVerifyingOperatorVault.initialize.selector, msg.sender, address(this), _paymentToken, _autoUpdateEnabled);
        ERC1967ProxyAutoUp _vaultProxy = new ERC1967ProxyAutoUp{ salt: _deploySalt }(s_verifyingOpVaultImplementation, _deployInitData);

        emit OperatorVaultRegistered(msg.sender, address(_vaultProxy));

        s_operators[msg.sender] = OperatorInfo({
            vault: address(_vaultProxy),
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

    // @todo 
    /**
     * 
     * @notice slash an operator vault that performs some malicious actions such as approving real estate without proper standards
     * @notice removes all the collateral from the vault inlcuding the users who have staked and send it to slasher contract 
     */
    function slashOperatorVault(string memory _ensName) external onlyRole(SLASHER_ROLE) {
        
    }

    function prepareRegisterVaultHash(string memory _ensName) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                REGISTER_VAULT_TYPE_HASH, 
                keccak256(abi.encodePacked(_ensName))
            )
        );

        return _hashTypedDataV4(structHash);
    }

    function _verifyHashWithRole(bytes32 _signedMessageHash, bytes memory _signature, bytes32 _role) internal view {
        address _signer = ECDSA.recover(_signedMessageHash, _signature);
        require(hasRole(_role, _signer), RealEstateRegistry__InvalidSignature());
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

    function getAcceptedTokenOnChain(address _baseAcceptedToken, uint256 _chainId) external view returns (address) {
        return s_tokenOnAnotherChain[_baseAcceptedToken][_chainId];
    }

    function getOperatorVault(address _operator) external view returns (address) {
        return s_operators[_operator].vault;
    }

    function getAllOperators() external view returns (address[] memory) {
        return s_allOperators;
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

    function getSwapRouter() external view returns (address) {
        return s_swapRouter;
    }

    function getMinOpFiatCollateral() external pure returns (uint256) {
        return MIN_OP_FIAT_COLLATERAL;
    }

    function getMaxOpFiatCollateral() external pure returns (uint256) {
        return MAX_OP_FIAT_COLLATERAL;
    }

    function getAssetTokenizationManager() external view returns (address) {
        return s_tokenizationManager;
    }
}