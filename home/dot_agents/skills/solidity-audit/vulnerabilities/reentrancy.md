---
title: Reentrancy Vulnerabilities
impact: CRITICAL
impactDescription: Classic, cross-function, and read-only reentrancy patterns with CEI and guard defenses
tags: solidity, reentrancy, CEI, security
---

# Reentrancy Vulnerabilities

## Classic reentrancy (checks-effects-interactions violation)

External calls before state updates let attackers re-enter and repeat
the operation against stale state.

INCORRECT:

```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount, "insufficient");

    // INTERACTIONS before EFFECTS -- attacker re-enters here
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);

    // State updated after the call -- too late
    balances[msg.sender] -= amount;
}
```

CORRECT:

```solidity
function withdraw(uint256 amount) external {
    // CHECKS
    if (balances[msg.sender] < amount) revert InsufficientBalance();

    // EFFECTS first
    balances[msg.sender] -= amount;

    // INTERACTIONS last
    (bool success,) = msg.sender.call{value: amount}("");
    if (!success) revert TransferFailed();
}
```

## Cross-function reentrancy

Attacker re-enters a different function that reads the stale state.
CEI on a single function isn't enough if other functions share state.

INCORRECT:

```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount;
}

// Attacker re-enters here during withdraw's external call
function transfer(address to, uint256 amount) external {
    require(balances[msg.sender] >= amount);  // stale balance!
    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

CORRECT:

```solidity
// Use a reentrancy guard for all functions sharing state
modifier nonReentrant() {
    require(!locked, "reentrant");
    locked = true;
    _;
    locked = false;
}

function withdraw(uint256 amount) external nonReentrant {
    if (balances[msg.sender] < amount) revert InsufficientBalance();
    balances[msg.sender] -= amount;
    (bool success,) = msg.sender.call{value: amount}("");
    if (!success) revert TransferFailed();
}

function transfer(address to, uint256 amount) external nonReentrant {
    if (balances[msg.sender] < amount) revert InsufficientBalance();
    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

## Read-only reentrancy

Attacker re-enters a view function during a state transition. The view
returns stale data that other protocols rely on for pricing.

INCORRECT:

```solidity
// Vulnerable: getPrice reads pool state that's mid-update
function getPrice() public view returns (uint256) {
    return totalAssets() * 1e18 / totalSupply();
}

function withdraw(uint256 shares) external {
    uint256 assets = shares * totalAssets() / totalSupply();
    _burn(msg.sender, shares);

    // External call while totalSupply is reduced but assets aren't yet
    // Another protocol calling getPrice() sees inflated price
    (bool success,) = msg.sender.call{value: assets}("");
    require(success);

    // Assets reduced after the call
    totalAssetsStored -= assets;
}
```

CORRECT:

```solidity
function withdraw(uint256 shares) external nonReentrant {
    uint256 assets = shares * totalAssets() / totalSupply();
    // Update ALL state before external call
    _burn(msg.sender, shares);
    totalAssetsStored -= assets;

    (bool success,) = msg.sender.call{value: assets}("");
    if (!success) revert TransferFailed();
}

// Also protect view functions used by external protocols
function getPrice() public view returns (uint256) {
    // Consider: use a cached price that updates atomically
    // or document that this should not be called mid-transaction
    return totalAssetsStored * 1e18 / totalSupply();
}
```

## Defense layers

1. **CEI pattern**: Always update state before external calls
2. **Reentrancy guard**: `nonReentrant` modifier on all state-changing functions
3. **Pull over push**: Let users withdraw instead of pushing funds to them
4. **OpenZeppelin ReentrancyGuard**: Battle-tested implementation
