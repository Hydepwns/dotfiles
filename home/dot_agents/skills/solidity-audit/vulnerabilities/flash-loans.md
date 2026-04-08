---
title: Flash Loan Attack Vectors
impact: CRITICAL
impactDescription: Flash loan exploits enabling price manipulation, governance hijacking, and vault inflation attacks
tags: solidity, flash-loans, price-manipulation, governance
---

# Flash Loan Attack Vectors

## Price manipulation via flash loans

Flash loans provide unlimited capital within a single transaction.
Any pricing mechanism based on current on-chain state is vulnerable.

INCORRECT:

```solidity
function deposit(uint256 amount) external {
    token.transferFrom(msg.sender, address(this), amount);
    // Shares based on current reserves -- manipulable
    uint256 shares = amount * totalShares / token.balanceOf(address(this));
    _mint(msg.sender, shares);
}
```

Attack: flash loan -> donate tokens to vault (inflate balance) -> deposit
(get shares at inflated rate) -> withdraw (drain excess).

CORRECT:

```solidity
function deposit(uint256 amount) external nonReentrant {
    // Use tracked balance, not actual balance
    uint256 shares = amount * totalShares / totalDeposited;
    totalDeposited += amount;
    token.transferFrom(msg.sender, address(this), amount);
    _mint(msg.sender, shares);
}
```

## Governance flash loan attacks

Flash-borrow governance tokens -> vote -> return. One transaction can
hijack governance decisions.

INCORRECT:

```solidity
function propose(bytes calldata action) external {
    require(token.balanceOf(msg.sender) >= proposalThreshold);
    // Attacker flash-borrows enough tokens to exceed threshold
    proposals.push(Proposal(action, block.timestamp));
}

function vote(uint256 proposalId) external {
    // Voting power = current balance -- flash loan exploitable
    uint256 weight = token.balanceOf(msg.sender);
    votes[proposalId] += weight;
}
```

CORRECT:

```solidity
function propose(bytes calldata action) external {
    // Use historical balance (snapshot) -- can't be flash-loaned
    uint256 balance = token.getPastVotes(msg.sender, block.number - 1);
    if (balance < proposalThreshold) revert InsufficientVotingPower();
    proposals.push(Proposal(action, block.timestamp, block.number));
}

function vote(uint256 proposalId) external {
    Proposal storage p = proposals[proposalId];
    // Snapshot at proposal creation block
    uint256 weight = token.getPastVotes(msg.sender, p.snapshotBlock);
    votes[proposalId] += weight;
}
```

## Vault inflation attack (first depositor)

The first depositor can manipulate the share price by donating tokens
after depositing a tiny amount.

INCORRECT:

```solidity
function deposit(uint256 amount) external {
    uint256 shares;
    if (totalSupply() == 0) {
        shares = amount;  // 1:1 for first deposit
    } else {
        shares = amount * totalSupply() / totalAssets();
    }
    _mint(msg.sender, shares);
    asset.transferFrom(msg.sender, address(this), amount);
}
// Attack: deposit 1 wei -> donate 1e18 tokens -> next depositor gets 0 shares
// (due to rounding: their_amount * 1 / 1e18 rounds to 0)
```

CORRECT:

```solidity
function deposit(uint256 amount) external {
    uint256 shares;
    if (totalSupply() == 0) {
        // Mint dead shares to prevent inflation attack
        shares = amount - MINIMUM_SHARES;
        _mint(address(0xdead), MINIMUM_SHARES);  // permanent minimum
    } else {
        shares = amount * totalSupply() / totalAssets();
    }
    if (shares == 0) revert ZeroShares();
    _mint(msg.sender, shares);
    asset.transferFrom(msg.sender, address(this), amount);
}

uint256 constant MINIMUM_SHARES = 1e3;
```

## Defense principles

1. **Never use current token balance for pricing** -- track deposits internally
2. **Use snapshots for governance** -- `ERC20Votes.getPastVotes()`
3. **Protect first depositor** -- dead shares or minimum deposit
4. **Time-delay sensitive operations** -- multi-block commit-reveal
5. **Rate limiting** -- cap deposit/withdrawal size per block
