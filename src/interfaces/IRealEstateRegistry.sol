// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

interface IRealEstateRegistry {
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

    function APPROVER_ROLE() external view returns (bytes32);
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function SETTER_ROLE() external view returns (bytes32);
    function SIGNER_ROLE() external view returns (bytes32);
    function SLASHER_ROLE() external view returns (bytes32);
    function addCollateralToken(address _newToken, address _dataFeed) external;
    function approveOperatorVault(string memory _operatorVaultEns) external;
    function depositCollateralAndRegisterVault(
        address[] memory _delegates,
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
    function fixCollateral() external payable;
    function forceUpdateOperatorVault(string memory _operatorVaultEns) external;
    function getAcceptedTokens() external view returns (address[] memory);
    function getDataFeedForToken(address _token) external view returns (address);
    function getDelegates(address _operator) external view returns (address[] memory);
    function getFiatCollateralRequiredForOperator() external view returns (uint256);
    function getIsVaultApproved(address _operator) external view returns (bool);
    function getMaxDelegates() external view returns (uint256);
    function getMaxOpFiatCollateral() external pure returns (uint256);
    function getMinDelegates() external view returns (uint256);
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
    function prepareRegisterVaultHash(address[] memory _delegates, string memory _ensName)
        external
        view
        returns (bytes32);
    function renounceRole(bytes32 role, address callerConfirmation) external;
    function revokeRole(bytes32 role, address account) external;
    function setCollateralRequiredForOperator(uint256 _newOperatorCollateral) external;
    function setSwapRouter(address _swapRouter) external;
    function slashOperatorVault(string memory _ensName) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function updateVOVImplementation(address _newVerifyingOpVaultImplementation) external;
}