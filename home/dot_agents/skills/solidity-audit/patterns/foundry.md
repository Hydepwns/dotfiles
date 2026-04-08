---
title: Foundry Testing Patterns
impact: HIGH
impactDescription: Fuzz testing, invariant testing, fork testing, and essential cheatcodes for security verification
tags: solidity, foundry, forge, fuzz, invariant, fork
---

# Foundry Testing Patterns

## Test organization

Mirror the source tree. One test file per contract. Use `setUp()` for
shared state.

```
src/
  Token.sol
  Vault.sol
test/
  Token.t.sol
  Vault.t.sol
  invariant/
    TokenInvariant.t.sol
  fork/
    VaultFork.t.sol
```

## Fuzz testing over unit tests

Foundry's fuzzer finds edge cases that hand-picked values miss. Prefer
fuzz tests for any function with numeric inputs.

INCORRECT:

```solidity
function test_deposit() public {
    vault.deposit(1 ether);
    assertEq(vault.balanceOf(address(this)), 1 ether);
}
```

CORRECT:

```solidity
function test_deposit(uint256 amount) public {
    amount = bound(amount, 1, type(uint128).max);
    deal(address(token), address(this), amount);
    token.approve(address(vault), amount);

    vault.deposit(amount);

    assertEq(vault.balanceOf(address(this)), amount);
}
```

## Bound inputs, don't assume

Use `bound()` to constrain fuzz inputs to valid ranges. Use `vm.assume()`
sparingly -- it discards runs, slowing the fuzzer.

INCORRECT:

```solidity
function test_transfer(uint256 amount) public {
    vm.assume(amount > 0 && amount < 1000 ether);
    // assume discards most inputs -- fuzzer wastes cycles
}
```

CORRECT:

```solidity
function test_transfer(uint256 amount) public {
    amount = bound(amount, 1, 999 ether);
    // Every fuzz run is valid -- no wasted cycles
}
```

## Invariant testing (stateful fuzzing)

Invariant tests call random sequences of functions and verify properties
hold after each call. This catches state-dependent bugs that individual
fuzz tests miss.

```solidity
// test/invariant/TokenInvariant.t.sol
contract TokenInvariant is Test {
    Token token;
    Handler handler;

    function setUp() public {
        token = new Token();
        handler = new Handler(token);

        // Tell the fuzzer to only call handler functions
        targetContract(address(handler));
    }

    /// @dev Total supply must equal sum of all balances
    function invariant_supplyEqualsBalances() public view {
        assertEq(
            token.totalSupply(),
            handler.ghost_totalDeposited() - handler.ghost_totalWithdrawn()
        );
    }

    /// @dev No individual balance exceeds total supply
    function invariant_noBalanceExceedsSupply() public view {
        for (uint256 i = 0; i < handler.actorCount(); i++) {
            assertLe(
                token.balanceOf(handler.actors(i)),
                token.totalSupply()
            );
        }
    }
}

// Handler wraps the target with ghost variables for tracking
contract Handler is Test {
    Token token;
    uint256 public ghost_totalDeposited;
    uint256 public ghost_totalWithdrawn;
    address[] public actors;

    function deposit(uint256 amount) public {
        amount = bound(amount, 1, type(uint128).max);
        // ... setup and call
        ghost_totalDeposited += amount;
    }
}
```

## Fork testing

Test against real mainnet state. Use `vm.createFork()` for multi-chain
and `vm.rollFork()` to test at specific blocks.

```solidity
contract VaultForkTest is Test {
    uint256 mainnetFork;

    function setUp() public {
        mainnetFork = vm.createFork(vm.envString("ETH_RPC_URL"));
        vm.selectFork(mainnetFork);
    }

    function test_swapOnUniswap() public {
        // Real Uniswap contracts, real liquidity
        ISwapRouter router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        // ...
    }

    function test_atSpecificBlock() public {
        vm.rollFork(18_000_000);
        // Test against state at block 18M
    }
}
```

## Essential cheatcodes

```solidity
// Impersonate an address
vm.prank(alice);
token.transfer(bob, 100);

// Persistent impersonation
vm.startPrank(alice);
// ... multiple calls as alice
vm.stopPrank();

// Expect a revert
vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, alice, 0, 100));
vault.withdraw(100);

// Expect an event
vm.expectEmit(true, true, false, true);
emit Transfer(alice, bob, 100);
token.transfer(bob, 100);

// Warp time
vm.warp(block.timestamp + 1 days);

// Set block number
vm.roll(block.number + 100);

// Give ETH
vm.deal(alice, 10 ether);

// Give ERC20
deal(address(token), alice, 1000e18);

// Snapshot and revert state
uint256 snapshot = vm.snapshot();
// ... make changes
vm.revertTo(snapshot);

// Label addresses for trace readability
vm.label(alice, "Alice");
vm.label(address(vault), "Vault");
```
