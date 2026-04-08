---
title: Zig SIMD Vector Optimization
impact: HIGH
impactDescription: Covers Zig @Vector SIMD patterns for high-performance native code callable from BEAM NIFs.
tags: simd, zig, vector, performance, optimization
---

# Zig SIMD Patterns

SIMD (Single Instruction, Multiple Data) via Zig's `@Vector` type.
Zig compiles to a shared library with C ABI, callable from C NIFs or Rust NIFs.

## @Vector basics

```zig
const std = @import("std");

// Declare a vector of 8 f32 lanes
const Vec8f = @Vector(8, f32);

pub fn add_vectors(a: Vec8f, b: Vec8f) Vec8f {
    return a + b;  // SIMD add, 8 floats at once
}

pub fn scale(v: Vec8f, scalar: f32) Vec8f {
    const splat: Vec8f = @splat(scalar);
    return v * splat;
}
```

Standard arithmetic operators (`+`, `-`, `*`, `/`, `%`) work on vectors.
Comparison operators return `@Vector(N, bool)`.

## Loading from memory

```zig
// Load a vector from a slice
fn loadVec(data: []const f32) Vec8f {
    // Incorrect -- direct pointer cast may violate alignment
    // const ptr: *const Vec8f = @ptrCast(data.ptr);
    // return ptr.*;

    // Correct -- use array pointer with proper length
    return data[0..8].*;
}

// Store vector to slice
fn storeVec(out: []f32, v: Vec8f) void {
    out[0..8].* = v;
}
```

## Batch processing pattern

Process arrays in SIMD-width chunks with scalar tail handling:

```zig
const LANES = 8;
const VecF32 = @Vector(LANES, f32);

pub export fn batch_multiply(
    input: [*]const f32,
    output: [*]f32,
    len: usize,
    factor: f32,
) void {
    const splat_factor: VecF32 = @splat(factor);
    const full_chunks = len / LANES;
    const remainder = len % LANES;

    // SIMD loop
    var i: usize = 0;
    while (i < full_chunks) : (i += 1) {
        const offset = i * LANES;
        const chunk: VecF32 = input[offset..][0..LANES].*;
        output[offset..][0..LANES].* = chunk * splat_factor;
    }

    // Scalar tail
    const tail_start = full_chunks * LANES;
    for (tail_start..tail_start + remainder) |j| {
        output[j] = input[j] * factor;
    }
}
```

## Reductions

```zig
const Vec8i = @Vector(8, i32);

fn sum(v: Vec8i) i32 {
    return @reduce(.Add, v);
}

fn max_element(v: Vec8i) i32 {
    return @reduce(.Max, v);
}

fn any_nonzero(v: Vec8i) bool {
    const zero: Vec8i = @splat(0);
    const cmp = v != zero;  // @Vector(8, bool)
    return @reduce(.Or, cmp);
}

fn all_positive(v: Vec8i) bool {
    const zero: Vec8i = @splat(0);
    const cmp = v > zero;
    return @reduce(.And, cmp);
}
```

## Conditional operations (@select)

Branchless per-lane selection:

```zig
fn clamp(v: Vec8f, lo: f32, hi: f32) Vec8f {
    const lo_vec: Vec8f = @splat(lo);
    const hi_vec: Vec8f = @splat(hi);

    // clamp low
    const below = v < lo_vec;
    const clamped_lo = @select(f32, below, lo_vec, v);

    // clamp high
    const above = clamped_lo > hi_vec;
    return @select(f32, above, hi_vec, clamped_lo);
}
```

## Shuffles

```zig
// Reverse a vector
fn reverse(v: @Vector(4, f32)) @Vector(4, f32) {
    return @shuffle(f32, v, undefined, @Vector(4, i32){ 3, 2, 1, 0 });
}

// Interleave two vectors
fn interleave_lo(a: @Vector(4, f32), b: @Vector(4, f32)) @Vector(4, f32) {
    return @shuffle(f32, a, b, @Vector(4, i32){ 0, -1, 1, -2 });
    //                                          a[0] b[0] a[1] b[1]
    // Negative indices select from second operand: -1 = b[0], -2 = b[1]
}
```

## Alignment

```zig
// Align data for optimal SIMD access
const CACHE_LINE = 64;

const AlignedBuffer = struct {
    data: []align(CACHE_LINE) f32,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, len: usize) !AlignedBuffer {
        const data = try allocator.alignedAlloc(f32, CACHE_LINE, len);
        return .{ .data = data, .allocator = allocator };
    }

    pub fn deinit(self: *AlignedBuffer) void {
        self.allocator.free(self.data);
    }
};
```

## Comptime feature detection with fallback

```zig
const builtin = @import("builtin");

const has_avx2 = std.Target.x86.featureSetHas(builtin.cpu.features, .avx2);

pub fn process(data: []const f32) f32 {
    if (comptime has_avx2) {
        return process_avx2(data);  // 8-wide
    } else {
        return process_scalar(data);  // fallback
    }
}

fn process_avx2(data: []const f32) f32 {
    const Vec8 = @Vector(8, f32);
    // ... 8-wide SIMD implementation
}

fn process_scalar(data: []const f32) f32 {
    var sum: f32 = 0;
    for (data) |v| sum += v;
    return sum;
}
```

## Exporting for C ABI (NIF integration)

```zig
// Export functions callable from C NIFs or Rust FFI
pub export fn simd_dot_product(
    a: [*]const f32,
    b: [*]const f32,
    len: usize,
) f32 {
    const LANES = 8;
    const VecF = @Vector(LANES, f32);
    var accum: VecF = @splat(@as(f32, 0));

    const chunks = len / LANES;
    for (0..chunks) |i| {
        const offset = i * LANES;
        const va: VecF = a[offset..][0..LANES].*;
        const vb: VecF = b[offset..][0..LANES].*;
        accum += va * vb;  // fused multiply-add on supporting hardware
    }

    var result = @reduce(.Add, accum);

    // Scalar tail
    const tail = chunks * LANES;
    for (tail..len) |j| {
        result += a[j] * b[j];
    }
    return result;
}
```

## Build for NIF integration

```zig
// build.zig -- shared library for NIF consumption
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "mysimd",
        .root_source_file = b.path("src/simd.zig"),
        .target = target,
        .optimize = .ReleaseFast,  // SIMD needs optimization
    });

    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = b.path("src/simd.zig"),
        .target = target,
    });
    const test_step = b.step("test", "Run SIMD tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
```

The resulting `libmysimd.so` / `libmysimd.dylib` is linked by the C NIF
Makefile or referenced via Rust `extern "C"` FFI.

## Testing SIMD

```zig
const std = @import("std");
const simd = @import("simd.zig");

test "dot product matches scalar" {
    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0 };
    const b = [_]f32{ 9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0 };

    const result = simd.simd_dot_product(&a, &b, a.len);

    // Scalar reference
    var expected: f32 = 0;
    for (a, b) |ai, bi| expected += ai * bi;

    try std.testing.expectApproxEqAbs(expected, result, 0.001);
}

test "batch_multiply handles non-aligned length" {
    var input = [_]f32{ 1, 2, 3, 4, 5 };  // 5 elements, not aligned to 8
    var output: [5]f32 = undefined;
    simd.batch_multiply(&input, &output, 5, 2.0);
    try std.testing.expectEqual([_]f32{ 2, 4, 6, 8, 10 }, output);
}
```
