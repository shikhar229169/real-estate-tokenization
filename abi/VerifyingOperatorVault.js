const abi = [
  { "type": "constructor", "inputs": [], "stateMutability": "nonpayable" },
  {
    "type": "function",
    "name": "DEFAULT_ADMIN_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "UPGRADER_ROLE",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "UPGRADE_INTERFACE_VERSION",
    "inputs": [],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "addNewTokenizedRealEstate",
    "inputs": [
      {
        "name": "_tokenizedRealEstate",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "claimRewardFromStaking",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getIsSlashed",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getPriceFromTokenToAnotherToken",
    "inputs": [
      { "name": "_tokenA", "type": "address", "internalType": "address" },
      { "name": "_tokenB", "type": "address", "internalType": "address" },
      {
        "name": "_tokenAmountA",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRealEstateRegistry",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRewards",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
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
    "name": "initialize",
    "inputs": [
      { "name": "_operator", "type": "address", "internalType": "address" },
      { "name": "_registry", "type": "address", "internalType": "address" },
      { "name": "_token", "type": "address", "internalType": "address" },
      {
        "name": "_isAutoUpdateEnabled",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "isAutoUpdateEnabled",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "proxiableUUID",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bytes32", "internalType": "bytes32" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "receiveRewards",
    "inputs": [
      {
        "name": "_rewardToken",
        "type": "address",
        "internalType": "address"
      },
      { "name": "_amount", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [
      {
        "name": "utilizedAmount",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "nonpayable"
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
    "name": "setMaxSlippage",
    "inputs": [
      { "name": "_newSlippage", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setStakeDelay",
    "inputs": [
      {
        "name": "_newStakeDelay",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "slashVault",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "stakeCollateral",
    "inputs": [
      { "name": "_amount", "type": "uint256", "internalType": "uint256" }
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
    "name": "toggleAutoUpdate",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "unlockPendingDeposits",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "upgradeToAndCall",
    "inputs": [
      {
        "name": "newImplementation",
        "type": "address",
        "internalType": "address"
      },
      { "name": "data", "type": "bytes", "internalType": "bytes" }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "withdrawFromPending",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "withdrawStake",
    "inputs": [
      { "name": "_amount", "type": "uint256", "internalType": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "AutoUpdateToggled",
    "inputs": [
      {
        "name": "isEnabled",
        "type": "bool",
        "indexed": false,
        "internalType": "bool"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "CollateralStakedInPending",
    "inputs": [
      {
        "name": "_amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "_inclusionTimestamp",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Initialized",
    "inputs": [
      {
        "name": "version",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "PendingStakeConsolidated",
    "inputs": [
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RewardClaimed",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
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
  {
    "type": "event",
    "name": "SlippageUpdated",
    "inputs": [
      {
        "name": "newSlippage",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "StakeDelayUpdated",
    "inputs": [
      {
        "name": "newStakedDelay",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "StakeWithdrawn",
    "inputs": [
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "TokenizedRealEstateAdded",
    "inputs": [
      {
        "name": "tokenizedRealEstate",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Upgraded",
    "inputs": [
      {
        "name": "implementation",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "WithdrawPending",
    "inputs": [
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "deadline",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
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
  {
    "type": "error",
    "name": "AddressEmptyCode",
    "inputs": [
      { "name": "target", "type": "address", "internalType": "address" }
    ]
  },
  {
    "type": "error",
    "name": "ERC1967InvalidImplementation",
    "inputs": [
      {
        "name": "implementation",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  { "type": "error", "name": "ERC1967NonPayable", "inputs": [] },
  { "type": "error", "name": "FailedCall", "inputs": [] },
  { "type": "error", "name": "InvalidInitialization", "inputs": [] },
  { "type": "error", "name": "NotInitializing", "inputs": [] },
  {
    "type": "error",
    "name": "SafeERC20FailedOperation",
    "inputs": [
      { "name": "token", "type": "address", "internalType": "address" }
    ]
  },
  { "type": "error", "name": "UUPSUnauthorizedCallContext", "inputs": [] },
  {
    "type": "error",
    "name": "UUPSUnsupportedProxiableUUID",
    "inputs": [
      { "name": "slot", "type": "bytes32", "internalType": "bytes32" }
    ]
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__AutoUpdateEnabled",
    "inputs": []
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__IncorrectSlippage",
    "inputs": []
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__InvalidImplementation",
    "inputs": []
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__InvalidToken",
    "inputs": []
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__NotAuthorized",
    "inputs": []
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__PendingDepositsNotUnlocked",
    "inputs": []
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__VaultNotEnabled",
    "inputs": []
  },
  {
    "type": "error",
    "name": "VerifyingOperatorVault__WithdrawDeadlineNotReached",
    "inputs": []
  }
]

export default abi;