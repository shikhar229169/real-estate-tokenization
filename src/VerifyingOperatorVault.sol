// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { IRealEstateRegistry } from "./interfaces/IRealEstateRegistry.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VerifyingOperatorVault is Initializable, UUPSUpgradeable, AccessControlUpgradeable {
    // errors
    error VerifyingOperatorVault__AutoUpdateEnabled();
    error VerifyingOperatorVault__InvalidImplementation();
    error VerifyingOperatorVault__VaultNotEnabled();

    // variables
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    address private s_operator;
    address private s_registry;
    address private s_token;
    bool private s_isAutoUpdateEnabled;
    address private immutable i_thisContract;

    // events

    // modifiers
    modifier vaultEnabled() {
        require(IRealEstateRegistry(s_registry).getIsVaultApproved(s_operator), VerifyingOperatorVault__VaultNotEnabled());
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
}