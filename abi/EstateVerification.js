const abi = [
  {
    "type": "constructor",
    "inputs": [
      {
        "name": "_functionRouter",
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
      { "name": "_donID", "type": "bytes32", "internalType": "bytes32" },
      { "name": "_owner", "type": "address", "internalType": "address" }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "createTestRequestIdResponse",
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
    "name": "createTokenizedRealEstate",
    "inputs": [
      {
        "name": "_paymentToken",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "chainsToDeploy",
        "type": "uint256[]",
        "internalType": "uint256[]"
      },
      {
        "name": "_estateOwnerAcrossChain",
        "type": "address[]",
        "internalType": "address[]"
      }
    ],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getAssetTokenizationManager",
    "inputs": [],
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
    "name": "getEstateVerificationFunctionsParams",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct EstateVerification.EstateVerificationFunctionsParams",
        "components": [
          { "name": "source", "type": "string", "internalType": "string" },
          {
            "name": "encryptedSecretsUrls",
            "type": "bytes",
            "internalType": "bytes"
          },
          { "name": "subId", "type": "uint64", "internalType": "uint64" },
          { "name": "gasLimit", "type": "uint32", "internalType": "uint32" },
          { "name": "donId", "type": "bytes32", "internalType": "bytes32" }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getLatestError",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes", "internalType": "bytes" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOwner",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
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
    "name": "getReqIdToTokenizeFunctionCallRequest",
    "inputs": [
      { "name": "reqId", "type": "bytes32", "internalType": "bytes32" }
    ],
    "outputs": [
      {
        "name": "",
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
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getSupportedChain",
    "inputs": [
      { "name": "chainId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "handleOracleFulfillment",
    "inputs": [
      { "name": "requestId", "type": "bytes32", "internalType": "bytes32" },
      { "name": "response", "type": "bytes", "internalType": "bytes" },
      { "name": "err", "type": "bytes", "internalType": "bytes" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setEstateVerificationSource",
    "inputs": [
      {
        "name": "_params",
        "type": "tuple",
        "internalType": "struct EstateVerification.EstateVerificationFunctionsParams",
        "components": [
          { "name": "source", "type": "string", "internalType": "string" },
          {
            "name": "encryptedSecretsUrls",
            "type": "bytes",
            "internalType": "bytes"
          },
          { "name": "subId", "type": "uint64", "internalType": "uint64" },
          { "name": "gasLimit", "type": "uint32", "internalType": "uint32" },
          { "name": "donId", "type": "bytes32", "internalType": "bytes32" }
        ]
      }
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
    "type": "event",
    "name": "RequestFulfilled",
    "inputs": [
      {
        "name": "id",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RequestSent",
    "inputs": [
      {
        "name": "id",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "TokenizationRequestPlaced",
    "inputs": [
      {
        "name": "reqId",
        "type": "bytes32",
        "indexed": false,
        "internalType": "bytes32"
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
  { "type": "error", "name": "EmptyArgs", "inputs": [] },
  { "type": "error", "name": "EmptySecrets", "inputs": [] },
  { "type": "error", "name": "EmptySource", "inputs": [] },
  {
    "type": "error",
    "name": "EstateVerification__BaseChainRequired",
    "inputs": []
  },
  {
    "type": "error",
    "name": "EstateVerification__ChainNotSupported",
    "inputs": []
  },
  {
    "type": "error",
    "name": "EstateVerification__NotAssetOwner",
    "inputs": []
  },
  {
    "type": "error",
    "name": "EstateVerification__NotAuthorized",
    "inputs": []
  },
  {
    "type": "error",
    "name": "EstateVerification__OnlyOneTokenizedRealEstatePerUser",
    "inputs": []
  },
  {
    "type": "error",
    "name": "EstateVerification__TokenNotWhitelisted",
    "inputs": []
  },
  { "type": "error", "name": "NoInlineSecrets", "inputs": [] },
  { "type": "error", "name": "OnlyRouterCanFulfill", "inputs": [] },
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