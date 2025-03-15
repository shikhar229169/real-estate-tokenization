// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { EstateAcrossChain } from "src/Bridge/EstateAcrossChain.sol";

contract MockEstateAcrossChain is EstateAcrossChain {
    constructor(
        address _router,
        address _link,
        uint256[] memory _chainId,
        uint64[] memory _chainSelector
    ) EstateAcrossChain(_router, _link, _chainId, _chainSelector) {}

    function _handleCrossChainMessage(bytes32 _messageId, bytes memory _data) internal virtual override {

    }

    function bridge(uint256 _chainId, bytes memory _data, uint256 _gasLimit) external returns (bytes32) {
        return _sendMessagePayLINK(chainIdToSelector[_chainId], chainSelectorToManager[chainIdToSelector[_chainId]], _data, _gasLimit);
    }
}