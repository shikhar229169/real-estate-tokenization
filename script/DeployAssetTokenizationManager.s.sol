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

contract DeployAssetTokenizationManager is Script {

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address owner = 0xF1c8170181364DeD1C56c4361DED2eB47f2eef1b;
        // deploy(0x42fFD061E73331b2327a37AA306a0356859F9d1C, privateKey);
        deploy(owner, privateKey);
    }

    function deploy(address owner, uint256 ownerKey) public returns (AssetTokenizationManager, VerifyingOperatorVault, RealEstateRegistry, USDC, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        helperConfig.run();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig();
        // TokenizedRealEstate tokenizedRealEstate;
        // uint256 linkBalance = 8 ether;

        vm.startBroadcast(ownerKey);
        
        AssetTokenizationManager assetTokenizationManager = new AssetTokenizationManager(
            networkConfig.ccipRouter,
            // address(1),
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

        VerifyingOperatorVault verifyingOperatorVault = new VerifyingOperatorVault();

        USDC usdc = new USDC();

        address[] memory acceptedTokens = new address[](2);
        acceptedTokens[0] = address(usdc);
        acceptedTokens[1] = networkConfig.link;

        address[] memory dataFeedAddresses = new address[](2);
        dataFeedAddresses[0] = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
        dataFeedAddresses[1] = 0xc59E3633BAAC79493d908e63626716e204A45EdF;

        // dataFeedAddresses[0] = 0x97FE42a7E96640D932bbc0e1580c73E705A8EB73;
        // dataFeedAddresses[1] = 0x34C4c526902d88a3Aa98DB8a9b802603EB1E3470;

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
        console.log("HelperConfig deployed at: ", address(helperConfig));

        return (assetTokenizationManager, verifyingOperatorVault, realEstateRegistry, usdc, helperConfig);
    }
}
