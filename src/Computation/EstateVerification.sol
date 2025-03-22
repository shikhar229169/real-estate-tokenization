// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { IRealEstateRegistry } from "../interfaces/IRealEstateRegistry.sol";
import { FunctionsClient, FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/v1_3_0/FunctionsClient.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { AssetTokenizationManager } from "../AssetTokenizationManager.sol";

contract EstateVerification is FunctionsClient {
    // libraries
    using FunctionsRequest for FunctionsRequest.Request;

    // Errors
    error EstateVerification__NotAuthorized();
    error EstateVerification__OnlyOneTokenizedRealEstatePerUser();
    error EstateVerification__ChainNotSupported();
    error EstateVerification__BaseChainRequired();
    error EstateVerification__TokenNotWhitelisted();
    error EstateVerification__NotAssetOwner();

    // Structs
    struct TokenizeFunctionCallRequest {
        address estateOwner;
        uint256[] chainsToDeploy;
        address paymentToken;
        address[] estateOwnerAcrossChain;
    }

    struct EstateVerificationFunctionsParams {
        string source;
        bytes encryptedSecretsUrls;
        uint64 subId;
        uint32 gasLimit;
        bytes32 donId;
    }

    // Variables
    mapping(bytes32 reqId => TokenizeFunctionCallRequest) private s_reqIdToTokenizeFunctionCallRequest;
    mapping(uint256 => bool) private s_isSupportedChain;
    address private s_registry;
    AssetTokenizationManager private immutable i_assetTokenizationManager;
    address private immutable i_owner;
    bytes private s_latestError;
    EstateVerificationFunctionsParams private s_estateVerificationFunctionsParams;
    uint256 private immutable i_baseChain;

    // Events
    event TokenizationRequestPlaced(bytes32 reqId, address estateOwner);

    // Modifiers
    modifier onlyAssetTokenizationManager {
        require(msg.sender == address(i_assetTokenizationManager), EstateVerification__NotAuthorized());
        _;
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, EstateVerification__NotAuthorized());
        _;
    }

    constructor(
        address _functionRouter, 
        uint256 _baseChainId, 
        uint256[] memory _supportedChains, 
        string memory _estateVerificationSource, 
        bytes memory _encryptedSecretsUrls, 
        uint64 _subId, 
        uint32 _gasLimit,
        bytes32 _donID,
        address _owner
    ) FunctionsClient(_functionRouter) {
        i_assetTokenizationManager = AssetTokenizationManager(msg.sender);
        i_baseChain = _baseChainId;
        s_estateVerificationFunctionsParams = EstateVerificationFunctionsParams({
            source: _estateVerificationSource,
            encryptedSecretsUrls: _encryptedSecretsUrls,
            subId: _subId,
            gasLimit: _gasLimit,
            donId: _donID
        });
        i_owner = _owner;
        for (uint256 i; i < _supportedChains.length; i++) {
            s_isSupportedChain[_supportedChains[i]] = true;
        }
    }

    function setRegistry(address _registry) external onlyAssetTokenizationManager {
        s_registry = _registry;
    }

    function setEstateVerificationSource(EstateVerificationFunctionsParams memory _params) external onlyOwner {
        s_estateVerificationFunctionsParams = _params;
    }

    /**
     * @dev calls chainlink function to query for data from the off-chain registry
     * @notice one user can have only one tokenized real estate registered
     * @param _paymentToken address of the token to be used for payment on the owner's real estate contract
     */
    function createTokenizedRealEstate(address _paymentToken, uint256[] memory chainsToDeploy, address[] memory _estateOwnerAcrossChain) external returns (bytes32) {
        require(i_assetTokenizationManager.balanceOf(msg.sender) == 0, EstateVerification__OnlyOneTokenizedRealEstatePerUser());
        require(block.chainid == i_baseChain, EstateVerification__ChainNotSupported());
        require(chainsToDeploy[0] == block.chainid, EstateVerification__BaseChainRequired());
        require(IRealEstateRegistry(s_registry).getDataFeedForToken(_paymentToken) != address(0), EstateVerification__TokenNotWhitelisted());
        require(msg.sender == _estateOwnerAcrossChain[0], EstateVerification__NotAssetOwner());
        for (uint256 i; i < chainsToDeploy.length; i++) {
            if (i > 0) {
                require(chainsToDeploy[i] != block.chainid, EstateVerification__ChainNotSupported());
            }
            require(s_isSupportedChain[chainsToDeploy[i]], EstateVerification__ChainNotSupported());
        }
        
        FunctionsRequest.Request memory req;
        string[] memory args = new string[](1);
        args[0] = Strings.toHexString(msg.sender);
        req.initializeRequestForInlineJavaScript(s_estateVerificationFunctionsParams.source);
        req.addSecretsReference(s_estateVerificationFunctionsParams.encryptedSecretsUrls);
        req.setArgs(args);

        bytes32 reqId = _sendRequest(
            req.encodeCBOR(),
            s_estateVerificationFunctionsParams.subId,
            s_estateVerificationFunctionsParams.gasLimit,
            s_estateVerificationFunctionsParams.donId
        );

        emit TokenizationRequestPlaced(reqId, msg.sender);
        s_reqIdToTokenizeFunctionCallRequest[reqId] = TokenizeFunctionCallRequest({
            estateOwner: msg.sender,
            chainsToDeploy: chainsToDeploy,
            paymentToken: _paymentToken,
            estateOwnerAcrossChain: _estateOwnerAcrossChain
        });

        return reqId;
    }


    function _fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (err.length > 0) {
            s_latestError = err;
            return;
        }
        s_latestError = "";
        TokenizeFunctionCallRequest memory _request = s_reqIdToTokenizeFunctionCallRequest[requestId];
        i_assetTokenizationManager.fulfillCreateEstateRequest(_request, response);
    }

    function createTestRequestIdResponse(TokenizeFunctionCallRequest memory _request, bytes memory _response) external {
        bytes32 _requestId = keccak256(abi.encode(_request));
        s_reqIdToTokenizeFunctionCallRequest[_requestId] = _request;
        i_assetTokenizationManager.fulfillCreateEstateRequest(_request, _response);
    }

    function getReqIdToTokenizeFunctionCallRequest(bytes32 reqId) external view returns (TokenizeFunctionCallRequest memory) {
        return s_reqIdToTokenizeFunctionCallRequest[reqId];
    }

    function getRegistry() external view returns (address) {
        return s_registry;
    }

    function getSupportedChain(uint256 chainId) external view returns (bool) {
        return s_isSupportedChain[chainId];
    }

    function getBaseChain() external view returns (uint256) {
        return i_baseChain;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getEstateVerificationFunctionsParams() external view returns (EstateVerificationFunctionsParams memory) {
        return s_estateVerificationFunctionsParams;
    }

    function getAssetTokenizationManager() external view returns (address) {
        return address(i_assetTokenizationManager);
    }

    function getLatestError() external view returns (bytes memory) {
        return s_latestError;
    }
}