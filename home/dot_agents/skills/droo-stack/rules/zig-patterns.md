---
title: Zig Idiomatic Patterns
impact: HIGH
impactDescription: Guides correct use of error unions, comptime, allocators, and build patterns in Zig.
tags: zig, comptime, allocators, error-unions, build
---

# Zig Patterns

## Error unions vs optionals

```zig
// Incorrect -- optional when the failure reason matters
fn findUser(id: u64) ?User {
    // caller can't distinguish "not found" from "db error"
}

// Correct -- error union preserves the failure reason
fn findUser(id: u64) !User {
    return db.query(id) catch |err| return err;
}

// Optional is correct when absence is the only failure mode
fn getCache(key: []const u8) ?*Entry {
    return map.get(key);  // null = not cached, no error
}
```

## Comptime generics

```zig
// Incorrect -- anytype loses type information in errors
fn sum(items: anytype) anytype {
    // error messages reference "anytype", not the actual type
}

// Correct -- constrained comptime parameter
fn sum(comptime T: type, items: []const T) T {
    var total: T = 0;
    for (items) |item| {
        total += item;
    }
    return total;
}
```

## Allocator discipline

Never use a global allocator. Accept one as a parameter:

```zig
// Incorrect -- hardcoded allocator
fn loadConfig() !Config {
    const alloc = std.heap.page_allocator;  // hidden dependency
    // ...
}

// Correct -- allocator as parameter
fn loadConfig(allocator: std.mem.Allocator) !Config {
    const data = try allocator.alloc(u8, 4096);
    defer allocator.free(data);
    // ...
}
```

Always pair alloc with defer free:

```zig
const buf = try allocator.alloc(u8, size);
defer allocator.free(buf);
// use buf -- freed automatically on scope exit (including error returns)
```

## Slice idioms

Prefer slices over pointer+length pairs:

```zig
// Incorrect -- C-style pointer + length
fn process(data: [*]const u8, len: usize) void {
    // manual bounds checking needed
}

// Correct -- slice carries length
fn process(data: []const u8) void {
    for (data) |byte| {
        // bounds-checked automatically
    }
}
```

For C interop, use sentinel-terminated slices:

```zig
// C string (null-terminated) to Zig slice
const c_str: [*:0]const u8 = @ptrCast(raw_c_string);
const zig_slice = std.mem.span(c_str);

// Zig slice to C string
const c_str = try allocator.dupeZ(u8, zig_slice);  // adds null terminator
defer allocator.free(c_str);
```

## Error handling patterns

```zig
// Catch and transform errors
const file = std.fs.cwd().openFile(path, .{}) catch |err| {
    std.log.err("open {s}: {}", .{ path, err });
    return error.ConfigLoadFailed;
};
defer file.close();

// errdefer for cleanup on error only
fn createResource(allocator: std.mem.Allocator) !*Resource {
    const r = try allocator.create(Resource);
    errdefer allocator.destroy(r);  // only runs if we return an error below

    r.* = .{
        .data = try allocator.alloc(u8, 1024),
        // if this alloc fails, r is freed by errdefer
    };
    return r;
}
```

## Testing

```zig
// Tests live in the same file (idiomatic)
const std = @import("std");

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "add positive numbers" {
    try std.testing.expectEqual(@as(i32, 5), add(2, 3));
}

test "add handles overflow" {
    const result = @addWithOverflow(std.math.maxInt(i32), 1);
    try std.testing.expect(result[1] == 1);  // overflow flag
}
```

Run with `zig test src/main.zig`. Use `--test-filter "pattern"` to run specific tests.

## Build system

```zig
// build.zig -- shared library for NIF or C consumption
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Shared library (for NIF/FFI)
    const lib = b.addSharedLibrary(.{
        .name = "mysimd",
        .root_source_file = b.path("src/simd.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Export C-compatible symbols
    lib.linker_module.addCSourceFiles(.{
        .files = &.{"src/wrapper.c"},
    });

    b.installArtifact(lib);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("src/simd.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
```

## C interop

```zig
// Import C headers
const c = @cImport({
    @cInclude("erl_nif.h");
});

// Export function with C ABI
export fn my_nif(
    env: ?*c.ErlNifEnv,
    argc: c_int,
    argv: [*]const c.ERL_NIF_TERM,
) c.ERL_NIF_TERM {
    // ...
}

// Pointer casting (between Zig and C types)
const zig_ptr: *MyStruct = @ptrCast(@alignCast(c_void_ptr));
```

## Struct patterns

```zig
// Default values via struct literals
const Config = struct {
    port: u16 = 8080,
    host: []const u8 = "0.0.0.0",
    max_connections: u32 = 128,

    pub fn init(overrides: Config) Config {
        return overrides;  // defaults fill in missing fields
    }
};

// Usage -- only specify what differs
const cfg = Config.init(.{ .port = 9090 });
```

## Enum and tagged union

```zig
const Command = union(enum) {
    get: []const u8,
    set: struct { key: []const u8, value: []const u8 },
    delete: []const u8,
    quit,

    pub fn execute(self: Command) !void {
        switch (self) {
            .get => |key| try handleGet(key),
            .set => |kv| try handleSet(kv.key, kv.value),
            .delete => |key| try handleDelete(key),
            .quit => return,
        }
    }
};
```

## See also

- `native-code` skill -- for NIF boundary patterns and SIMD with `@Vector`
- `c-patterns` -- C interop is a core Zig use case
