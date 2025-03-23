// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {AssetTokenizationManager} from "../src/AssetTokenizationManager.sol";
import {USDC} from "../test/mocks/MockUSDCToken.sol";
import {EstateVerification} from "../src/Computation/EstateVerification.sol";

contract CreateTokenizedRealEstate is Script {
    function run() external {
        uint256 ownerKey = vm.envUint("PRIVATE_KEY");
        address asset = 0x402A7859717f8fd0b1b8F806653dA7225E9e45CC;
        vm.startBroadcast(ownerKey);
        
        address usdc = address(0xCd183631ebBcbd2109DC4a0E5D4D53f7fB3CE65e);
        // address owner = 0x697F5E7a089e1621EA329FE4e906EA45D16E79c6;
        address owner = 0x42fFD061E73331b2327a37AA306a0356859F9d1C;
        
        USDC(usdc).mint(owner, 1000000e18);
        USDC(usdc).approve(asset, type(uint256).max);

        address estateVerification = AssetTokenizationManager(asset).getEstateVerification();

        EstateVerification.TokenizeFunctionCallRequest memory request;
        request.estateOwner = owner;
        request.chainsToDeploy = new uint256[](2);
        request.chainsToDeploy[0] = 43113;
        request.chainsToDeploy[1] = 11155111;
        request.paymentToken = usdc;
        request.estateOwnerAcrossChain = new address[](2);
        request.estateOwnerAcrossChain[0] = owner;
        request.estateOwnerAcrossChain[1] = owner;

        uint256 estateCost = 1e6 * 1e18;
        uint256 percentageToTokenize = 100e18;
        bool isApproved = true;
        bytes memory _saltBytes = bytes("6969");
        address _verifyingOperator = 0x42fFD061E73331b2327a37AA306a0356859F9d1C;

        bytes memory response = abi.encode(estateCost, percentageToTokenize, isApproved, _saltBytes, _verifyingOperator);

        EstateVerification(estateVerification).createTestRequestIdResponse(request, response);

        vm.stopBroadcast();
    }
}