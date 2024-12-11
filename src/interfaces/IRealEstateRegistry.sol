// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

interface IRealEstateRegistry {
    struct OperatorInfo {
        address vault;
        string ensName;
        uint256 stakedCollateralInFiat;
        uint256 stakedCollateralInToken;
        address token;
        uint256 timestamp;
        bool isApproved;
    }

    error AccessControlBadConfirmation();
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error ECDSAInvalidSignature();
    error ECDSAInvalidSignatureLength(uint256 length);
    error ECDSAInvalidSignatureS(bytes32 s);
    error InvalidShortString();
    error RealEstateRegistry__ENSNameAlreadyExist();
    error RealEstateRegistry__InsufficientCollateral();
    error RealEstateRegistry__InvalidCollateral();
    error RealEstateRegistry__InvalidDataFeeds();
    error RealEstateRegistry__InvalidENSName();
    error RealEstateRegistry__InvalidSignature();
    error RealEstateRegistry__InvalidToken();
    error RealEstateRegistry__NativeNotRequired();
    error RealEstateRegistry__OperatorAlreadyExist();
    error RealEstateRegistry__TransferFailed();
    error SafeERC20FailedOperation(address token);
    error StringTooLong(string str);

    event CollateralUpdated(uint256 newCollateral);
    event EIP712DomainChanged();
    event OperatorVaultApproved(address approver, address operator);
    event OperatorVaultRegistered(address operator, address vault);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function APPROVER_ROLE() external view returns (bytes32);
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function SETTER_ROLE() external view returns (bytes32);
    function SIGNER_ROLE() external view returns (bytes32);
    function SLASHER_ROLE() external view returns (bytes32);
    function addCollateralToken(address _newToken, address _dataFeed) external;
    function approveOperatorVault(string memory _operatorVaultEns) external;
    function depositCollateralAndRegisterVault(
        string memory _ensName,
        address _paymentToken,
        bytes memory _signature,
        bool _autoUpdateEnabled
    ) external payable;
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
    function emergencyWithdrawToken(address _token) external;
    function forceUpdateOperatorVault(string memory _operatorVaultEns) external;
    function getAcceptedTokenOnChain(address _baseAcceptedToken, uint256 _chainId) external view returns (address);
    function getAcceptedTokens() external view returns (address[] memory);
    function getAllOperators() external view returns (address[] memory);
    function getAssetTokenizationManager() external view returns (address);
    function getDataFeedForToken(address _token) external view returns (address);
    function getFiatCollateralRequiredForOperator() external view returns (uint256);
    function getIsVaultApproved(address _operator) external view returns (bool);
    function getMaxOpFiatCollateral() external pure returns (uint256);
    function getMinOpFiatCollateral() external pure returns (uint256);
    function getOperatorENSName(address _operator) external view returns (string memory);
    function getOperatorFromEns(string memory _ensName) external view returns (address);
    function getOperatorInfo(address _operator) external view returns (OperatorInfo memory);
    function getOperatorVault(address _operator) external view returns (address);
    function getOperatorVaultImplementation() external view returns (address);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function getSwapRouter() external view returns (address);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function prepareRegisterVaultHash(string memory _ensName) external view returns (bytes32);
    function renounceRole(bytes32 role, address callerConfirmation) external;
    function revokeRole(bytes32 role, address account) external;
    function setCollateralRequiredForOperator(uint256 _newOperatorCollateral) external;
    function setSwapRouter(address _swapRouter) external;
    function setTokenForAnotherChain(address _tokenOnBaseChain, uint256 _chainId, address _tokenOnAnotherChain)
        external;
    function slashOperatorVault(string memory _ensName) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function updateVOVImplementation(address _newVerifyingOpVaultImplementation) external;
}