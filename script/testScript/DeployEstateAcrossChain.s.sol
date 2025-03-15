// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { MockEstateAcrossChain } from "./mock/MockEstateAcrossChain.sol";
import { Script, console } from "forge-std/Script.sol";

contract DeployEstateAcrossChain is Script {
    function run() external {
        MockEstateAcrossChain mockEstateAcrossChain = MockEstateAcrossChain(0x05ADfE5fC9D37b6442C29bbd5e73a51078E82C86);
        string memory data = "billi bole meow";
        vm.startBroadcast();
        mockEstateAcrossChain.bridge(11155111, abi.encodePacked(data), 500000);
        vm.stopBroadcast();
    }

    function run2() external returns (MockEstateAcrossChain) {
        // address _router, address _link, uint256[] memory _chainId, uint64[] memory _chainSelector

        vm.startBroadcast();

        uint256[] memory chainId = new uint256[](1);
        uint64[] memory chainSelector = new uint64[](1);

        // av deployment
        // chainId[0] = 11155111;
        // chainSelector[0] = 16015286601757825753;

        // sepolia deployment
        // chainId[0] = 43113;
        // chainSelector[0] = 14767482510784806043;

        // arb deployment
        chainId[0] = 43113;
        chainSelector[0] = 14767482510784806043;

        // av deployment
        // MockEstateAcrossChain mockEstateAcrossChain = new MockEstateAcrossChain(
        //     0xF694E193200268f9a4868e4Aa017A0118C9a8177,
        //     0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
        //     chainId,
        //     chainSelector
        // );


        // sepolia deployment
        // MockEstateAcrossChain mockEstateAcrossChain = new MockEstateAcrossChain(
        //     0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
        //     0x779877A7B0D9E8603169DdbD7836e478b4624789,
        //     chainId,
        //     chainSelector
        // );

        // arb deployment
        MockEstateAcrossChain mockEstateAcrossChain = new MockEstateAcrossChain(
            0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            chainId,
            chainSelector
        );

        vm.stopBroadcast();
        return mockEstateAcrossChain;
    }
}