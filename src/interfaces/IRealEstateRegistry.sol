// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

interface IRealEstateRegistry {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function SETTER_ROLE() external view returns (bytes32);
    function SLASHER_ROLE() external view returns (bytes32);
    function addCollateralToken(address _newToken, address _dataFeed) external;
    function depositCollateralAndRegisterVault(
        address[] memory _delegates,
        string memory _ensName,
        address _paymentToken
    ) external payable;
    function emergencyWithdrawToken(address _token) external;
    function fixCollateral() external payable;
    function getOperatorVaultImplementation() external view returns (address);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function renounceRole(bytes32 role, address callerConfirmation) external;
    function revokeRole(bytes32 role, address account) external;
    function setCollateralRequiredForOperator(uint256 _newOperatorCollateral) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function updateVOVImplementation(address _newVerifyingOpVaultImplementation) external;
}