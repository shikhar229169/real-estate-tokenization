// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {
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
    }

    string public homeChain = "arbitrum";
    uint256 public homeChainId = 42164;
    // uint256 public homeChainId = 42161;
    uint256 public polygonChainId = 137;
    uint256 public avalancheChainId = 43113;

    NetworkConfig private networkConfig;

    function run() external {
        if (block.chainid == homeChainId) {
            networkConfig = getArbitrumConfig();
        }
        else if (block.chainid == polygonChainId) {
            networkConfig = getPolygonConfig();
        }
        else if (block.chainid == avalancheChainId) {
            networkConfig = getTestConfig();
        }
        else {
            networkConfig = getTestConfig();
        }
    }

    function getArbitrumConfig() public pure returns (NetworkConfig memory _networkConfig) {
        return _networkConfig;
    }

    function getPolygonConfig() public pure returns (NetworkConfig memory _networkConfig) {
        return _networkConfig;
    }

    function getAvalancheConfig() public pure returns (NetworkConfig memory _networkConfig) {
        return _networkConfig;
    }

    function getTestConfig() public view returns (NetworkConfig memory _networkConfig) {
        // SEPOLIA //
        // _networkConfig.swapRouter = address(0);//(Avalanche Fuji) -> (Arbitrum) Uniswap Router
        // _networkConfig.ccipRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59; 
        // _networkConfig.functionsRouter = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
        // _networkConfig.subId_Acalanche = 15150;
        // _networkConfig.subId_Arbitrum = 4389;
        // _networkConfig.baseChainId = avalancheChainId;
        // _networkConfig.link = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
        // _networkConfig.donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
        // _networkConfig.gasLimit = 21000;
        // _networkConfig.supportedChains = new uint256[](2);
        // _networkConfig.supportedChains[0] = avalancheChainId;
        // _networkConfig.supportedChains[1] = 11155111;
        // _networkConfig.chainSelectors = new uint64[](2);
        // _networkConfig.chainSelectors[0] = 14767482510784806043;
        // _networkConfig.chainSelectors[1] = 16015286601757825753;
        // _networkConfig.estateVerificationSource = "";
        // _networkConfig.encryptedSecretsUrls = "";
        // return _networkConfig;

        _networkConfig.swapRouter = address(0);//(Avalanche Fuji) -> (Arbitrum) Uniswap Router
        _networkConfig.ccipRouter = 0xF694E193200268f9a4868e4Aa017A0118C9a8177; 
        _networkConfig.functionsRouter = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;
        _networkConfig.subId_Acalanche = 15150;
        _networkConfig.subId_Arbitrum = 4389;
        _networkConfig.baseChainId = avalancheChainId;
        _networkConfig.link = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
        _networkConfig.donId = 0x66756e2d6176616c616e6368652d66756a692d31000000000000000000000000;
        _networkConfig.gasLimit = 21000;
        _networkConfig.supportedChains = new uint256[](2);
        _networkConfig.supportedChains[0] = avalancheChainId;
        _networkConfig.supportedChains[1] = 11155111;
        _networkConfig.chainSelectors = new uint64[](2);
        _networkConfig.chainSelectors[0] = 14767482510784806043;
        _networkConfig.chainSelectors[1] = 16015286601757825753;
        _networkConfig.estateVerificationSource = "";
        _networkConfig.encryptedSecretsUrls = "";
        return _networkConfig;
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return networkConfig;
    }
}