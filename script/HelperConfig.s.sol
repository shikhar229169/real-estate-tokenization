// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {
    error HelperConfig__ChainNotSupported();

    struct NetworkConfig {
        address swapRouter;
        address ccipRouter;
        address functionsRouter;
        uint64 subId_Acalanche;
        uint64 subId_Arbitrum;
        uint256 baseChainId;
        address link;
        bytes32 donId;
        uint32 gasLimit;
        uint256[] supportedChains; 
        uint64[] chainSelectors;
        string estateVerificationSource;
        bytes encryptedSecretsUrls;
        address usdcPriceFeed;
        address linkPriceFeed;
    }

    uint256 public avalancheFujiChainId = 43113;
    uint256 public ethereumSepoliaChainId = 11155111;

    NetworkConfig private networkConfig;

    function run() external {
        if (block.chainid == avalancheFujiChainId) {
            networkConfig = getAvalancheFujiConfig();
        }
        else if (block.chainid == ethereumSepoliaChainId) {
            networkConfig = getEthereumSepoliaConfig();
        }
        else {
            revert HelperConfig__ChainNotSupported();
        }
    }

    function getAvalancheFujiConfig() public view returns (NetworkConfig memory _networkConfig) {
        _networkConfig.swapRouter = address(0);
        _networkConfig.ccipRouter = 0xF694E193200268f9a4868e4Aa017A0118C9a8177; 
        _networkConfig.functionsRouter = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;
        _networkConfig.subId_Acalanche = 15150;
        _networkConfig.subId_Arbitrum = 4389;
        _networkConfig.baseChainId = avalancheFujiChainId;
        _networkConfig.link = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
        _networkConfig.donId = 0x66756e2d6176616c616e6368652d66756a692d31000000000000000000000000;
        _networkConfig.gasLimit = 21000;
        _networkConfig.supportedChains = new uint256[](2);
        _networkConfig.supportedChains[0] = avalancheFujiChainId;
        _networkConfig.supportedChains[1] = 11155111;
        _networkConfig.chainSelectors = new uint64[](2);
        _networkConfig.chainSelectors[0] = 14767482510784806043;
        _networkConfig.chainSelectors[1] = 16015286601757825753;
        _networkConfig.estateVerificationSource = "";
        _networkConfig.encryptedSecretsUrls = "";
        _networkConfig.usdcPriceFeed = 0x97FE42a7E96640D932bbc0e1580c73E705A8EB73;
        _networkConfig.linkPriceFeed = 0x34C4c526902d88a3Aa98DB8a9b802603EB1E3470;
    }

    function getEthereumSepoliaConfig() public view returns (NetworkConfig memory _networkConfig) {
        _networkConfig.swapRouter = address(0);
        _networkConfig.ccipRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59; 
        _networkConfig.functionsRouter = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
        _networkConfig.subId_Acalanche = 15150;
        _networkConfig.subId_Arbitrum = 4389;
        _networkConfig.baseChainId = avalancheFujiChainId;
        _networkConfig.link = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
        _networkConfig.donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
        _networkConfig.gasLimit = 21000;
        _networkConfig.supportedChains = new uint256[](2);
        _networkConfig.supportedChains[0] = avalancheFujiChainId;
        _networkConfig.supportedChains[1] = 11155111;
        _networkConfig.chainSelectors = new uint64[](2);
        _networkConfig.chainSelectors[0] = 14767482510784806043;
        _networkConfig.chainSelectors[1] = 16015286601757825753;
        _networkConfig.estateVerificationSource = "";
        _networkConfig.encryptedSecretsUrls = "";
        _networkConfig.usdcPriceFeed = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
        _networkConfig.linkPriceFeed = 0xc59E3633BAAC79493d908e63626716e204A45EdF;
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return networkConfig;
    }
}