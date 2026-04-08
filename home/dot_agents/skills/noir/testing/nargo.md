---
title: Testing with Nargo
impact: HIGH
impactDescription: Incomplete circuit testing misses constraint bugs that only surface during real proof generation.
tags: noir, nargo, testing, proving, execution
---

# Testing with Nargo

## Tests generate real constraints

Unlike unit tests in traditional languages, Noir tests with `#[test]`
generate actual constraints. A passing test means the proof would verify.

```noir
#[test]
fn test_hash_commitment() {
    let secret = 42;
    let commitment = std::hash::poseidon::bn254::hash_1([secret]);
    // This test proves the hash relationship holds in the circuit
    assert(commitment != 0);
}
```

## Running tests

```bash
# Run all tests
nargo test

# Run specific test
nargo test --test-name test_hash_commitment

# Run tests matching a pattern
nargo test --test-name test_transfer

# Show constraint count (useful for optimization)
nargo info
```

## Test organization

Keep tests close to the code they verify. Use `should_fail_with` for
negative tests.

INCORRECT:

```noir
// Tests scattered across files with no naming convention
#[test]
fn t1() { /* ... */ }

#[test]
fn test() { /* ... */ }
```

CORRECT:

```noir
// In the same file as the function being tested
fn verify_age(age: Field, min_age: u64) {
    let a = age as u64;
    assert(a >= min_age, "underage");
    assert(a <= 150, "invalid age");
}

#[test]
fn test_verify_age_valid() {
    verify_age(25, 18);
}

#[test]
fn test_verify_age_boundary() {
    verify_age(18, 18);  // exact minimum
}

#[test(should_fail_with = "underage")]
fn test_verify_age_too_young() {
    verify_age(17, 18);
}

#[test(should_fail_with = "invalid age")]
fn test_verify_age_too_old() {
    verify_age(151, 18);
}
```

## Testing unconstrained functions

Unconstrained functions can be tested directly, but remember: passing
unconstrained tests don't prove circuit correctness.

```noir
unconstrained fn sort_hint(arr: [Field; 4]) -> [Field; 4] {
    let mut sorted = arr;
    // bubble sort for simplicity
    for i in 0..3 {
        for j in 0..(3 - i) {
            if (sorted[j] as u64) > (sorted[j + 1] as u64) {
                let tmp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = tmp;
            }
        }
    }
    sorted
}

// Test the hint itself
#[test]
fn test_sort_hint() {
    let result = sort_hint([3, 1, 4, 2]);
    assert(result == [1, 2, 3, 4]);
}

// Test the FULL constrained pipeline (hint + verification)
#[test]
fn test_sort_verified() {
    let input = [3, 1, 4, 2];
    let sorted = sort_hint(input);
    // Verify sorted order (this is what the circuit actually proves)
    for i in 0..3 {
        assert((sorted[i] as u64) <= (sorted[i + 1] as u64));
    }
}
```

## Testing with Prover.toml

For integration tests that simulate real proving, use `Prover.toml`:

```toml
# Prover.toml -- test inputs for `nargo prove`
x = "42"
y = "7"
expected = "294"
```

```noir
// src/main.nr
fn main(x: Field, y: Field, expected: pub Field) {
    assert(x * y == expected, "multiplication check failed");
}
```

```bash
# Generate a proof with test inputs
nargo prove

# Verify the proof
nargo verify
```

## Constraint counting for optimization

Use `nargo info` to track constraint counts during development:

```bash
$ nargo info
+---------+------------------------+--------------+----------------------+
| Package | Expression Width       | ACIR Opcodes | Backend Circuit Size |
+---------+------------------------+--------------+----------------------+
| my_app  | Bounded { width: 4 }   | 152          | 1,204               |
+---------+------------------------+--------------+----------------------+
```

Track this across changes. A sudden jump in circuit size usually means
an operation that should be unconstrained is generating constraints.
