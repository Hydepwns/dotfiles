---
title: Noir Language Patterns
impact: HIGH
impactDescription: safe circuits, correct constraints, idiomatic Noir
tags: noir, zk, circuits, field, constraints, nargo
---

# Noir Language Patterns

## Use Field for arithmetic, integers for bit-width guarantees

`Field` is the native type -- zero-cost in constraints. Integer types (`u8`,
`u32`, etc.) add range-check constraints. Only use integers when you need
bounded values.

INCORRECT:

```noir
fn compute_hash(a: u64, b: u64) -> u64 {
    // u64 adds unnecessary range checks on every operation
    let sum = a + b;
    sum * 2
}
```

CORRECT:

```noir
fn compute_hash(a: Field, b: Field) -> Field {
    // Field arithmetic is native -- no extra constraints
    let sum = a + b;
    sum * 2
}

fn bounded_index(i: u32, len: u32) -> u32 {
    // u32 is correct here -- we need the range guarantee
    assert(i < len);
    i
}
```

## Constrained by default, unconstrained explicitly

All functions generate constraints unless marked `unconstrained`. Use
unconstrained for expensive computations that can be verified cheaply.

INCORRECT:

```noir
// Expensive: sorting generates O(n^2) constraints
fn sort_and_verify(arr: [Field; 100]) -> [Field; 100] {
    let mut sorted = arr;
    for i in 0..99 {
        for j in 0..(99 - i) {
            if sorted[j] as u64 > sorted[j + 1] as u64 {
                let tmp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = tmp;
            }
        }
    }
    sorted
}
```

CORRECT:

```noir
// Cheap: sort unconstrained, verify constrained
unconstrained fn sort_hint(arr: [Field; 100]) -> [Field; 100] {
    // Brillig execution -- no constraints generated
    let mut sorted = arr;
    // ... sort however you want
    sorted
}

fn sort_and_verify(arr: [Field; 100]) -> [Field; 100] {
    let sorted = sort_hint(arr);
    // Verify in O(n) constraints: sorted is a permutation and ordered
    for i in 0..99 {
        assert(sorted[i] as u64 <= sorted[i + 1] as u64);
    }
    // Also verify it's a permutation of the original (check multiset equality)
    sorted
}
```

## Never trust unconstrained return values

Unconstrained functions run outside the circuit. A malicious prover can
return anything. Always constrain the result.

INCORRECT:

```noir
unconstrained fn find_sqrt(x: Field) -> Field {
    // ... compute square root
    result
}

fn main(x: Field) {
    let root = find_sqrt(x);
    // BUG: root is unchecked -- prover can return any value
    // and the proof will still verify
}
```

CORRECT:

```noir
unconstrained fn find_sqrt_hint(x: Field) -> Field {
    // ... compute square root
    result
}

fn main(x: Field) {
    let root = find_sqrt_hint(x);
    // Constrain: root * root == x
    assert(root * root == x);
}
```

## Use assert with descriptive messages

Assertions are the primary way to express constraints. Always include
a message for debugging failed proofs.

INCORRECT:

```noir
fn transfer(balance: Field, amount: Field) {
    assert(balance as u64 >= amount as u64);
    assert(amount as u64 > 0);
}
```

CORRECT:

```noir
fn transfer(balance: Field, amount: Field) {
    assert(balance as u64 >= amount as u64, "insufficient balance");
    assert(amount as u64 > 0, "amount must be positive");
}
```

## Struct patterns and decomposition

Use structs for domain modeling. Destructure in function signatures
for clarity.

INCORRECT:

```noir
fn process(data: [Field; 4]) -> Field {
    // Positional access is fragile and unclear
    data[0] + data[1] * data[2] - data[3]
}
```

CORRECT:

```noir
struct Transfer {
    sender: Field,
    receiver: Field,
    amount: Field,
    nonce: Field,
}

fn process(transfer: Transfer) -> Field {
    transfer.sender + transfer.receiver * transfer.amount - transfer.nonce
}
```

## Test with #[test] and should_fail_with

Use nargo's built-in test framework. Tests generate real constraints
by default.

INCORRECT:

```noir
// No tests, or tests in a separate unlinked file
fn main(x: Field) {
    assert(x != 0, "x must be nonzero");
}
```

CORRECT:

```noir
fn check_nonzero(x: Field) {
    assert(x != 0, "x must be nonzero");
}

#[test]
fn test_nonzero_passes() {
    check_nonzero(42);
}

#[test(should_fail_with = "x must be nonzero")]
fn test_zero_fails() {
    check_nonzero(0);
}
```

## Use generics for reusable circuit components

Noir supports generics with trait bounds. Use them for array sizes
and reusable verification logic.

INCORRECT:

```noir
fn hash_4(inputs: [Field; 4]) -> Field {
    // Hardcoded size -- need a new function for every array length
    std::hash::poseidon::bn254::hash_4(inputs)
}
```

CORRECT:

```noir
fn hash_inputs<let N: u32>(inputs: [Field; N]) -> Field {
    std::hash::poseidon::bn254::hash(inputs)
}
```

## Module organization follows Rust conventions

Use `mod` and `use` for organization. `Nargo.toml` declares dependencies.

INCORRECT:

```noir
// Everything in main.nr -- 500 lines, no structure
fn main() { /* ... */ }
fn helper1() { /* ... */ }
fn helper2() { /* ... */ }
struct BigStruct { /* ... */ }
```

CORRECT:

```
// src/main.nr
mod types;
mod utils;

use crate::types::Transfer;
use crate::utils::verify_signature;

fn main(transfer: Transfer, signature: [u8; 64]) {
    verify_signature(transfer, signature);
}

// src/types.nr
struct Transfer {
    sender: Field,
    receiver: Field,
    amount: Field,
}

// src/utils.nr
use crate::types::Transfer;

fn verify_signature(transfer: Transfer, signature: [u8; 64]) {
    // ...
}
```

## Avoid unnecessary type conversions

Casting between Field and integer types adds constraints. Minimize
conversions by choosing the right type upfront.

INCORRECT:

```noir
fn compare(a: Field, b: Field) -> bool {
    // Each cast adds range-check constraints
    let a_int = a as u64;
    let b_int = b as u64;
    let result = a_int > b_int;
    let back = result as Field;  // unnecessary conversion back
    back == 1
}
```

CORRECT:

```noir
fn compare(a: Field, b: Field) -> bool {
    // Cast once, compare directly
    (a as u64) > (b as u64)
}
```
