---
title: Unconstrained Computation Patterns
impact: CRITICAL
impactDescription: Misusing unconstrained functions lets provers forge arbitrary values, breaking proof soundness.
tags: noir, unconstrained, oracle, brillig, optimization
---

# Unconstrained Computation Patterns

## The compute-then-verify pattern

The core ZK optimization: compute the answer cheaply (unconstrained),
then verify it cheaply (constrained). The prover does the hard work,
the circuit only checks.

INCORRECT:

```noir
// O(n^2) constraints for in-circuit sorting
fn find_median(values: [Field; 100]) -> Field {
    let mut sorted = values;
    for i in 0..99 {
        for j in 0..(99 - i) {
            let a = sorted[j] as u64;
            let b = sorted[j + 1] as u64;
            if a > b {
                let tmp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = tmp;
            }
        }
    }
    sorted[50]
}
```

CORRECT:

```noir
unconstrained fn sort_hint(values: [Field; 100]) -> [Field; 100] {
    // Brillig: no constraints, runs in prover only
    let mut sorted = values;
    // Any sorting algorithm works here
    sorted
}

fn find_median(values: [Field; 100]) -> Field {
    let sorted = sort_hint(values);
    // O(n) verification: check sorted order
    for i in 0..99 {
        assert(
            (sorted[i] as u64) <= (sorted[i + 1] as u64),
            "not sorted"
        );
    }
    // Verify permutation (same elements, just reordered)
    // ... (multiset equality check)
    sorted[50]
}
```

## Oracle calls for external data

Oracles let circuits access external data (blockchain state, timestamps,
randomness). They execute outside the circuit via `#[oracle]`.

INCORRECT:

```noir
#[oracle(get_block_timestamp)]
unconstrained fn get_timestamp() -> u64 {}

fn main(deadline: pub u64) {
    let now = get_timestamp();
    // BUG: prover controls the oracle -- they can fake the timestamp
    assert(now < deadline, "expired");
}
```

CORRECT:

```noir
#[oracle(get_block_timestamp)]
unconstrained fn get_timestamp() -> u64 {}

fn main(
    deadline: pub u64,
    block_hash: pub Field,   // anchor to a specific block
    timestamp: pub u64,       // timestamp is PUBLIC, verified on-chain
) {
    // The verifier contract checks timestamp against block_hash on-chain
    // The circuit only checks the deadline logic
    assert(timestamp < deadline, "expired");
}
```

## ACIR vs Brillig compilation

Constrained code compiles to ACIR (Abstract Circuit IR) -- generates
constraints. Unconstrained code compiles to Brillig -- runs as a VM
program in the prover with no constraints.

**When to use unconstrained:**
- Expensive computation with cheap verification (sorting, searching, optimization)
- Data formatting / string manipulation
- Complex conditional logic that would branch-explode in constraints
- Anything where you can verify the result more cheaply than computing it

**When NOT to use unconstrained:**
- Simple arithmetic (Field ops are already cheap)
- Hash computations (must be constrained for soundness)
- Anything where verification is as expensive as computation

INCORRECT:

```noir
// Unconstrained for a simple hash -- defeats the purpose
unconstrained fn hash_unconstrained(a: Field, b: Field) -> Field {
    std::hash::poseidon::bn254::hash_2([a, b])
}

fn main(a: Field, b: Field, expected: pub Field) {
    let h = hash_unconstrained(a, b);
    assert(h == expected);
    // BUG: the hash was computed unconstrained -- prover can return
    // any value that equals expected, without actually hashing
}
```

CORRECT:

```noir
fn main(a: Field, b: Field, expected: pub Field) {
    // Hash must be constrained -- it IS the verification
    let h = std::hash::poseidon::bn254::hash_2([a, b]);
    assert(h == expected, "hash mismatch");
}
```

## Unconstrained helper patterns

Common patterns for safe unconstrained usage:

```noir
// Pattern 1: Division hint
unconstrained fn div_hint(a: u64, b: u64) -> (u64, u64) {
    (a / b, a % b)
}

fn safe_div(a: Field, b: Field) -> (Field, Field) {
    let (q, r) = div_hint(a as u64, b as u64);
    let quotient = q as Field;
    let remainder = r as Field;
    // Verify: a == b * q + r and r < b
    assert(a == b * quotient + remainder, "division check failed");
    assert((r as u64) < (b as u64), "remainder >= divisor");
    (quotient, remainder)
}

// Pattern 2: Array search hint
unconstrained fn find_index_hint(arr: [Field; 100], target: Field) -> u32 {
    let mut idx = 0;
    for i in 0..100 {
        if arr[i] == target {
            idx = i;
        }
    }
    idx
}

fn find_verified(arr: [Field; 100], target: Field) -> u32 {
    let idx = find_index_hint(arr, target);
    // One constraint instead of 100
    assert(arr[idx] == target, "element not found at index");
    idx
}
```
