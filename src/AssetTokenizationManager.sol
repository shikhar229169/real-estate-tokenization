// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { TokenizedRealEstate } from "./TokenizedRealEstate.sol";
import { EstateAcrossChain } from "./Bridge/EstateAcrossChain.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IRealEstateRegistry } from "./interfaces/IRealEstateRegistry.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

contract AssetTokenizationManager is ERC721, EstateAcrossChain {
    // libraries
    using SafeERC20 for IERC20;

    // Errors
    error AssetTokenizationManager__NotAssetOwner();
    error AssetTokenizationManager__NotShareHolder();
    error AssetTokenizationManager__ChainNotSupported();
    error AssetTokenizationManager__OnlyOneTokenizedRealEstatePerUser();

    // Structs
    struct EstateInfo {
        address estateOwner;
        uint256 percentageToTokenize;
        address tokenizedRealEstate;
        uint256 estateCost;
        uint256 accumulatedRewards;
    }

    struct TokenizeFunctionCallRequest {
        address estateOwner;
        uint256[] chainsToDeploy;
        address paymentToken;
    }
    
    // variables
    address private s_registry;
    mapping(uint256 tokenId => EstateInfo) private s_tokenidToEstateInfo;
    uint256 private s_tokenCounter;
    uint256[] private s_supportedChains;
    mapping(uint256 chainId => bool) private s_isSupportedChain;
    uint256 private immutable i_baseChain;
    mapping(bytes32 reqId => TokenizeFunctionCallRequest) private s_reqIdToTokenizeFunctionCallRequest;
    mapping(uint256 chainId => address atm) private s_chainIdToATManager;
    mapping(uint256 => mapping(uint256 => address)) private s_tokenIdToChainIdToTokenizedRealEstate;

    uint256 private constant MAX_DECIMALS_SHARE_PERCENTAGE = 5;
    uint256 private constant TOTAL_TRE = 1e6 * 1e18;

    // events
    event ValidatorAdded(address indexed validator);
    event ShareholderAdded(address indexed shareholder);
    event TokenizationRequestPlaced(bytes32 reqId, address estateOwner);

    // modifiers
    modifier onlyEstateOwner(uint256 tokenId) {
        if (msg.sender != s_tokenidToEstateInfo[tokenId].estateOwner) {
            revert AssetTokenizationManager__NotAssetOwner();
        }
        _;
    }

    // constructor
    constructor(address _router, address _link, uint256 _baseChainId, uint256[] memory _supportedChains, uint64[] memory _chainSelectors) ERC721("Asset Tokenization Manager", "ATM") EstateAcrossChain(_router, _link, _supportedChains, _chainSelectors) {
        i_baseChain = _baseChainId;
        for (uint256 i; i < _supportedChains.length; i++) {
            s_supportedChains.push(_supportedChains[i]);
            s_isSupportedChain[_supportedChains[i]] = true;
        }
    }

    function setRegistry(address _registry) external onlyRole(DEFAULT_ADMIN_ROLE) {
        s_registry = _registry;
    }

    // functions
    /**
     * @dev calls chainlink function to query for data from the off-chain registry
     * @notice one user can have only one tokenized real estate registered
     * @param _paymentToken address of the token to be used for payment on the owner's real estate contract
     */
    function createTokenizedRealEstate(address _paymentToken, uint256[] memory chainsToDeploy) external returns (uint256 _tokenId) {
        require(balanceOf(msg.sender) == 0, AssetTokenizationManager__OnlyOneTokenizedRealEstatePerUser());
        require(block.chainid == i_baseChain, AssetTokenizationManager__ChainNotSupported());
        for (uint256 i; i < chainsToDeploy.length; i++) {
            require(s_isSupportedChain[chainsToDeploy[i]], AssetTokenizationManager__ChainNotSupported());
        }
        
        // @todo implement chainlink function call on offchain db to query for user approved real estate
        bytes32 reqId; // returned from chainlink functions request

        s_reqIdToTokenizeFunctionCallRequest[reqId] = TokenizeFunctionCallRequest({
            estateOwner: msg.sender,
            chainsToDeploy: chainsToDeploy,
            paymentToken: _paymentToken
        });

        emit TokenizationRequestPlaced(reqId, msg.sender);
    }

    // function mintAssetTokenizedRealEstateForEth(uint256 percentageForShareholders, uint256 amountOfAsset) external {
    //     _mint(msg.sender, s_tokenCounter);
    //     address tokenizedRealEstate = address(new TokenizedRealEstate(address(this), msg.sender, amountOfAsset, percentageForShareholders, s_tokenCounter));

    //     TokenizedRealEstate(tokenizedRealEstate).mintTokenizedRealEstateForEth();
    //     uint256 netAmountForShares = _calculateNetAmountForShares(percentageForShareholders, amountOfAsset);
    //     s_tokenidToAssetInfo[s_tokenCounter] = EstateInfo({
    //         estateOwner: msg.sender,
    //         sharesAvailable: percentageForShareholders,
    //         token: address(tokenizedRealEstate),
    //         amountOfAsset: amountOfAsset,
    //         currRentAmount: 0,
    //         netAmountForShareholders: netAmountForShares
    //     });
    //     TokenizedRealEstate(tokenizedRealEstate).updateAssetInfo(s_tokenCounter);
    //     s_tokenCounter++;
    // }

    // function updateRentAmount(uint256 tokenid, uint256 rentAmount) external onlyEstateOwner(tokenid) {
    //     s_tokenidToAssetInfo[tokenid].currRentAmount = rentAmount;
    //     address tokenizedRealEstate = s_tokenidToAssetInfo[tokenid].token;
    //     TokenizedRealEstate(tokenizedRealEstate).updateAssetInfoRentAmount(tokenid, rentAmount);
    // }

    function fulfillCreateEstateRequest(bytes32 _reqId, bytes memory _response) external {
        TokenizeFunctionCallRequest memory _request = s_reqIdToTokenizeFunctionCallRequest[_reqId];
        
        require(balanceOf(_request.estateOwner) == 0, AssetTokenizationManager__OnlyOneTokenizedRealEstatePerUser());

        uint256 estateCost;
        uint256 percentageToTokenize;
        bool isApproved;
        bytes32 salt;
        address _paymentToken = _request.paymentToken;
        uint256 _tokenId = s_tokenCounter;

        _mint(_request.estateOwner, _tokenId);
        s_tokenCounter++;

        // @todo changes maybe required
        address tokenizedRealEstate = address(new TokenizedRealEstate(address(this), _request.estateOwner, estateCost, percentageToTokenize, _tokenId));

        s_tokenidToEstateInfo[_tokenId] = EstateInfo({
            estateOwner: _request.estateOwner,
            percentageToTokenize: percentageToTokenize,
            tokenizedRealEstate: tokenizedRealEstate,
            estateCost: estateCost,
            accumulatedRewards: 0
        });

        for (uint256 i; i < _request.chainsToDeploy.length; i++) {
            // @todo implement chainlink ccip call to deploy contract on supported chains
        }
    }

    function _handleCrossChainMessage(bytes32 _messageId, bytes memory _data) internal override {

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

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        return "";
    }

    function getAssetInfo(uint256 tokenId) external view returns (EstateInfo memory) {
        return s_tokenidToEstateInfo[tokenId];
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, EstateAcrossChain) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || EstateAcrossChain.supportsInterface(interfaceId);
    }
}
