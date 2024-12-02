// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

interface IVerifyingOperatorVault {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function UPGRADER_ROLE() external view returns (bytes32);
    function UPGRADE_INTERFACE_VERSION() external view returns (string memory);
    function getRealEstateRegistry() external view returns (address);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function initialize(address _operator, address _registry, address _token, bool _isAutoUpdateEnabled) external;
    function isAutoUpdateEnabled() external view returns (bool);
    function proxiableUUID() external view returns (bytes32);
    function renounceRole(bytes32 role, address callerConfirmation) external;
    function revokeRole(bytes32 role, address account) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function toggleAutoUpdate() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}