// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {AssetTokenizationManager} from "../src/AssetTokenizationManager.sol";
import {TokenizedRealEstate} from "../src/TokenizedRealEstate.sol";
import {RealEstateRegistry} from "../src/RealEstateRegistry.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VerifyingOperatorVault} from "../src/VerifyingOperatorVault.sol";
import {RealEstateRegistry} from "../src/RealEstateRegistry.sol";
import {USDC} from "../test/mocks/MockUSDCToken.sol";
import {EstateVerification} from "../src/Computation/EstateVerification.sol";

contract DeployAssetTokenizationManager is Script {

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address privateKeyAddr = vm.addr(privateKey);
        deploy(privateKeyAddr, privateKey);
    }

    function deploy(address owner, uint256 ownerKey) public returns (AssetTokenizationManager, VerifyingOperatorVault, RealEstateRegistry, USDC, EstateVerification,HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        helperConfig.run();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig();

        vm.startBroadcast(ownerKey);
        
        AssetTokenizationManager assetTokenizationManager = new AssetTokenizationManager(
            networkConfig.ccipRouter,
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
        
        EstateVerification estateVerification = EstateVerification(assetTokenizationManager.getEstateVerification());

        VerifyingOperatorVault verifyingOperatorVault = new VerifyingOperatorVault();

        USDC usdc = new USDC();

        address[] memory acceptedTokens = new address[](2);
        acceptedTokens[0] = address(usdc);
        acceptedTokens[1] = networkConfig.link;

        address[] memory dataFeedAddresses = new address[](2);

        dataFeedAddresses[0] = networkConfig.usdcPriceFeed;
        dataFeedAddresses[1] = networkConfig.linkPriceFeed;

        uint256 collateralReqInFiat = 5;

        RealEstateRegistry realEstateRegistry = new RealEstateRegistry(
            owner,
            owner,
            collateralReqInFiat,
            acceptedTokens,
            dataFeedAddresses,
            address(verifyingOperatorVault),
            networkConfig.swapRouter,
            address(assetTokenizationManager)
        );

        assetTokenizationManager.setRegistry(address(realEstateRegistry)); 

        vm.stopBroadcast();

        console.log("AssetTokenizationManager deployed at: ", address(assetTokenizationManager));
        console.log("VerifyingOperatorVault deployed at: ", address(verifyingOperatorVault));
        console.log("RealEstateRegistry deployed at: ", address(realEstateRegistry));
        console.log("USDC deployed at: ", address(usdc));
        console.log("EstateVerification deployed at: ", address(estateVerification));
        console.log("HelperConfig deployed at: ", address(helperConfig));

        return (assetTokenizationManager, verifyingOperatorVault, realEstateRegistry, usdc, estateVerification,helperConfig);
    }
}
