// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract EstateAcrossChain is CCIPReceiver, OwnerIsCreator, AccessControl {
    using SafeERC20 for IERC20;

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
    error NothingToWithdraw(); 
    error FailedToWithdrawEth(address owner, address target, uint256 value); 
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); 
    error SourceChainNotAllowlisted(uint64 sourceChainSelector); 
    error SenderNotAllowlisted(address sender); 
    error InvalidReceiverAddress(); 

    event MessageSent(
        bytes32 indexed messageId, 
        uint64 indexed destinationChainSelector, 
        address receiver, 
        bytes data, 
        address feeToken, 
        uint256 fees 
    );

    event MessageReceived(
        bytes32 indexed messageId, 
        uint64 indexed sourceChainSelector, 
        address sender, 
        bytes data 
    );

    bytes32 private s_lastReceivedMessageId; 
    bytes private s_lastReceivedData;
    bool public testPhase;
    bool public result = false;

    mapping(uint256 => uint64) public chainIdToSelector;
    mapping(uint64 => address) public chainSelectorToManager;

    IERC20 private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link, uint256[] memory _chainId, uint64[] memory _chainSelector) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
        testPhase = true;

        for (uint256 i = 0; i < _chainId.length; i++) {
            chainIdToSelector[_chainId[i]] = _chainSelector[i];
        }

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
    /// @param _sourceChainSelector The selector of the source chain.
    /// @param _sender The address of the sender.
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (chainSelectorToManager[_sourceChainSelector] != _sender && !testPhase) {
            revert SenderNotAllowlisted(_sender);
        }
        else {
            result = (chainSelectorToManager[_sourceChainSelector] == _sender);
        }
        _;
    }

    /// @dev Modifier that checks the receiver address is not 0.
    /// @param _receiver The receiver address.
    modifier validateReceiver(address _receiver) {
        if (_receiver == address(0)) revert InvalidReceiverAddress();
        _;
    }

    function switchPhase() external onlyOwner {
        testPhase = !testPhase;
    }

    /// @dev Updates the allowlist status of a sender for transactions.
    /// @notice used to allowlist the AssetTokenizationManager on various chains
    function allowlistManager(uint64 _chainSelector, address _manager) external onlyOwner {
        chainSelectorToManager[_chainSelector] = _manager;
    }

    function bridgeRequest(uint256 _chainId, bytes memory _data, uint256 _gasLimit) internal returns (bytes32) {
        return _sendMessagePayLINK(chainIdToSelector[_chainId], chainSelectorToManager[chainIdToSelector[_chainId]], _data, _gasLimit);
    }

    /// @notice Sends data to receiver on the destination chain.
    /// @notice Pay for fees in LINK.
    /// @dev Assumes your contract has sufficient LINK.
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _receiver The address of receiving contract
    /// @param _data The data to be sent.
    /// @return messageId The ID of the CCIP message that was sent.
    function _sendMessagePayLINK(
        uint64 _destinationChainSelector,
        address _receiver,
        bytes memory _data,
        uint256 _gasLimit
    )
        internal
        validateReceiver(_receiver)
        returns (bytes32 messageId)
    {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _data,
            address(s_linkToken),
            _gasLimit
        );

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        // Get the fee required to send the CCIP message
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        // s_linkToken.safeTransferFrom(msg.sender, address(this), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(router), fees);

        // Send the CCIP message through the router and store the returned CCIP message ID
        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            _data,
            address(s_linkToken),
            fees
        );

        // Return the CCIP message ID
        return messageId;
    }

    
    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    )
        internal
        override
        onlyAllowlisted(
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address))
        ) // Make sure source chain and sender are allowlisted
    {
        s_lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
        s_lastReceivedData = any2EvmMessage.data; // fetch the data

        if (testPhase) {
            return;
        }

        _handleCrossChainMessage(s_lastReceivedMessageId, s_lastReceivedData);

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            any2EvmMessage.data
        );
    }

    function _handleCrossChainMessage(bytes32 _messageId, bytes memory _data) internal virtual;

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a text.
    /// @param _receiver The address of the receiver.
    /// @param _data The data to be sent.
    /// @param _feeTokenAddress The address of the token used for fees. Set address(0) for native gas.
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        address _receiver,
        bytes memory _data,
        address _feeTokenAddress,
        uint256 _gasLimit
    ) private pure returns (Client.EVM2AnyMessage memory) {
        return Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver), 
            data: _data,
            tokenAmounts: new Client.EVMTokenAmount[](0), // no tokens being transferred, only data
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV2({
                    gasLimit: _gasLimit, 
                    allowOutOfOrderExecution: true // Allows the message to be executed out of order relative to other messages from the same sender
                })
            ),
            feeToken: _feeTokenAddress
        });
    }

    /// @notice Fetches the details of the last received message.
    /// @return messageId The ID of the last received message.
    /// @return data The last received text.
    function getLastReceivedMessageDetails()
        external
        view
        returns (bytes32 messageId, bytes memory data)
    {
        return (s_lastReceivedMessageId, s_lastReceivedData);
    }

    /// @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
    /// @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    /// @param _beneficiary The address to which the tokens will be sent.
    /// @param _token The contract address of the ERC20 token to be withdrawn.
    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).safeTransfer(_beneficiary, amount);
    }

    function getLinkToken() public view returns (IERC20) {
        return s_linkToken;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(CCIPReceiver, AccessControl) returns (bool) {
        return CCIPReceiver.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }
}
