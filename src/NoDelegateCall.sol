// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

contract NoDelegateCall {
    error NoDelegateCall__DelegateCallNotSupported();

    address private immutable i_thisContract;

    constructor() {
        i_thisContract = address(this);
    }

    modifier noDelegateCall {
        require(i_thisContract == address(this), NoDelegateCall__DelegateCallNotSupported());
        _;
    }
}