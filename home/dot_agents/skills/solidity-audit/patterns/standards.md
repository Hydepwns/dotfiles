---
title: Solidity Development Standards
tags: solidity, natspec, errors, events, gas, storage
---

# Solidity Development Standards

## Use custom errors over require strings

Custom errors are cheaper (no string storage) and composable with parameters.

INCORRECT:

```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount, "Insufficient balance");
    require(amount > 0, "Amount must be positive");
    require(!paused, "Contract is paused");
}
```

CORRECT:

```solidity
error InsufficientBalance(address account, uint256 available, uint256 requested);
error ZeroAmount();
error ContractPaused();

function withdraw(uint256 amount) external {
    if (balances[msg.sender] < amount) {
        revert InsufficientBalance(msg.sender, balances[msg.sender], amount);
    }
    if (amount == 0) revert ZeroAmount();
    if (paused) revert ContractPaused();
}
```

## NatSpec on all external/public functions

NatSpec generates documentation and helps auditors understand intent.

INCORRECT:

```solidity
function swap(address tokenIn, uint256 amountIn, uint256 minOut) external returns (uint256) {
    // ...
}
```

CORRECT:

```solidity
/// @notice Swaps `amountIn` of `tokenIn` for the pool's other token.
/// @dev Uses constant-product formula. Reverts if output < minOut.
/// @param tokenIn Address of the input token (must be token0 or token1).
/// @param amountIn Amount of input tokens to swap.
/// @param minOut Minimum acceptable output (slippage protection).
/// @return amountOut The amount of output tokens received.
function swap(
    address tokenIn,
    uint256 amountIn,
    uint256 minOut
) external returns (uint256 amountOut) {
    // ...
}
```

## Emit events for all state changes

Events are the only way to efficiently index on-chain history. Every
meaningful state mutation should emit.

INCORRECT:

```solidity
function transfer(address to, uint256 amount) external {
    balances[msg.sender] -= amount;
    balances[to] += amount;
    // No event -- impossible to track transfers off-chain
}
```

CORRECT:

```solidity
event Transfer(address indexed from, address indexed to, uint256 amount);

function transfer(address to, uint256 amount) external {
    balances[msg.sender] -= amount;
    balances[to] += amount;
    emit Transfer(msg.sender, to, amount);
}
```

## Storage packing

Variables sharing a 32-byte slot save ~20,000 gas per SSTORE. Order
struct fields and state variables by size, smallest first within each slot.

INCORRECT:

```solidity
// 3 storage slots (wasteful)
contract Config {
    bool active;        // slot 0: 1 byte, 31 bytes wasted
    uint256 maxAmount;  // slot 1: 32 bytes
    uint8 decimals;     // slot 2: 1 byte, 31 bytes wasted
    address owner;      // slot 3: 20 bytes
    bool paused;        // slot 4: 1 byte
}
```

CORRECT:

```solidity
// 2 storage slots (packed)
contract Config {
    // slot 0: bool(1) + uint8(1) + bool(1) + address(20) = 23 bytes
    bool active;
    uint8 decimals;
    bool paused;
    address owner;
    // slot 1: uint256(32)
    uint256 maxAmount;
}
```

## Use calldata for read-only external parameters

`calldata` is cheaper than `memory` for external function parameters
that aren't modified.

INCORRECT:

```solidity
function processOrders(Order[] memory orders) external {
    for (uint256 i = 0; i < orders.length; i++) {
        _process(orders[i]);
    }
}
```

CORRECT:

```solidity
function processOrders(Order[] calldata orders) external {
    for (uint256 i = 0; i < orders.length; i++) {
        _process(orders[i]);
    }
}
```

## Upgradeable storage layout

For upgradeable contracts (UUPS, transparent proxy), never reorder or
remove storage variables. Use storage gaps for future slots.

INCORRECT:

```solidity
// V1
contract TokenV1 {
    address owner;
    uint256 totalSupply;
    mapping(address => uint256) balances;
}

// V2 -- BROKEN: inserted variable shifts storage layout
contract TokenV2 {
    address owner;
    string name;           // shifts totalSupply to wrong slot
    uint256 totalSupply;
    mapping(address => uint256) balances;
}
```

CORRECT:

```solidity
// V1
contract TokenV1 {
    address owner;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    uint256[47] private __gap;  // reserve slots for future use
}

// V2 -- append new variables, shrink gap
contract TokenV2 {
    address owner;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    string name;                // uses first gap slot
    uint256[46] private __gap; // gap shrinks by 1
}
```
