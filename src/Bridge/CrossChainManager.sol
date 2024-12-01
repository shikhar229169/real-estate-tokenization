// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";


contract CrossChainManager is CCIPReceiver, OwnerIsCreator, AccessControl {
    using SafeERC20 for IERC20;

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
    error NothingToWithdraw(); 
    error FailedToWithdrawEth(address owner, address target, uint256 value); 
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); 
    error SourceChainNotAllowlisted(uint64 sourceChainSelector); 
    error SenderNotAllowlisted(address sender); 
    error InvalidReceiverAddress(); 

    struct CCManager {
        address ccManager;
        uint64 chainSelector;
    }

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

    bytes32 private constant BRIDGER_ROLE = keccak256("BRIDGER_ROLE");
    bytes32 private s_lastReceivedMessageId; 
    bytes private s_lastReceivedData;

    mapping(uint64 => bool) public allowlistedDestinationChains;

    mapping(uint64 => bool) public allowlistedSourceChains;

    mapping(address => bool) public allowlistedSenders;

    mapping(string => CCManager) public chainToCCManager;

    IERC20 private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @dev Modifier that checks if the chain with the given destinationChainSelector is allowlisted.
    /// @param _destinationChainSelector The selector of the destination chain.
    modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
        if (!allowlistedDestinationChains[_destinationChainSelector])
            revert DestinationChainNotAllowlisted(_destinationChainSelector);
        _;
    }

    /// @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
    /// @param _sourceChainSelector The selector of the destination chain.
    /// @param _sender The address of the sender.
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (!allowlistedSourceChains[_sourceChainSelector])
            revert SourceChainNotAllowlisted(_sourceChainSelector);
        if (!allowlistedSenders[_sender]) revert SenderNotAllowlisted(_sender);
        _;
    }

    /// @dev Modifier that checks the receiver address is not 0.
    /// @param _receiver The receiver address.
    modifier validateReceiver(address _receiver) {
        if (_receiver == address(0)) revert InvalidReceiverAddress();
        _;
    }

    /// @dev Updates the allowlist status of a destination chain for transactions.
    function allowlistDestinationChain(
        uint64 _destinationChainSelector,
        bool allowed
    ) external onlyOwner {
        allowlistedDestinationChains[_destinationChainSelector] = allowed;
    }

    /// @dev Updates the allowlist status of a source chain for transactions.
    function allowlistSourceChain(
        uint64 _sourceChainSelector,
        bool allowed
    ) external onlyOwner {
        allowlistedSourceChains[_sourceChainSelector] = allowed;
    }

    /// @dev Updates the allowlist status of a sender for transactions.
    function allowlistSender(address _sender, bool allowed) external onlyOwner {
        allowlistedSenders[_sender] = allowed;
    }

    function addCCManagerForChain(string memory chain, address ccmanager, uint64 chainSelector) external onlyOwner {
        chainToCCManager[chain] = CCManager({
            ccManager: ccmanager,
            chainSelector: chainSelector
        });
    }

    function bridgeRequest(address _sender, string memory _chain, bytes calldata _data) external onlyRole(BRIDGER_ROLE) returns (bytes32) {
        return _sendMessagePayLINK(_sender, chainToCCManager[_chain].chainSelector, chainToCCManager[_chain].ccManager, _data);
    }

    /// @notice Sends data to receiver on the destination chain.
    /// @notice Pay for fees in LINK.
    /// @dev Assumes your contract has sufficient LINK.
    /// @param _sender The user who initiated the bridge request on real estate 
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _receiver The address of receiving contract
    /// @param _data The data to be sent.
    /// @return messageId The ID of the CCIP message that was sent.
    function _sendMessagePayLINK(
        address _sender,
        uint64 _destinationChainSelector,
        address _receiver,
        bytes calldata _data
    )
        internal
        onlyAllowlistedDestinationChain(_destinationChainSelector)
        validateReceiver(_receiver)
        returns (bytes32 messageId)
    {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _data,
            address(s_linkToken)
        );

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        // Get the fee required to send the CCIP message
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        s_linkToken.safeTransferFrom(_sender, address(this), fees);

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

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            any2EvmMessage.data
        );
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a text.
    /// @param _receiver The address of the receiver.
    /// @param _data The data to be sent.
    /// @param _feeTokenAddress The address of the token used for fees. Set address(0) for native gas.
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        address _receiver,
        bytes calldata _data,
        address _feeTokenAddress
    ) private pure returns (Client.EVM2AnyMessage memory) {
        return Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver), 
            data: _data,
            tokenAmounts: new Client.EVMTokenAmount[](0), // no tokens being transferred, only data
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV2({
                    gasLimit: 200_000, 
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(CCIPReceiver, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
