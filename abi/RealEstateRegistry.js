const abi = [
  {
    "type": "constructor",
    "inputs": [
      { "name": "_slasher", "type": "address", "internalType": "address" },
      { "name": "_signer", "type": "address", "internalType": "address" },
      {
        "name": "_collateralReqInFiat",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "_acceptedTokens",
        "type": "address[]",
        "internalType": "address[]"
      },
      {
        "name": "_dataFeeds",
        "type": "address[]",
        "internalType": "address[]"
      },
      {
        "name": "_verifyingOpVaultImplementation",
        "type": "address",
        "internalType": "address"
      },
      { "name": "_swapRouter", "type": "address", "internalType": "address" },
      {
        "name": "_tokenizationManager",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "APPROVER_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "DEFAULT_ADMIN_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "SETTER_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "SIGNER_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "SLASHER_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "addCollateralToken",
    "inputs": [
      { "name": "_newToken", "type": "address", "internalType": "address" },
      { "name": "_dataFeed", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "approveOperatorVault",
    "inputs": [
      {
        "name": "_operatorVaultEns",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "depositCollateralAndRegisterVault",
    "inputs": [
      { "name": "_ensName", "type": "string", "internalType": "string" },
      {
        "name": "_paymentToken",
        "type": "address",
        "internalType": "address"
      },
      { "name": "_signature", "type": "bytes", "internalType": "bytes" },
      { "name": "_autoUpdateEnabled", "type": "bool", "internalType": "bool" }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "eip712Domain",
    "inputs": [],
    "outputs": [
      { "name": "fields", "type": "bytes1", "internalType": "bytes1" },
      { "name": "name", "type": "string", "internalType": "string" },
      { "name": "version", "type": "string", "internalType": "string" },
      { "name": "chainId", "type": "uint256", "internalType": "uint256" },
      {
        "name": "verifyingContract",
        "type": "address",
        "internalType": "address"
      },
      { "name": "salt", "type": "bytes32", "internalType": "bytes32" },
      {
        "name": "extensions",
        "type": "uint256[]",
        "internalType": "uint256[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "emergencyWithdrawToken",
    "inputs": [
      { "name": "_token", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "forceUpdateOperatorVault",
    "inputs": [
      {
        "name": "_operatorVaultEns",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getAcceptedTokenOnChain",
    "inputs": [
      {
        "name": "_baseAcceptedToken",
        "type": "address",
        "internalType": "address"
      },
      { "name": "_chainId", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getAcceptedTokens",
    "inputs": [],
    "outputs": [
      { "name": "", "type": "address[]", "internalType": "address[]" }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getAllOperators",
    "inputs": [],
    "outputs": [
      { "name": "", "type": "address[]", "internalType": "address[]" }
    ],
    "stateMutability": "view"
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
    "name": "getDataFeedForToken",
    "inputs": [
      { "name": "_token", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getFiatCollateralRequiredForOperator",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getIsVaultApproved",
    "inputs": [
      { "name": "_operator", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getMaxOpFiatCollateral",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "pure"
  },
  {
    "type": "function",
    "name": "getMinOpFiatCollateral",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "pure"
  },
  {
    "type": "function",
    "name": "getOperatorENSName",
    "inputs": [
      { "name": "_operator", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOperatorFromEns",
    "inputs": [
      { "name": "_ensName", "type": "string", "internalType": "string" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOperatorInfo",
    "inputs": [
      { "name": "_operator", "type": "address", "internalType": "address" }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct RealEstateRegistry.OperatorInfo",
        "components": [
          { "name": "vault", "type": "address", "internalType": "address" },
          { "name": "ensName", "type": "string", "internalType": "string" },
          {
            "name": "stakedCollateralInFiat",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "stakedCollateralInToken",
            "type": "uint256",
            "internalType": "uint256"
          },
          { "name": "token", "type": "address", "internalType": "address" },
          {
            "name": "timestamp",
            "type": "uint256",
            "internalType": "uint256"
          },
          { "name": "isApproved", "type": "bool", "internalType": "bool" }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOperatorVault",
    "inputs": [
      { "name": "_operator", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOperatorVaultImplementation",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRoleAdmin",
    "inputs": [
      { "name": "role", "type": "bytes32", "internalType": "bytes32" }
    ],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getSwapRouter",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "grantRole",
    "inputs": [
      { "name": "role", "type": "bytes32", "internalType": "bytes32" },
      { "name": "account", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "hasRole",
    "inputs": [
      { "name": "role", "type": "bytes32", "internalType": "bytes32" },
      { "name": "account", "type": "address", "internalType": "address" }
    ],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "prepareRegisterVaultHash",
    "inputs": [
      { "name": "_operator", "type": "address", "internalType": "address" },
      { "name": "_ensName", "type": "string", "internalType": "string" }
    ],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "renounceRole",
    "inputs": [
      { "name": "role", "type": "bytes32", "internalType": "bytes32" },
      {
        "name": "callerConfirmation",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "revokeRole",
    "inputs": [
      { "name": "role", "type": "bytes32", "internalType": "bytes32" },
      { "name": "account", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setCollateralRequiredForOperator",
    "inputs": [
      {
        "name": "_newOperatorCollateral",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setSwapRouter",
    "inputs": [
      { "name": "_swapRouter", "type": "address", "internalType": "address" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setTokenForAnotherChain",
    "inputs": [
      {
        "name": "_tokenOnBaseChain",
        "type": "address",
        "internalType": "address"
      },
      { "name": "_chainId", "type": "uint256", "internalType": "uint256" },
      {
        "name": "_tokenOnAnotherChain",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "slashOperatorVault",
    "inputs": [
      { "name": "_ensName", "type": "string", "internalType": "string" }
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
    "name": "updateVOVImplementation",
    "inputs": [
      {
        "name": "_newVerifyingOpVaultImplementation",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "CollateralUpdated",
    "inputs": [
      {
        "name": "newCollateral",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "EIP712DomainChanged",
    "inputs": [],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorVaultApproved",
    "inputs": [
      {
        "name": "approver",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorVaultRegistered",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "vault",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorVaultSlashed",
    "inputs": [
      {
        "name": "ensName",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleAdminChanged",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "previousAdminRole",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "newAdminRole",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleGranted",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "sender",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleRevoked",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "sender",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  { "type": "error", "name": "AccessControlBadConfirmation", "inputs": [] },
  {
    "type": "error",
    "name": "AccessControlUnauthorizedAccount",
    "inputs": [
      { "name": "account", "type": "address", "internalType": "address" },
      { "name": "neededRole", "type": "bytes32", "internalType": "bytes32" }
    ]
  },
  { "type": "error", "name": "ECDSAInvalidSignature", "inputs": [] },
  {
    "type": "error",
    "name": "ECDSAInvalidSignatureLength",
    "inputs": [
      { "name": "length", "type": "uint256", "internalType": "uint256" }
    ]
  },
  {
    "type": "error",
    "name": "ECDSAInvalidSignatureS",
    "inputs": [{ "name": "s", "type": "bytes32", "internalType": "bytes32" }]
  },
  { "type": "error", "name": "InvalidShortString", "inputs": [] },
  {
    "type": "error",
    "name": "RealEstateRegistry__ENSNameAlreadyExist",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__InsufficientCollateral",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__InvalidCollateral",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__InvalidDataFeeds",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__InvalidENSName",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__InvalidSignature",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__InvalidToken",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__NativeNotRequired",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__OperatorAlreadyExist",
    "inputs": []
  },
  {
    "type": "error",
    "name": "RealEstateRegistry__TransferFailed",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SafeERC20FailedOperation",
    "inputs": [
      { "name": "token", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "StringTooLong",
    "inputs": [{ "name": "str", "type": "string", "internalType": "string" }]
  }
]

export default abi;