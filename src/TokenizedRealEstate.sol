// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AssetTokenizationManager } from "./AssetTokenizationManager.sol";
import { IRealEstateRegistry } from "./interfaces/IRealEstateRegistry.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

contract TokenizedRealEstate is ERC20 {
    using SafeERC20 for IERC20; 

    error TokenizedRealEstate__ZeroEthSent();
    error TokenizedRealEstate__OnlyAssetTokenizationManager();
    error TokenizedRealEstate__OnlyShareHolder();
    error TokenizedRealEstate__NotEnoughTokensToMint();
    error TokenizedRealEstate__NotEnoughCollateralToCoverEstateTokenDebt();
    error TokenizedRealEstate__OnlyEstateOwner();
    
    address private immutable i_assetTokenizationManager;
    address private immutable i_estateOwner;
    uint256 private s_estateCost;
    uint256 private immutable i_tokenId;
    uint256 private immutable i_percentageToTokenize;
    address private immutable i_paymentToken;
    mapping(address => uint256) private s_collateralDeposited;
    mapping(address => uint256) private s_estateTokenOwnershipMinted;
    uint256 private s_perEstateTokenRewardStored;
    mapping(address estateTokenHolder => uint256 perTokenRewardClaimed) private s_perEstateTokenRewardClaimedBy;
    mapping(address estateTokenHolder => uint256 rewards) private s_claimableRewards;
    // mapping(address => shareHolderInfo) private s_shareHolderToShareHolderInfo;

    uint8 private constant MAX_DECIMALS = 18;
    uint256 private constant TOTAL_TRE_SUPPLY = 1e6 * 1e18;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant COLLATERAL_REQUIRED = 120e18;
    uint256 private constant PERCENT_PRECISION = 100e18;

    // struct shareHolderInfo {
    //     uint256 tokenId;
    //     address shareholder;
    //     uint256 sharesAmount;
    //     uint256 fractionalShares;
    //     uint256 rentAmountIn;
    // }

    // Events
    event CollateralDeposited(address depositor, uint256 collateralAmount);
    event EstateOwnershipTokensMinted(address user, uint256 estateOwnershipTokensMinted);
    event RewardsAccumulated(uint256 currRewardsAvailable, uint256 perEstateTokenRewardStored);

    modifier onlyAssetTokenizationManager() {
        if (msg.sender != i_assetTokenizationManager) {
            revert TokenizedRealEstate__OnlyAssetTokenizationManager();
        }
        _;
    }

    modifier onlyEstateOwner() {
        require(msg.sender == i_estateOwner, TokenizedRealEstate__OnlyEstateOwner());
        _;
    }

    modifier updateReward() {
        uint256 reward = ((s_perEstateTokenRewardStored - s_perEstateTokenRewardClaimedBy[msg.sender]) * s_estateTokenOwnershipMinted[msg.sender]) / PRECISION;
        s_perEstateTokenRewardClaimedBy[msg.sender] = s_perEstateTokenRewardStored;
        s_claimableRewards[msg.sender] += reward;
        _;
    }

    constructor(
        address estateOwner,
        uint256 estateCost,
        uint256 percentageToTokenize,
        uint256 tokenId,
        address paymentTokenOnChain
    ) ERC20(
        string.concat("Tokenized Real Estate - ", Strings.toHexString(estateOwner)), 
        string.concat("TRE-", Strings.toHexString(estateOwner))
    ) {
        i_assetTokenizationManager = msg.sender;
        i_estateOwner = estateOwner;
        s_estateCost = estateCost;
        i_percentageToTokenize = percentageToTokenize;
        i_tokenId = tokenId;
        i_paymentToken = paymentTokenOnChain;
    }

    function depositCollateral(uint256 collateralAmount) external {
        s_collateralDeposited[msg.sender] += collateralAmount;
        emit CollateralDeposited(msg.sender, collateralAmount);
        IERC20(i_paymentToken).safeTransferFrom(msg.sender, address(this), collateralAmount);
    }

    /**
     * 
     * @param tokensToMint The amount of tokens to mint for collateral
     * @notice Calculates the amount of collateral with 120% over collateralization, takes collateral from user if not enough, and then mints the partial ownership tokens
     */
    function buyRealEstatePartialOwnershipWithCollateral(uint256 tokensToMint) external updateReward {
        uint256 tokensAvailableForMint = TOTAL_TRE_SUPPLY - totalSupply();
        require(tokensToMint <= tokensAvailableForMint, TokenizedRealEstate__NotEnoughTokensToMint());

        uint256 collateralRequired = calculateCollateralRequiredForTokens(tokensToMint + s_estateTokenOwnershipMinted[msg.sender]);

        if (collateralRequired > s_collateralDeposited[msg.sender]) {
            uint256 netCollateralRequired = collateralRequired - s_collateralDeposited[msg.sender];
            s_collateralDeposited[msg.sender] += netCollateralRequired;
            emit CollateralDeposited(msg.sender, netCollateralRequired);
            IERC20(i_paymentToken).safeTransferFrom(msg.sender, address(this), netCollateralRequired);
        }

        emit EstateOwnershipTokensMinted(msg.sender, tokensToMint);
        s_estateTokenOwnershipMinted[msg.sender] += tokensToMint;
        _mint(msg.sender, tokensToMint);
    }

    function burnEstateOwnershipTokens(uint256 tokensToBurn) external updateReward {
        s_estateTokenOwnershipMinted[msg.sender] -= tokensToBurn;
        _burn(msg.sender, tokensToBurn);
    }

    function withdrawCollateral(uint256 collateralAmount) external {
        s_collateralDeposited[msg.sender] -= collateralAmount;
        require(_hasEnoughCollateral(msg.sender), TokenizedRealEstate__NotEnoughCollateralToCoverEstateTokenDebt());
        IERC20(i_paymentToken).safeTransfer(msg.sender, collateralAmount);
    }

    function claimRewardsForEstateOwnershipTokens() external {
        uint256 reward = ((s_perEstateTokenRewardStored - s_perEstateTokenRewardClaimedBy[msg.sender]) * s_estateTokenOwnershipMinted[msg.sender]) / PRECISION;
        s_perEstateTokenRewardClaimedBy[msg.sender] = s_perEstateTokenRewardStored;
        reward += s_claimableRewards[msg.sender];
        s_claimableRewards[msg.sender] = 0;
        IERC20(i_paymentToken).safeTransfer(msg.sender, reward);
    }

    function sendRegularEstateRewardsAccumulated(uint256 rewardsAvailable) external onlyEstateOwner {
        IERC20(i_paymentToken).safeTransferFrom(msg.sender, address(this), rewardsAvailable);
        s_perEstateTokenRewardStored += ((rewardsAvailable * PRECISION)  / totalSupply());
        emit RewardsAccumulated(rewardsAvailable, s_perEstateTokenRewardStored);
    }

    function _hasEnoughCollateral(address user) internal view returns (bool) {
        uint256 collateralDeposited = s_collateralDeposited[user];
        uint256 collateralRequired = calculateCollateralRequiredForTokens(s_estateTokenOwnershipMinted[user]);
        return collateralDeposited >= collateralRequired;
    }

    function calculateCollateralRequiredForTokens(uint256 estateTokens) public view returns (uint256) {
        uint256 tokenPriceInPaymentToken = (getPerEstateTokenPrice() * estateTokens) / PRECISION;
        uint256 collateralRequired = (COLLATERAL_REQUIRED * tokenPriceInPaymentToken) / PERCENT_PRECISION;
        return collateralRequired;
    }

    function getCurrentOnChainTokenizedAmount() public view returns (uint256) {
        return (i_percentageToTokenize * s_estateCost) / PERCENT_PRECISION;
    }

    function getPerEstateTokenPrice() public view returns (uint256) {
        uint256 currentEstateCostOnChain = getCurrentOnChainTokenizedAmount();
        return (currentEstateCostOnChain * PRECISION) / TOTAL_TRE_SUPPLY;
    }

    function getEstateOwner() external view returns (address) {
        return i_estateOwner;
    }

    function getEstateCost() external view returns (uint256) {
        return s_estateCost;
    }

    function getPercentageToTokenize() external view returns (uint256) {
        return i_percentageToTokenize;
    }

    function getTokenId() external view returns (uint256) {
        return i_tokenId;
    }

    function getPaymentToken() external view returns (address) {
        return i_paymentToken;
    }

    function getAssetTokenizationManager() external view returns (address) {
        return i_assetTokenizationManager;
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
