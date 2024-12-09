// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TokenizedRealEstate is ERC20 {

    error TokenizedRealEstate__ZeroEthSent();
    error TokenizedRealEstate__OnlyAssetTokenizationManager();
    error TokenizedRealEstate__OnlyShareHolder();
    
    address private immutable i_assertTonkenizationManager;
    AggregatorV3Interface private immutable i_ethUsdPriceFeeds;
    uint8 private constant MAX_DECIMALS = 18;
    address private immutable i_assetOwner;
    uint256 private s_amountOfAsset;
    uint256 private constant TOTAL_TRE = 1e6 * 1e18;
    uint256 private s_percentageForShareholders;
    uint256 private immutable i_tokenId;
    mapping(uint256 => AssetInfo) private s_tokenidToAssetInfo;
    mapping(address => shareHolderInfo) private s_shareHolderToShareHolderInfo;
    mapping(address => bool) private isShareHolder;

    struct AssetInfo {
        uint256 sharesAvailable;
        uint256 currRentAmount;
        uint256 netAmountForShareholders;
    }

    struct shareHolderInfo {
        uint256 tokenId;
        address shareholder;
        uint256 sharesAmount;
        uint256 fractionalShares;
        uint256 rentAmountIn;
    }

    modifier onlyAssetTokenizationManager() {
        if (msg.sender != i_assertTonkenizationManager) {
            revert TokenizedRealEstate__OnlyAssetTokenizationManager();
        }
        _;
    }

    modifier onlySharesHolder() {
        if(isShareHolder[msg.sender]){
            revert TokenizedRealEstate__OnlyShareHolder();
        }
        _;
    }

    constructor(address assertTonkenizationManager, address ethUsdPriceFeeds, address assetOwner,uint256 percentageForShareholders, uint256 amountOfAsset, uint256 tokenId) ERC20("Tokenized Real Estate", "TRE") {
        i_assertTonkenizationManager = assertTonkenizationManager;
        i_ethUsdPriceFeeds = AggregatorV3Interface(ethUsdPriceFeeds);
        i_assetOwner = assetOwner;
        s_percentageForShareholders = percentageForShareholders;
        s_amountOfAsset = amountOfAsset;
        i_tokenId = tokenId;
    }

    function buySharesOfAsset(uint256 amount) external payable {
        // if (msg.value != amount) {
        //     // revert AssetTokenizationManager__();
        // }
        uint256 amountOfToken = _calculateNetTokenAmount(amount, s_tokenidToAssetInfo[i_tokenId].netAmountForShareholders);

        s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
            tokenId: i_tokenId,
            shareholder: msg.sender,
            sharesAmount: amount,
            fractionalShares: amountOfToken,
            rentAmountIn: s_tokenidToAssetInfo[i_tokenId].currRentAmount
        });
        
        transferFrom(i_assetOwner, msg.sender, amountOfToken);
    }

    function sellSharesOfAsset(uint256 tokenid) external onlySharesHolder {
        
        uint256 rentAmount = s_shareHolderToShareHolderInfo[msg.sender].rentAmountIn;
        uint256 currRentAmount = s_tokenidToAssetInfo[tokenid].currRentAmount;
        uint256 amount = currRentAmount - rentAmount;
        
        uint256 tokenAmount = s_shareHolderToShareHolderInfo[msg.sender].fractionalShares;
        
        s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
            tokenId: tokenid,
            shareholder: address(0),
            sharesAmount: 0,
            fractionalShares: 0,
            rentAmountIn: 0
        });

        bool success = payable(msg.sender).send(amount);
        require(success);
        transferFrom(msg.sender,i_assetOwner , tokenAmount);
    }

    function updateAssetInfo(uint256 tokenId) external onlyAssetTokenizationManager {
        uint256 netAmountForShares = _calculateNetAmountForShares(s_percentageForShareholders, s_amountOfAsset);
        s_tokenidToAssetInfo[tokenId] = AssetInfo({
            sharesAvailable: s_percentageForShareholders,
            currRentAmount: 0,
            netAmountForShareholders: netAmountForShares
        });
    }

    function updateAssetInfoRentAmount(uint256 tokenId, uint256 rentAmount) external onlyAssetTokenizationManager {
        s_tokenidToAssetInfo[tokenId].currRentAmount = rentAmount;
    }

    function updateShareHolderToShareHolderInfo(uint256 tokenId, uint256 amount, uint256 amountOfToken) external onlyAssetTokenizationManager {
        s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
            tokenId: tokenId,
            shareholder: msg.sender,
            sharesAmount: amount,
            fractionalShares: amountOfToken,
            rentAmountIn: s_tokenidToAssetInfo[tokenId].currRentAmount
        });
    }

    function _calculateNetAmountForShares(uint256 percentageForShareholders, uint256 amountOfAsset)
        internal
        pure
        returns (uint256)
    {
        return (amountOfAsset * percentageForShareholders) / 100;
    }

    function _calculateNetTokenAmount(uint256 amount, uint256 netAmountForShareholders)
        internal
        pure
        returns (uint256)
    {
        return (amount * TOTAL_TRE) / netAmountForShareholders;
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
