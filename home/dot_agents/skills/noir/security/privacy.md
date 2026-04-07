---
title: Privacy & Information Leakage
tags: noir, privacy, public-inputs, leakage, nullifiers
---

# Privacy & Information Leakage

## Public inputs leak information

Every `pub` parameter is visible to the verifier and anyone observing the
proof. Minimize public surface area.

INCORRECT:

```noir
fn main(
    sender: pub Field,      // leaks who is sending
    receiver: pub Field,    // leaks who is receiving
    amount: pub u64,        // leaks the amount
    nonce: Field,
) {
    // All transaction details are public -- no privacy
    assert(amount > 0, "zero amount");
}
```

CORRECT:

```noir
fn main(
    commitment: pub Field,  // hides all details in one commitment
    nullifier: pub Field,   // prevents double-spend without revealing identity
    sender: Field,          // private
    receiver: Field,        // private
    amount: Field,          // private
    nonce: Field,           // private
) {
    // Prove the commitment matches the private values
    let computed = std::hash::poseidon::bn254::hash_4([sender, receiver, amount, nonce]);
    assert(computed == commitment, "invalid commitment");

    // Prove the nullifier is correctly derived
    let computed_null = std::hash::poseidon::bn254::hash_2([sender, nonce]);
    assert(computed_null == nullifier, "invalid nullifier");
}
```

## Small-domain brute-force attacks

If a private input has a small domain (age, boolean, small enum), an
attacker can hash all possibilities and compare against the public output.

INCORRECT:

```noir
fn main(age_hash: pub Field, age: Field) {
    // BUG: age is 0-150 -- attacker hashes all 151 values
    // and matches against age_hash to learn the age
    let h = std::hash::poseidon::bn254::hash_1([age]);
    assert(h == age_hash, "invalid age");
}
```

CORRECT:

```noir
fn main(age_hash: pub Field, age: Field, salt: Field) {
    // Salt from a large domain prevents brute-force
    let h = std::hash::poseidon::bn254::hash_2([age, salt]);
    assert(h == age_hash, "invalid age");
    // Verify age is in valid range
    let a = age as u8;
    assert(a <= 150, "invalid age value");
}
```

## Nullifier patterns for double-spend prevention

Nullifiers let you mark a note as "spent" without revealing which note.
The nullifier must be deterministic (same note always produces same nullifier)
but unlinkable to the note commitment.

INCORRECT:

```noir
fn compute_nullifier(note_hash: Field) -> Field {
    // BUG: nullifier = note_hash means anyone can link
    // the nullifier to the original note
    note_hash
}
```

CORRECT:

```noir
fn compute_nullifier(
    note_hash: Field,
    owner_secret: Field,  // only the owner can compute this
) -> Field {
    // Nullifier is derived from both the note and owner's secret
    // - Deterministic: same note + owner always gives same nullifier
    // - Unlinkable: without owner_secret, can't link nullifier to note
    std::hash::poseidon::bn254::hash_2([note_hash, owner_secret])
}
```

## Information leakage through proof timing and size

Even with private inputs, metadata can leak information:

- **Proof generation time**: Variable-time operations can leak input size
- **Circuit selection**: Different circuits for different operations reveal the operation type
- **Transaction patterns**: Timing, frequency, and gas usage create fingerprints

Mitigations:
- Use fixed-size circuits (pad to maximum expected size)
- Add dummy operations to normalize execution paths
- Use relayers to break sender-transaction links
- Batch operations to obscure individual patterns
