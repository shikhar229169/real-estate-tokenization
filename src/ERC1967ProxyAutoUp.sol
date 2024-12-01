// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC1967Proxy, ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IRealEstateRegistry } from "./interfaces/IRealEstateRegistry.sol";

contract ERC1967ProxyAutoUp is ERC1967Proxy {
    constructor(address implementation, bytes memory _data) payable ERC1967Proxy(implementation, _data) {

    }

    function _implementation() internal view virtual override returns (address) {
        (bool s1, bytes memory data1) = address(this).staticcall(abi.encodeWithSignature("isAutoUpdateEnabled()"));
        require(s1);
        bool enabled = abi.decode(data1, (bool));

        if (enabled) {
            (bool s2, bytes memory data2) = address(this).staticcall(abi.encodeWithSignature("getRealEstateRegistry()"));
            require(s2);
            address realEstateRegistry = abi.decode(data2, (address));
            return IRealEstateRegistry(realEstateRegistry).getOperatorVaultImplementation();
        }

        return ERC1967Utils.getImplementation();
    }
}