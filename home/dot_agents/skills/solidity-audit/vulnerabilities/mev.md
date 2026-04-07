---
title: MEV & Frontrunning Protection
tags: solidity, mev, frontrunning, sandwich, commit-reveal
---

# MEV & Frontrunning Protection

## Sandwich attacks on swaps

Attackers see pending swaps in the mempool, frontrun with a buy (raising
the price), let the victim swap at the worse price, then backrun with a sell.

INCORRECT:

```solidity
function swap(address tokenIn, uint256 amountIn) external {
    // No slippage protection -- sandwich extracts maximum value
    uint256 amountOut = router.swapExactTokensForTokens(
        amountIn,
        0,  // minAmountOut = 0, accepting ANY output
        path,
        msg.sender,
        block.timestamp
    );
}
```

CORRECT:

```solidity
function swap(
    address tokenIn,
    uint256 amountIn,
    uint256 minAmountOut,     // user-specified slippage bound
    uint256 deadline          // transaction expiry
) external {
    if (block.timestamp > deadline) revert Expired();

    uint256 amountOut = router.swapExactTokensForTokens(
        amountIn,
        minAmountOut,  // revert if sandwich pushes price too far
        path,
        msg.sender,
        deadline
    );
}
```

## Commit-reveal for sensitive operations

Two-phase submission prevents frontrunning by hiding the action until
it's committed.

INCORRECT:

```solidity
// NFT auction: highest bid visible in mempool before inclusion
function bid(uint256 amount) external {
    require(amount > highestBid, "too low");
    // Attacker sees this tx, bids amount + 1
    highestBid = amount;
    highestBidder = msg.sender;
}
```

CORRECT:

```solidity
// Phase 1: commit (hash of bid, hidden)
mapping(address => bytes32) public commitments;
mapping(address => uint256) public commitBlock;

function commit(bytes32 hash) external {
    commitments[msg.sender] = hash;
    commitBlock[msg.sender] = block.number;
}

// Phase 2: reveal (after commit window, e.g., 10 blocks)
function reveal(uint256 amount, bytes32 salt) external {
    require(block.number > commitBlock[msg.sender] + COMMIT_WINDOW, "too early");
    require(block.number < commitBlock[msg.sender] + REVEAL_WINDOW, "too late");

    bytes32 expected = keccak256(abi.encodePacked(msg.sender, amount, salt));
    if (commitments[msg.sender] != expected) revert InvalidReveal();

    if (amount > highestBid) {
        highestBid = amount;
        highestBidder = msg.sender;
    }
}
```

## Transaction ordering dependence

Functions whose outcome depends on execution order are MEV-extractable.

INCORRECT:

```solidity
// First caller gets the reward -- miners/searchers will always win
function claimReward() external {
    require(!claimed, "already claimed");
    claimed = true;
    token.transfer(msg.sender, reward);
}
```

CORRECT:

```solidity
// Deterministic recipient -- order doesn't matter
function claimReward(bytes32[] calldata merkleProof) external {
    if (hasClaimed[msg.sender]) revert AlreadyClaimed();

    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
        revert InvalidProof();
    }

    hasClaimed[msg.sender] = true;
    token.transfer(msg.sender, rewards[msg.sender]);
}
```

## MEV protection strategies

| Strategy | Protection | Tradeoff |
|----------|-----------|----------|
| Slippage bounds | Sandwich | User must set appropriate bounds |
| Commit-reveal | Frontrunning | 2-tx UX, reveal window timing |
| Private mempool (Flashbots) | All MEV | Centralization, censorship risk |
| Batch auctions | Frontrunning | Delayed execution, complexity |
| Time-weighted operations | Flash loans | Slower price discovery |
| MEV-Share / OFA | Sandwich | Requires MEV-aware infrastructure |

## Deadline parameters

Always include a deadline for time-sensitive operations. Without one,
a transaction can sit in the mempool and execute at an unfavorable time.

```solidity
function swap(uint256 amountIn, uint256 minOut, uint256 deadline) external {
    if (block.timestamp > deadline) revert TransactionExpired();
    // ... perform swap
}
```
