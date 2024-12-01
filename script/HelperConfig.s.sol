// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address swapRouter;
        address ccipRouter;
        address functionsRouter;
    }

    string public homeChain = "arbitrum";
    uint256 public homeChainId = 42161;
    uint256 polygonChainId = 137;
    uint256 avalancheChainId = 43114;

    NetworkConfig private networkConfig;

    function run() external {
        if (block.chainid == homeChainId) {

        }
        else if (block.chainid == polygonChainId) {

        }
        else if (block.chainid == avalancheChainId) {

        }
    }

    function getArbitrumConfig() external pure returns (NetworkConfig memory _networkConfig) {
        return _networkConfig;
    }

    function getPolygonConfig() external pure returns (NetworkConfig memory _networkConfig) {
        return _networkConfig;
    }

    function getAvalancheConfig() external pure returns (NetworkConfig memory _networkConfig) {
        return _networkConfig;
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return networkConfig;
    }
}