// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {TokenizedRealEstate} from "./TokenizedRealEstate.sol";
import {CrossChainManager} from "./Bridge/CrossChainManager.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AssetTokenizationManager is ERC721 {
    using SafeERC20 for IERC20;

    error AssetTokenizationManager__NotAssetOwner();
    error AssetTokenizationManager__NotShareHolder();

    struct AssetInfo {
        address assetOwner;
        uint256 sharesAvailable;
        address token;
        uint256 amountOfAsset;
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
    
    uint256 private constant MAX_DECIMALS_SHARE_PERCENTAGE = 5;
    mapping(uint256 => AssetInfo) private s_tokenidToAssetInfo;
    mapping(address => shareHolderInfo) private s_shareHolderToShareHolderInfo;
    uint256 private s_tokenId;
    mapping(address => bool) private s_isShareholder;
    mapping(address => uint256) private s_shareholderToShares;
    address private immutable i_assetTokenizedRealEsate;
    uint256 private constant TOTAL_TRE = 1e6 * 1e18;

    CrossChainManager private immutable i_crossChainManager;

    event ValidatorAdded(address indexed validator);
    event ShareholderAdded(address indexed shareholder);

    modifier onlyAssetOwner(uint256 tokenId) {
        if (msg.sender != s_tokenidToAssetInfo[tokenId].assetOwner) {
            revert AssetTokenizationManager__NotAssetOwner();
        }
        _;
    }

    modifier onlySharesHolder(){
        if (msg.sender != s_shareHolderToShareHolderInfo[msg.sender].shareholder) {
            revert AssetTokenizationManager__NotShareHolder();

        }
        _;
    }

    constructor(address ethUsdcPriceFeeds, address crossChainManager)
        ERC721("Asset Tokenization Manager", "ATM")
    {
        i_assetTokenizedRealEsate = msg.sender;
        i_crossChainManager = CrossChainManager(crossChainManager);
    }

    function mintAssetTokenizedRealEstateForEth(uint256 percentageForShareholders, uint256 amountOfAsset) external {
        _mint(msg.sender, s_tokenId);
        address tokenizedRealEstate = address(new TokenizedRealEstate(address(this), address(i_crossChainManager)));
        TokenizedRealEstate(tokenizedRealEstate).mintTokenizedRealEstateForEth();
        uint256 netAmountForShares = _calculateNetAmountForShares(percentageForShareholders, amountOfAsset);
        s_tokenidToAssetInfo[s_tokenId] = AssetInfo({
            assetOwner: msg.sender,
            sharesAvailable: percentageForShareholders,
            token: address(tokenizedRealEstate),
            amountOfAsset: amountOfAsset,
            currRentAmount: 0,
            netAmountForShareholders: netAmountForShares
        });
        s_tokenId++;
    }

    function buySharesOfAsset(uint256 tokenid, uint256 amount) external payable {
        // if (msg.value != amount) {
        //     // revert AssetTokenizationManager__();
        // }
        uint256 amountOfToken = _calculateNetTokenAmount(amount, s_tokenidToAssetInfo[tokenid].netAmountForShareholders);
        s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
            tokenId: tokenid,
            shareholder: msg.sender,
            sharesAmount: amount,
            fractionalShares: amountOfToken,
            rentAmountIn: s_tokenidToAssetInfo[tokenid].currRentAmount
        });
        address tokenTRE = s_tokenidToAssetInfo[tokenid].token;
        address assetOwner = s_tokenidToAssetInfo[tokenid].assetOwner;
        
        IERC20(tokenTRE).transferFrom(assetOwner, msg.sender, amountOfToken);
    }

    function sellSharesOfAsset(uint256 tokenid) external onlySharesHolder {
        
        uint256 rentAmount = s_shareHolderToShareHolderInfo[msg.sender].rentAmountIn;
        uint256 currRentAmount = s_tokenidToAssetInfo[tokenid].currRentAmount;
        uint256 amount = currRentAmount - rentAmount;
        
        uint256 tokenAmount = s_shareHolderToShareHolderInfo[msg.sender].fractionalShares;
        address tokenTRE = s_tokenidToAssetInfo[tokenid].token;
        address assetOwner = s_tokenidToAssetInfo[tokenid].assetOwner;
        
        s_shareHolderToShareHolderInfo[msg.sender] = shareHolderInfo({
            tokenId: tokenid,
            shareholder: address(0),
            sharesAmount: 0,
            fractionalShares: 0,
            rentAmountIn: 0
        });

        bool success = payable(msg.sender).send(amount);
        require(success);
        IERC20(tokenTRE).transferFrom(msg.sender,assetOwner , tokenAmount);
    }

    function updateRentAmount(uint256 tokenid, uint256 rentAmount) external onlyAssetOwner(tokenid) {
        s_tokenidToAssetInfo[tokenid].currRentAmount = rentAmount;
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

    function getAssetInfo(uint256 tokenId) external view returns (AssetInfo memory) {
        return s_tokenidToAssetInfo[tokenId];
    }

    function getShareHolderInfo(address shareholder) external view returns (shareHolderInfo memory) {
        return s_shareHolderToShareHolderInfo[shareholder];
    }
}
