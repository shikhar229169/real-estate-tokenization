// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { AssetTokenizationManager } from "./AssetTokenizationManager.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TokenizedRealEstate is ERC20 {

    error TokenizedRealEstate__ZeroEthSent();
    error TokenizedRealEstate__OnlyAssetTokenizationManager();
    error TokenizedRealEstate__OnlyShareHolder();
    
    address private immutable i_assetTokenizationManager;
    address private immutable i_estateOwner;
    uint256 private s_estateCost;
    uint256 private immutable i_tokenId;
    uint256 private immutable i_percentageToTokenize;
    address private immutable i_paymentToken;
    mapping(uint256 => EstateInfo) private s_tokenidToAssetInfo;
    mapping(address => shareHolderInfo) private s_shareHolderToShareHolderInfo;
    mapping(address => bool) private isShareHolder;

    uint8 private constant MAX_DECIMALS = 18;
    uint256 private constant TOTAL_TRE = 1e6 * 1e18;

    struct EstateInfo {
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
        if (msg.sender != i_assetTokenizationManager) {
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

    constructor(
        address estateOwner,
        uint256 estateCost,
        uint256 percentageToTokenize,
        uint256 tokenId,
        address paymentTokenOnChain
    ) ERC20("Tokenized Real Estate", "TRE") {
        i_assetTokenizationManager = msg.sender;
        i_estateOwner = estateOwner;
        s_estateCost = estateCost;
        i_percentageToTokenize = percentageToTokenize;
        i_tokenId = tokenId;
        i_paymentToken = paymentTokenOnChain;
    }

    // function buySharesOfAsset(uint256 amount) external payable {
    //     // if (msg.value != amount) {
    //     //     // revert AssetTokenizationManager__();
    //     // }

    //     uint256 netAmount = s_shareHolderToShareHolderInfo[msg.sender].sharesAmount+amount;
    //     uint256 prevAmountOfToken = s_shareHolderToShareHolderInfo[msg.sender].fractionalShares;
    //     uint256 amountOfToken = _calculateNetTokenAmount(netAmount, s_tokenidToAssetInfo[i_tokenId].netAmountForShareholders);

    //     s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
    //         tokenId: i_tokenId,
    //         shareholder: msg.sender,
    //         sharesAmount: netAmount,
    //         fractionalShares: amountOfToken,
    //         rentAmountIn: s_tokenidToAssetInfo[i_tokenId].currRentAmount
    //     });
    //     uint256 netAmountOfTOken = amountOfToken-prevAmountOfToken;
    //     transferFrom(i_assetOwner, msg.sender, netAmountOfTOken);
    // }

    // function sellSharesOfAsset(uint256 tokenid) external onlySharesHolder {
        
    //     uint256 rentAmount = s_shareHolderToShareHolderInfo[msg.sender].rentAmountIn;
    //     uint256 currRentAmount = s_tokenidToAssetInfo[tokenid].currRentAmount;
    //     uint256 amount = currRentAmount - rentAmount;
        
    //     uint256 tokenAmount = s_shareHolderToShareHolderInfo[msg.sender].fractionalShares;
        
    //     s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
    //         tokenId: tokenid,
    //         shareholder: address(0),
    //         sharesAmount: 0,
    //         fractionalShares: 0,
    //         rentAmountIn: 0
    //     });

    //     bool success = payable(msg.sender).send(amount);
    //     require(success);
    //     transferFrom(msg.sender,i_assetOwner , tokenAmount);
    // }

    // function updateAssetInfo(uint256 tokenId) external onlyAssetTokenizationManager {
    //     uint256 netAmountForShares = _calculateNetAmountForShares(s_percentageForShareholders, s_amountOfAsset);
    //     s_tokenidToAssetInfo[tokenId] = AssetInfo({
    //         sharesAvailable: s_percentageForShareholders,
    //         currRentAmount: 0,
    //         netAmountForShareholders: netAmountForShares
    //     });
    // }

    // function updateAssetInfoRentAmount(uint256 tokenId, uint256 rentAmount) external onlyAssetTokenizationManager {
    //     s_tokenidToAssetInfo[tokenId].currRentAmount = rentAmount;
    // }

    // function updateShareHolderToShareHolderInfo(uint256 tokenId, uint256 amount, uint256 amountOfToken) external onlyAssetTokenizationManager {
    //     s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
    //         tokenId: tokenId,
    //         shareholder: msg.sender,
    //         sharesAmount: amount,
    //         fractionalShares: amountOfToken,
    //         rentAmountIn: s_tokenidToAssetInfo[tokenId].currRentAmount
    //     });
    // }

    // function _calculateNetAmountForShares(uint256 percentageForShareholders, uint256 amountOfAsset)
    //     internal
    //     pure
    //     returns (uint256)
    // {
    //     return (amountOfAsset * percentageForShareholders) / 100;
    // }

    // function _calculateNetTokenAmount(uint256 amount, uint256 netAmountForShareholders)
    //     internal
    //     pure
    //     returns (uint256)
    // {
    //     return (amount * TOTAL_TRE) / netAmountForShareholders;
    // }

    // function mintTokenizedRealEstateForEth() external payable {
    //     _mint(msg.sender, 1e6 * 1e18);
    // }

    // function burnTokenizedRealEstate(uint256 amount) external onlyAssetTokenizationManager {
    //     _burn(msg.sender, amount);
    // }

    // function getAssetTokenizationManager() external view returns (address) {
    //     return i_assertTonkenizationManager;
    // }
}
