// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {AssetTokenizationManager} from "../src/AssetTokenizationManager.sol";
import {USDC} from "../test/mocks/MockUSDCToken.sol";

contract CreateTokenizedRealEstate is Script {
    function run() external {
        uint256 ownerKey = vm.envUint("PRIVATE_KEY");
        address asset = 0xdc5E2b74FbC0b4a8C7F6944D936f3f8eE8f9b5B2;
        vm.startBroadcast(ownerKey);
        
        address usdc = address(0xF2b778E3f6Eb1Ab287B4c62918e64Dfc17A9762e);
        // address owner = 0x42fFD061E73331b2327a37AA306a0356859F9d1C;
        address owner = 0xF1c8170181364DeD1C56c4361DED2eB47f2eef1b;
        
        USDC(usdc).mint(owner, 1000000e18);
        USDC(usdc).approve(asset, type(uint256).max);

        AssetTokenizationManager.TokenizeFunctionCallRequest memory request;
        request.estateOwner = owner;
        request.chainsToDeploy = new uint256[](2);
        request.chainsToDeploy[0] = 43113;
        request.chainsToDeploy[1] = 11155111;
        request.paymentToken = 0xF2b778E3f6Eb1Ab287B4c62918e64Dfc17A9762e;
        request.estateOwnerAcrossChain = new address[](2);
        request.estateOwnerAcrossChain[0] = owner;
        request.estateOwnerAcrossChain[1] = owner;

        uint256 estateCost = 1000;
        uint256 percentageToTokenize = 100e18;
        bool isApproved = true;
        bytes memory _saltBytes = bytes("69");
        address _verifyingOperator = 0x42fFD061E73331b2327a37AA306a0356859F9d1C;

        bytes memory response = abi.encode(estateCost, percentageToTokenize, isApproved, _saltBytes, _verifyingOperator);

        AssetTokenizationManager(asset).createTestRequestIdResponse(request, response);

        vm.stopBroadcast();
    }
}
