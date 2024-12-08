// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TokenizedRealEstate is ERC20 {

    error TokenizedRealEstate__ZeroEthSent();
    error TokenizedRealEstate__OnlyAssetTokenizationManager();
    
    address private immutable i_assertTonkenizationManager;
    AggregatorV3Interface private immutable i_ethUsdPriceFeeds;
    uint8 private constant MAX_DECIMALS = 18;

    modifier onlyAssetTokenizationManager() {
        if (msg.sender != i_assertTonkenizationManager) {
            revert TokenizedRealEstate__OnlyAssetTokenizationManager();
        }
        _;
    }

    constructor(address assertTonkenizationManager, address ethUsdPriceFeeds) ERC20("Tokenized Real Estate", "TRE") {
        i_assertTonkenizationManager = assertTonkenizationManager;
        i_ethUsdPriceFeeds = AggregatorV3Interface(ethUsdPriceFeeds);
    }

    function mintTokenizedRealEstateForEth() external payable {
        _mint(msg.sender, 1e6 * 1e18);
    }

    function burnTokenizedRealEstate(uint256 amount) external onlyAssetTokenizationManager {
        _burn(msg.sender, amount);
    }

    function getEthUsdcPriceFeeds() external view returns (address) {
        return address(i_ethUsdPriceFeeds);
    }

    function getAssetTokenizationManager() external view returns (address) {
        return i_assertTonkenizationManager;
    }
}
