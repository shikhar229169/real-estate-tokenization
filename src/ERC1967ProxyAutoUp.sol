// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { console } from "forge-std/Test.sol";
import { ERC1967Proxy, ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IRealEstateRegistry } from "./interfaces/IRealEstateRegistry.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

contract ERC1967ProxyAutoUp is ERC1967Proxy {

    constructor(address implementation, bytes memory _data) payable ERC1967Proxy(implementation, _data) {

    }

    function delegatedPower(address impl, bytes memory data) external returns (bytes memory) {
        (bool success, bytes memory res) = impl.delegatecall(data);
        require(success);
        return res;
    }


    function _implementation() internal view virtual override returns (address) {
        bytes memory _d1 = _makeDelegateCallFor(abi.encodePacked(abi.encodeWithSignature("isAutoUpdateEnabled()")));
        bool _isAutoUpdateEnabled = abi.decode(_d1, (bool));

        if (!_isAutoUpdateEnabled) {
            return ERC1967Utils.getImplementation();
        }

        bytes memory _d2 = _makeDelegateCallFor(abi.encodePacked(abi.encodeWithSignature("getRealEstateRegistry()")));
        address _registry = abi.decode(_d2, (address));
        return IRealEstateRegistry(_registry).getOperatorVaultImplementation();
    }

    function _makeDelegateCallFor(bytes memory _data) internal view returns (bytes memory) {
        address currImplementation = ERC1967Utils.getImplementation();
        (bool s, bytes memory data) = address(this).staticcall(abi.encodeWithSelector(this.delegatedPower.selector, currImplementation, _data));
        require(s);

        return abi.decode(data, (bytes));
    }

    function getImplementation() external view returns (address) {
        return _implementation();
    }

    receive() external payable {
        revert('unimplemented');
    }

}