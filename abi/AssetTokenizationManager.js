const abi = [
  {
    "type": "constructor",
    "inputs": [
      { "name": "_ccipRouter", "type": "address", "internalType": "address" },
      { "name": "_link", "type": "address", "internalType": "address" },
      {
        "name": "_functionsRouter",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "_baseChainId",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "_supportedChains",
        "type": "uint256[]",
        "internalType": "uint256[]"
      },
      {
        "name": "_chainSelectors",
        "type": "uint64[]",
        "internalType": "uint64[]"
      },
      {
        "name": "_estateVerificationSource",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "_encryptedSecretsUrls",
        "type": "bytes",
        "internalType": "bytes"
      },
      { "name": "_subId", "type": "uint64", "internalType": "uint64" },
      { "name": "_gasLimit", "type": "uint32", "internalType": "uint32" },
      { "name": "_donID", "type": "bytes32", "internalType": "bytes32" }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "acceptOwnership",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "allowlistManager",
    "inputs": [
      {
        "name": "_chainSelector",
        "type": "uint64",
        "internalType": "uint64"
      },
      { "name": "_manager", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "approve",
    "inputs": [
      { "name": "to", "type": "address", "internalType": "address" },
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "balanceOf",
    "inputs": [
      { "name": "owner", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "bridgeRequestFromTRE",
    "inputs": [
      { "name": "_data", "type": "bytes", "internalType": "bytes" },
      { "name": "_gasLimit", "type": "uint256", "internalType": "uint256" },
      {
        "name": "_destChainId",
        "type": "uint256",
        "internalType": "uint256"
      },
      { "name": "_tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "ccipReceive",
    "inputs": [
      {
        "name": "message",
        "type": "tuple",
        "internalType": "struct Client.Any2EVMMessage",
        "components": [
          {
            "name": "messageId",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "sourceChainSelector",
            "type": "uint64",
            "internalType": "uint64"
          },
          { "name": "sender", "type": "bytes", "internalType": "bytes" },
          { "name": "data", "type": "bytes", "internalType": "bytes" },
          {
            "name": "destTokenAmounts",
            "type": "tuple[]",
            "internalType": "struct Client.EVMTokenAmount[]",
            "components": [
              {
                "name": "token",
                "type": "address",
                "internalType": "address"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "chainIdToSelector",
    "inputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "outputs": [{ "name": "", "type": "uint64", "internalType": "uint64" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "chainSelectorToManager",
    "inputs": [{ "name": "", "type": "uint64", "internalType": "uint64" }],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "fulfillCreateEstateRequest",
    "inputs": [
      {
        "name": "_request",
        "type": "tuple",
        "internalType": "struct EstateVerification.TokenizeFunctionCallRequest",
        "components": [
          {
            "name": "estateOwner",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "chainsToDeploy",
            "type": "uint256[]",
            "internalType": "uint256[]"
          },
          {
            "name": "paymentToken",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "estateOwnerAcrossChain",
            "type": "address[]",
            "internalType": "address[]"
          }
        ]
      },
      { "name": "_response", "type": "bytes", "internalType": "bytes" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getAllChainDeploymentAddr",
    "inputs": [
      {
        "name": "_estateOwner",
        "type": "address[]",
        "internalType": "address[]"
      },
      { "name": "_estateCost", "type": "uint256", "internalType": "uint256" },
      {
        "name": "_percentageToTokenize",
        "type": "uint256",
        "internalType": "uint256"
      },
      { "name": "_tokenId", "type": "uint256", "internalType": "uint256" },
      { "name": "_salt", "type": "bytes32", "internalType": "bytes32" },
      {
        "name": "_paymentToken",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "_chainsToDeploy",
        "type": "uint256[]",
        "internalType": "uint256[]"
      }
    ],
    "outputs": [
      { "name": "", "type": "address[]", "internalType": "address[]" }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getApproved",
    "inputs": [
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getBaseChain",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getCollateralDepositedBy",
    "inputs": [
      { "name": "estateOwner", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getEstateInfo",
    "inputs": [
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct AssetTokenizationManager.EstateInfo",
        "components": [
          {
            "name": "estateOwner",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "percentageToTokenize",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "tokenizedRealEstate",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "estateCost",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "accumulatedRewards",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "verifyingOperator",
            "type": "address",
            "internalType": "address"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getEstateOwnerToTokeinzedRealEstate",
    "inputs": [
      { "name": "estateOwner", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getEstateVerification",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getIsSupportedChain",
    "inputs": [
      { "name": "chainId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getLastMessage",
    "inputs": [],
    "outputs": [{ "name": "data", "type": "bytes", "internalType": "bytes" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRegistry",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRouter",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getSupportedChains",
    "inputs": [],
    "outputs": [
      { "name": "", "type": "uint256[]", "internalType": "uint256[]" }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getTokenCounter",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getTokenIdToChainIdToTokenizedRealEstate",
    "inputs": [
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" },
      { "name": "chainId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isApprovedForAll",
    "inputs": [
      { "name": "owner", "type": "address", "internalType": "address" },
      { "name": "operator", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "name",
    "inputs": [],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "owner",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "ownerOf",
    "inputs": [
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "safeTransferFrom",
    "inputs": [
      { "name": "from", "type": "address", "internalType": "address" },
      { "name": "to", "type": "address", "internalType": "address" },
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "safeTransferFrom",
    "inputs": [
      { "name": "from", "type": "address", "internalType": "address" },
      { "name": "to", "type": "address", "internalType": "address" },
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" },
      { "name": "data", "type": "bytes", "internalType": "bytes" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setApprovalForAll",
    "inputs": [
      { "name": "operator", "type": "address", "internalType": "address" },
      { "name": "approved", "type": "bool", "internalType": "bool" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setRegistry",
    "inputs": [
      { "name": "_registry", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "supportsInterface",
    "inputs": [
      { "name": "interfaceId", "type": "bytes4", "internalType": "bytes4" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "symbol",
    "inputs": [],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "tokenURI",
    "inputs": [
      { "name": "_tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "transferFrom",
    "inputs": [
      { "name": "from", "type": "address", "internalType": "address" },
      { "name": "to", "type": "address", "internalType": "address" },
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "transferOwnership",
    "inputs": [
      { "name": "to", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "Approval",
    "inputs": [
      {
        "name": "owner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "approved",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "tokenId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "ApprovalForAll",
    "inputs": [
      {
        "name": "owner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "approved",
        "type": "bool",
        "indexed": false,
        "internalType": "bool"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "MessageReceived",
    "inputs": [
      {
        "name": "messageId",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "sourceChainSelector",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "sender",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "data",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "MessageSent",
    "inputs": [
      {
        "name": "messageId",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "destinationChainSelector",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "receiver",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "data",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      },
      {
        "name": "feeToken",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "fees",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OwnershipTransferRequested",
    "inputs": [
      {
        "name": "from",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "to",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OwnershipTransferred",
    "inputs": [
      {
        "name": "from",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "to",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "TokenizedRealEstateDeployed",
    "inputs": [
      {
        "name": "tokenId",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "tokenizedRealEstate",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "estateOwner",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Transfer",
    "inputs": [
      {
        "name": "from",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "to",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "tokenId",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "AssetTokenizationManager__NotAssetOwner",
    "inputs": []
  },
  {
    "type": "error",
    "name": "AssetTokenizationManager__NotAuthorized",
    "inputs": []
  },
  {
    "type": "error",
    "name": "AssetTokenizationManager__OnlyOneTokenizedRealEstatePerUser",
    "inputs": []
  },
  {
    "type": "error",
    "name": "DestinationChainNotAllowlisted",
    "inputs": [
      {
        "name": "destinationChainSelector",
        "type": "uint64",
        "internalType": "uint64"
      }
    ]
  },
  {
    "type": "error",
    "name": "ERC721IncorrectOwner",
    "inputs": [
      { "name": "sender", "type": "address", "internalType": "address" },
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" },
      { "name": "owner", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "ERC721InsufficientApproval",
    "inputs": [
      { "name": "operator", "type": "address", "internalType": "address" },
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ]
  },
  {
    "type": "error",
    "name": "ERC721InvalidApprover",
    "inputs": [
      { "name": "approver", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "ERC721InvalidOperator",
    "inputs": [
      { "name": "operator", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "ERC721InvalidOwner",
    "inputs": [
      { "name": "owner", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "ERC721InvalidReceiver",
    "inputs": [
      { "name": "receiver", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "ERC721InvalidSender",
    "inputs": [
      { "name": "sender", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "ERC721NonexistentToken",
    "inputs": [
      { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
    ]
  },
  {
    "type": "error",
    "name": "FailedToWithdrawEth",
    "inputs": [
      { "name": "owner", "type": "address", "internalType": "address" },
      { "name": "target", "type": "address", "internalType": "address" },
      { "name": "value", "type": "uint256", "internalType": "uint256" }
    ]
  },
  { "type": "error", "name": "InvalidReceiverAddress", "inputs": [] },
  {
    "type": "error",
    "name": "InvalidRouter",
    "inputs": [
      { "name": "router", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "NotEnoughBalance",
    "inputs": [
      {
        "name": "currentBalance",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "calculatedFees",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  { "type": "error", "name": "NothingToWithdraw", "inputs": [] },
  {
    "type": "error",
    "name": "SafeERC20FailedOperation",
    "inputs": [
      { "name": "token", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "SenderNotAllowlisted",
    "inputs": [
      { "name": "sender", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "SourceChainNotAllowlisted",
    "inputs": [
      {
        "name": "sourceChainSelector",
        "type": "uint64",
        "internalType": "uint64"
      }
    ]
  },
  {
    "type": "error",
    "name": "StringsInsufficientHexLength",
    "inputs": [
      { "name": "value", "type": "uint256", "internalType": "uint256" },
      { "name": "length", "type": "uint256", "internalType": "uint256" }
    ]
  }
]

export default abi;