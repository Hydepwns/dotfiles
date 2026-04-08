---
title: Oracle Manipulation
impact: CRITICAL
impactDescription: Oracle exploitation via spot price manipulation, stale Chainlink data, and TWAP weaknesses
tags: solidity, oracle, chainlink, twap, price-feed
---

# Oracle Manipulation

## Spot price manipulation

Using a DEX's current reserves as a price oracle is trivially exploitable
with flash loans.

INCORRECT:

```solidity
function getPrice() public view returns (uint256) {
    // Uniswap V2 spot price -- manipulable in a single transaction
    (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
    return uint256(reserve1) * 1e18 / uint256(reserve0);
}

function liquidate(address user) external {
    uint256 price = getPrice();
    uint256 collateralValue = collateral[user] * price / 1e18;
    require(collateralValue < debt[user], "not liquidatable");
    // Attacker: flash loan -> manipulate reserves -> liquidate -> repay
}
```

CORRECT:

```solidity
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

function getPrice() public view returns (uint256) {
    (
        uint80 roundId,
        int256 answer,
        ,
        uint256 updatedAt,
        uint80 answeredInRound
    ) = priceFeed.latestRoundData();

    // Validate the response
    if (answer <= 0) revert InvalidPrice();
    if (updatedAt == 0) revert StaleRound();
    if (block.timestamp - updatedAt > STALENESS_THRESHOLD) revert StalePrice();
    if (answeredInRound < roundId) revert StaleRound();

    return uint256(answer);
}
```

## Chainlink staleness checks

Chainlink feeds can go stale during network congestion or oracle outages.
Always validate freshness.

INCORRECT:

```solidity
function getPrice() public view returns (uint256) {
    (, int256 answer,,,) = priceFeed.latestRoundData();
    return uint256(answer);
    // No staleness check -- could use hours-old data during volatility
}
```

CORRECT:

```solidity
uint256 constant STALENESS_THRESHOLD = 3600; // 1 hour for ETH/USD

function getPrice() public view returns (uint256) {
    (
        uint80 roundId,
        int256 answer,
        ,
        uint256 updatedAt,
        uint80 answeredInRound
    ) = priceFeed.latestRoundData();

    if (answer <= 0) revert InvalidPrice();
    if (block.timestamp - updatedAt > STALENESS_THRESHOLD) revert StalePrice();
    if (answeredInRound < roundId) revert StaleRound();

    return uint256(answer);
}
```

## TWAP oracles

Time-weighted average prices are more manipulation-resistant than spot
prices but still have tradeoffs.

```solidity
// Uniswap V3 TWAP -- resistant to single-block manipulation
function getTWAP(address pool, uint32 twapInterval) public view returns (int24) {
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = twapInterval;  // e.g., 1800 for 30-minute TWAP
    secondsAgos[1] = 0;             // now

    (int56[] memory tickCumulatives,) = IUniswapV3Pool(pool).observe(secondsAgos);

    int24 avgTick = int24(
        (tickCumulatives[1] - tickCumulatives[0]) / int56(int32(twapInterval))
    );
    return avgTick;
}
```

**TWAP considerations:**
- Longer window = more manipulation-resistant but slower to reflect real price changes
- Short windows (< 10 minutes) are still vulnerable to multi-block manipulation
- Low-liquidity pools are cheaper to manipulate regardless of window length
- Consider fallback to Chainlink if TWAP deviates significantly

## Multi-oracle pattern

For critical price dependencies, use multiple independent oracles with
deviation checks.

```solidity
function getPrice() public view returns (uint256) {
    uint256 chainlinkPrice = getChainlinkPrice();
    uint256 twapPrice = getTWAPPrice();

    // Check deviation between oracles
    uint256 deviation = chainlinkPrice > twapPrice
        ? (chainlinkPrice - twapPrice) * 1e18 / chainlinkPrice
        : (twapPrice - chainlinkPrice) * 1e18 / twapPrice;

    if (deviation > MAX_DEVIATION) revert OracleDeviation(chainlinkPrice, twapPrice);

    // Use the more conservative price (lower for collateral, higher for debt)
    return chainlinkPrice < twapPrice ? chainlinkPrice : twapPrice;
}
```
