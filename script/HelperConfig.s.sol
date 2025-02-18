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
    uint256 polygonChainId = 137;
    uint256 avalancheChainId = 43114;

    NetworkConfig private networkConfig;

    function run() external {
        if (block.chainid == homeChainId) {
            networkConfig = getArbitrumConfig();
        }
        else if (block.chainid == polygonChainId) {
            networkConfig = getPolygonConfig();
        }
        else if (block.chainid == avalancheChainId) {
            networkConfig = getAvalancheConfig();
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

    function getTestConfig() public pure returns (NetworkConfig memory _networkConfig) {
        _networkConfig.swapRouter = 0x20C8c9F13C6AA402F2545AD15fB7a9CdE9108618;//(Destination network) -> (Avalanche Fuji) OnRamp address
        _networkConfig.ccipRouter = 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165; 
        _networkConfig.functionsRouter = 0x234a5fb5Bd614a7AA2FfAB244D603abFA0Ac5C5C;
        _networkConfig.subId_Acalanche = 15150;
        _networkConfig.subId_Arbitrum = 0;
        _networkConfig.baseChainId = 421614;
        _networkConfig.link = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
        _networkConfig.donId = 0x66756e2d617262697472756d2d7365706f6c69612d3100000000000000000000;
        _networkConfig.gasLimit = 21000;
        _networkConfig.supportedChains = new uint256[](2);
        _networkConfig.supportedChains[0] = 421614;
        _networkConfig.supportedChains[1] = 43113;
        _networkConfig.chainSelectors = new uint64[](2);
        _networkConfig.chainSelectors[0] = 3478487238524512106;
        _networkConfig.chainSelectors[1] = 14767482510784806043;
        _networkConfig.estateVerificationSource = "";
        _networkConfig.encryptedSecretsUrls = "";
        return _networkConfig;
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return networkConfig;
    }
}