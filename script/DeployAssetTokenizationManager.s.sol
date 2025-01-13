// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {AssetTokenizationManager} from "../src/AssetTokenizationManager.sol";
import {TokenizedRealEstate} from "../src/TokenizedRealEstate.sol";
import {RealEstateRegistry} from "../src/RealEstateRegistry.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployAssetTokenizationManager is Script {

    function run() external {
        deploy(address(0), 0);
    }

    function deploy(address owner, uint256 ownerKey) public returns (AssetTokenizationManager, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        helperConfig.run();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig();
        // TokenizedRealEstate tokenizedRealEstate;
        // uint256 linkBalance = 8 ether;

        vm.startBroadcast(ownerKey);
        
        AssetTokenizationManager assetTokenizationManager = new AssetTokenizationManager(
            // networkConfig.ccipRouter,
            address(1),
            networkConfig.link,
            networkConfig.functionsRouter,
            networkConfig.baseChainId,
            networkConfig.supportedChains,
            networkConfig.chainSelectors,
            networkConfig.estateVerificationSource,
            networkConfig.encryptedSecretsUrls,
            networkConfig.subId_Acalanche,
            networkConfig.gasLimit,
            networkConfig.donId
        );
        vm.stopBroadcast();

        return (assetTokenizationManager, helperConfig);
    }
}
