// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {TokenizedRealEstate} from "../src/TokenizedRealEstate.sol";
import {AssetTokenizationManager} from "../src/AssetTokenizationManager.sol";
import {DeployAssetTokenizationManager} from "../script/DeployAssetTokenizationManager.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {VerifyingOperatorVault} from "../src/VerifyingOperatorVault.sol";
import {RealEstateRegistry} from "../src/RealEstateRegistry.sol";

contract AssetTokenizationManagerTest is Test {
    error AssetTokenizationManager__BaseChainRequired();
    error AssetTokenizationManager__TokenNotWhitelisted();
    error AssetTokenizationManager__NotAssetOwner();
    error RealEstateRegistry__InvalidToken();
    error RealEstateRegistry__InvalidCollateral();
    error RealEstateRegistry__InvalidENSName();

    TokenizedRealEstate public tokenizedRealEstate;
    address public user;
    address owner;
    uint256 ownerKey;
    address slasher;
    address signer;
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig public networkConfig;
    AssetTokenizationManager public assetTokenizationManager;
    DeployAssetTokenizationManager public deployer;
    RealEstateRegistry public realEstateRegistry;
    VerifyingOperatorVault public verifyingOperatorVault;

    function setUp() public {
        (owner, ownerKey) = makeAddrAndKey("owner");
        slasher = makeAddr("slasher");
        signer = makeAddr("signer");

        deployer = new DeployAssetTokenizationManager();
        (assetTokenizationManager, helperConfig) = deployer.deploy(owner, ownerKey);
        networkConfig = helperConfig.getNetworkConfig();

        address[] memory _acceptedTokens = new address[](1);
        _acceptedTokens[0] = networkConfig.link;
        address[] memory dataFeeds = new address[](1);
        dataFeeds[0] = makeAddr("dataFeed");
        
        verifyingOperatorVault = new VerifyingOperatorVault();

        vm.startPrank(address(owner));
        realEstateRegistry = new RealEstateRegistry(
            slasher,
            signer,
            1e18,
            _acceptedTokens,
            dataFeeds,
            address(verifyingOperatorVault),
            networkConfig.swapRouter,
            address(assetTokenizationManager)
        );

        vm.stopPrank();

        user = makeAddr("user");
    }

    function test_ConstructorAssetTokenizationManager() public view {
        assertEq(assetTokenizationManager.getBaseChain(), networkConfig.baseChainId);
        uint256[] memory supportedChains = assetTokenizationManager.getSupportedChains();
        for (uint256 i = 0; i < supportedChains.length; i++) {
            assertEq(supportedChains[i], networkConfig.supportedChains[i]);
        }
    }

    function test_createTokenizedRealEstate_IsBaseChainRequired() public {
        uint256[] memory _chainsToDeploy = new uint256[](2);

        address[] memory _estateOwnerAcrossChain = new address[](2);

        vm.startPrank(user);
        vm.expectRevert(AssetTokenizationManager__BaseChainRequired.selector);
        assetTokenizationManager.createTokenizedRealEstate(networkConfig.link, _chainsToDeploy, _estateOwnerAcrossChain);
        vm.stopPrank();
    }

    function test_createTokenizedRealEstate() public {
        uint256[] memory _chainsToDeploy = new uint256[](2);
        _chainsToDeploy[0] = networkConfig.supportedChains[0];
        _chainsToDeploy[1] = networkConfig.supportedChains[1];

        address[] memory _estateOwnerAcrossChain = new address[](2);

        vm.startPrank(user);
        vm.expectRevert();
        assetTokenizationManager.createTokenizedRealEstate(networkConfig.link, _chainsToDeploy, _estateOwnerAcrossChain);
        vm.stopPrank();
    }

    function test_setRegistryIsNotCallableFroUsers() public {
        vm.startPrank(user);
        vm.expectRevert();
        assetTokenizationManager.setRegistry(address(realEstateRegistry));
        vm.stopPrank();
    }

    function test_setEstateVerificationSourceIsNotCallableFroUsers() public {
        AssetTokenizationManager.EstateVerificationFunctionsParams memory _params;
        _params.source = "source";
        _params.encryptedSecretsUrls = "encryptedSecretsUrls";
        _params.subId = 1;
        _params.gasLimit = 1;
        _params.donId = "0x1";

        vm.startPrank(user);
        vm.expectRevert();
        assetTokenizationManager.setEstateVerificationSource(_params);
        vm.stopPrank();
    }

    function test_setEstateVerificationSource() public {
        AssetTokenizationManager.EstateVerificationFunctionsParams memory _params;
        _params.source = "source";
        _params.encryptedSecretsUrls = "encryptedSecretsUrls";
        _params.subId = 1;
        _params.gasLimit = 1;
        _params.donId = "0x1";

        vm.startPrank(address(owner));
        assetTokenizationManager.setEstateVerificationSource(_params);
        vm.stopPrank();
    }

    function test_setRegistry() public {
        vm.startPrank(address(owner));
        assetTokenizationManager.setRegistry(address(realEstateRegistry));
        vm.stopPrank();
    }

    function test_createTokenizedRealEstateRegistryIfTokenNotWhitelisted() public {
        uint256[] memory _chainsToDeploy = new uint256[](2);
        _chainsToDeploy[0] = networkConfig.supportedChains[0];
        _chainsToDeploy[1] = networkConfig.supportedChains[1];

        address[] memory _estateOwnerAcrossChain = new address[](2);
        
        vm.startPrank(owner);
        assetTokenizationManager.setRegistry(address(realEstateRegistry));
        vm.stopPrank();

        address paymentToken = makeAddr("paymentToken");
        vm.expectRevert(AssetTokenizationManager__TokenNotWhitelisted.selector);
        vm.startPrank(address(user));
        assetTokenizationManager.createTokenizedRealEstate(paymentToken, _chainsToDeploy, _estateOwnerAcrossChain);
        vm.stopPrank();
    }

    function test_createTokenizedRealEstateRegistryNotAssetOwner() public {
        uint256[] memory _chainsToDeploy = new uint256[](2);
        _chainsToDeploy[0] = networkConfig.supportedChains[0];
        _chainsToDeploy[1] = networkConfig.supportedChains[1];

        address[] memory _estateOwnerAcrossChain = new address[](2);
        
        vm.startPrank(owner);
        assetTokenizationManager.setRegistry(address(realEstateRegistry));
        vm.stopPrank();

        address paymentToken = networkConfig.link;
        vm.startPrank(address(user));
        vm.expectRevert(AssetTokenizationManager__NotAssetOwner.selector);
        assetTokenizationManager.createTokenizedRealEstate(paymentToken, _chainsToDeploy, _estateOwnerAcrossChain);
        vm.stopPrank();
    }

    // function test_createTokenizedRealEstate_RegistryYOYO() public {
    //     uint256[] memory _chainsToDeploy = new uint256[](2);
    //     _chainsToDeploy[0] = networkConfig.supportedChains[0];
    //     _chainsToDeploy[1] = networkConfig.supportedChains[1];

    //     address[] memory _estateOwnerAcrossChain = new address[](2);
    //     _estateOwnerAcrossChain[0] = address(user);
    //     _estateOwnerAcrossChain[1] = address(0x2);

    //     // vm.deal(user, 1e18);
    //     vm.startPrank(owner);
    //     assetTokenizationManager.setRegistry(address(realEstateRegistry));
    //     vm.stopPrank();

    //     address paymentToken = networkConfig.link;
    //     vm.startPrank(address(user));
    //     assetTokenizationManager.createTokenizedRealEstate(paymentToken, _chainsToDeploy, _estateOwnerAcrossChain);
    //     vm.stopPrank();
    // }

    function test_setTokenForAnotherChainIfNotSETTER_ROLE() public {
        address token = makeAddr("token");
        uint256 chainId = 1;

        vm.startPrank(user);
        vm.expectRevert();
        realEstateRegistry.setTokenForAnotherChain(token, chainId, networkConfig.link);
        vm.stopPrank();
    }

    function test_setTokenForAnotherChainIfInvalidToken() public {
        address token = makeAddr("token");
        uint256 chainId = 1;

        vm.startPrank(owner);
        vm.expectRevert(RealEstateRegistry__InvalidToken.selector);
        realEstateRegistry.setTokenForAnotherChain(token, chainId, networkConfig.link);
        vm.stopPrank();
    }

    function test_setTokenForAnotherChain() public {
        address token = networkConfig.link;
        uint256 chainId = 1;

        vm.startPrank(owner);
        realEstateRegistry.setTokenForAnotherChain(token, chainId, networkConfig.link);
        vm.stopPrank();
    }

    function test_addCollateralTokenIfNotSETTER_ROLE() public {
        address token = networkConfig.link;
        address datafeed = makeAddr("datafeed");

        vm.startPrank(user);
        vm.expectRevert();
        realEstateRegistry.addCollateralToken(token, datafeed);
        vm.stopPrank();
    }

    function test_setSwapRouterIfNotSETTER_ROLE() public {
        address swapRouter = makeAddr("swapRouter");

        vm.startPrank(user);
        vm.expectRevert();
        realEstateRegistry.setSwapRouter(swapRouter);
        vm.stopPrank();
    }

    function test_setSwapRouter() public {
        address swapRouter = makeAddr("swapRouter");

        vm.startPrank(owner);
        realEstateRegistry.setSwapRouter(swapRouter);
        vm.stopPrank();
    }

    function test_updateVOVImplementation() public {
        address newImplementation = makeAddr("newImplementation");

        vm.startPrank(owner);
        realEstateRegistry.updateVOVImplementation(newImplementation);
        vm.stopPrank();
    }

    function test_updateVOVImplementationIfNotSETTER_ROLE() public {
        address newImplementation = makeAddr("newImplementation");

        vm.startPrank(user);
        vm.expectRevert();
        realEstateRegistry.updateVOVImplementation(newImplementation);
        vm.stopPrank();
    }

    function test_setCollateralRequiredForOperatorIfInvalidLowCollateral() public {
        uint256 newOperatorCollateral = 1_000;

        vm.startPrank(owner);
        vm.expectRevert(RealEstateRegistry__InvalidCollateral.selector);
        realEstateRegistry.setCollateralRequiredForOperator(newOperatorCollateral);
        vm.stopPrank();
    }

    function test_setCollateralRequiredForOperatorIfInvalidHighCollateral() public {
        uint256 newOperatorCollateral = 1_30_000;

        vm.startPrank(owner);
        vm.expectRevert(RealEstateRegistry__InvalidCollateral.selector);
        realEstateRegistry.setCollateralRequiredForOperator(newOperatorCollateral);
        vm.stopPrank();
    }

    function test_setCollateralRequiredForOperatorIfNotSETTER_ROLE() public {
        uint256 newOperatorCollateral = 50_000;

        vm.startPrank(user);
        vm.expectRevert();
        realEstateRegistry.setCollateralRequiredForOperator(newOperatorCollateral);
        vm.stopPrank();
    }

    function test_setCollateralRequiredForOperator() public {
        uint256 newOperatorCollateral = 50_000;

        vm.startPrank(owner);
        realEstateRegistry.setCollateralRequiredForOperator(newOperatorCollateral);
        vm.stopPrank();
        assertEq(realEstateRegistry.getFiatCollateralRequiredForOperator(), newOperatorCollateral);
    }

    function test_approveOperatorVaultInvalidENSName() public {
        string memory operatorVaultEns = "operatorVaultEns";
        uint256 collateral = 50_000;

        vm.startPrank(owner);
        realEstateRegistry.setCollateralRequiredForOperator(collateral);
        vm.expectRevert(RealEstateRegistry__InvalidENSName.selector);
        realEstateRegistry.approveOperatorVault(operatorVaultEns);
        vm.stopPrank();
    }

    // function test_approveOperatorVault__() public {
    //     string memory operatorVaultEns = "operatorVaultEns";
    //     uint256 collateral = 50_000;

    //     vm.startPrank(signer);
    //     realEstateRegistry.setCollateralRequiredForOperator(collateral);
    //     realEstateRegistry.approveOperatorVault(operatorVaultEns);
    //     vm.stopPrank();
    // }

    // function test_depositCollateralAndRegisterVault() public {
    //     string memory operatorVaultEns = "operatorVaultEns";
    //     uint256 collateral = 50_000;
    //     bytes memory data = abi.encode(operatorVaultEns, networkConfig.link, 1e18);

    //     vm.startPrank(owner);
    //     realEstateRegistry.setCollateralRequiredForOperator(collateral);
    //     realEstateRegistry.depositCollateralAndRegisterVault(operatorVaultEns, networkConfig.link, data, false);
    //     vm.stopPrank();
    // }

    function test_fulfillCreateEstateRequest() public {
        AssetTokenizationManager.TokenizeFunctionCallRequest memory request;
        request.estateOwner = user;
        request.chainsToDeploy = new uint256[](2);
        request.chainsToDeploy[0] = networkConfig.supportedChains[0];
        request.chainsToDeploy[1] = networkConfig.supportedChains[1];
        request.paymentToken = networkConfig.link;
        request.estateOwnerAcrossChain = new address[](2);
        request.estateOwnerAcrossChain[0] = user;
        request.estateOwnerAcrossChain[1] = makeAddr("owner");

        uint256 estateCost = 1e18;
        uint256 percentageToTokenize = 50;
        bool isApproved = true;
        bytes memory _saltBytes = abi.encode(5802);
        address _verifyingOperator = makeAddr("verifyingOperator");

        bytes memory response = abi.encode(estateCost, percentageToTokenize, isApproved, _saltBytes, _verifyingOperator);
        
        vm.startPrank(owner);
        assetTokenizationManager.createTestRequestIdResponse(request, response);
        vm.stopPrank();
    }
}
