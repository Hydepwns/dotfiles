---
title: C Safety and Memory Patterns
impact: HIGH
impactDescription: Enforces safe C idioms for compiler flags, memory ownership, string handling, and error codes.
tags: c, memory, safety, strings, error-codes
---

# C Patterns

## Compiler flags

```c
// Incorrect -- no warnings, silent UB
gcc -o prog main.c

// Correct -- catch bugs at compile time
gcc -Wall -Wextra -Werror -Wpedantic -std=c11 -o prog main.c
```

For NIF/shared library builds, add `-fPIC -shared`.

## Memory ownership

Document who owns (and frees) every allocation. Use naming conventions.

```c
// Incorrect -- caller doesn't know they must free
char *get_name(void) {
    char *name = malloc(64);
    snprintf(name, 64, "hello");
    return name;
}

// Correct -- _owned suffix signals caller must free
char *get_name_owned(void) {
    char *name = malloc(64);
    if (!name) return NULL;
    snprintf(name, 64, "hello");
    return name;  // caller frees
}
```

Always NULL after free to prevent use-after-free:

```c
// Incorrect
free(buf);
// buf is now dangling

// Correct
free(buf);
buf = NULL;
```

## Defensive pointer handling

```c
// Incorrect -- sizeof(Type) diverges if type changes
MyStruct *s = malloc(sizeof(MyStruct));

// Correct -- sizeof(*ptr) always matches
MyStruct *s = malloc(sizeof(*s));
```

NULL-check at function entry, not deep in the body:

```c
// Incorrect -- NULL deref before check
int process(const Config *cfg) {
    int x = cfg->value;  // crash if NULL
    if (!cfg) return -1;
    return x + 1;
}

// Correct -- guard at entry
int process(const Config *cfg) {
    if (!cfg) return -1;
    return cfg->value + 1;
}
```

## Const correctness

```c
// Incorrect -- function could mutate the input
void print_buffer(char *data, size_t len);

// Correct -- const documents read-only intent
void print_buffer(const char *data, size_t len);
```

For double pointers, const the right level:

```c
// Read-only access to array of strings
void print_all(const char *const *strings, size_t count);
//              ^^^^^              ^^^^^ can't reassign pointer either
```

## Error handling via return codes

```c
// Incorrect -- mixing error and data in return value
int parse_port(const char *str) {
    int port = atoi(str);  // returns 0 on failure AND for "0"
    return port;
}

// Correct -- return status, output via pointer
int parse_port(const char *str, uint16_t *out_port) {
    if (!str || !out_port) return -1;

    char *end = NULL;
    long val = strtol(str, &end, 10);
    if (end == str || *end != '\0') return -1;
    if (val < 0 || val > 65535) return -1;

    *out_port = (uint16_t)val;
    return 0;
}
```

## String safety

```c
// Incorrect -- buffer overflow
char buf[64];
sprintf(buf, "user: %s, id: %d", username, id);

// Correct -- bounded write
char buf[64];
int n = snprintf(buf, sizeof(buf), "user: %s, id: %d", username, id);
if (n < 0 || (size_t)n >= sizeof(buf)) {
    // handle truncation
}
```

Never use `gets`, `strcpy`, `strcat` -- always use bounded variants (`fgets`, `strncpy`/`strlcpy`, `strncat`).

## Struct initialization

```c
// Incorrect -- uninitialized fields contain garbage
Config cfg;
cfg.port = 8080;
// cfg.host is garbage

// Correct -- zero-init then set known fields
Config cfg = {0};
cfg.port = 8080;

// Also correct -- designated initializers (C99+)
Config cfg = {
    .port = 8080,
    .host = "0.0.0.0",
    .max_conn = 128,
};
```

## Resource cleanup pattern

For structs that own heap memory, provide init/destroy pairs:

```c
typedef struct {
    char *name;
    uint8_t *data;
    size_t data_len;
} Resource;

int resource_init(Resource *r, const char *name, size_t len) {
    if (!r || !name) return -1;
    r->name = strdup(name);
    if (!r->name) return -1;
    r->data = calloc(len, sizeof(uint8_t));
    if (!r->data) {
        free(r->name);
        r->name = NULL;
        return -1;
    }
    r->data_len = len;
    return 0;
}

void resource_destroy(Resource *r) {
    if (!r) return;
    free(r->name);
    r->name = NULL;
    free(r->data);
    r->data = NULL;
    r->data_len = 0;
}
```

## Header guards

```c
// Incorrect -- traditional guards are error-prone (typos in macro name)
#ifndef MY_HEADER_H
#define MY_HEADER_H
// ...
#endif

// Correct -- pragma once (supported by all major compilers)
#pragma once
```

## Function-like macros vs inline functions

```c
// Incorrect -- macro has no type safety, double evaluation
#define MAX(a, b) ((a) > (b) ? (a) : (b))
int x = MAX(i++, j++);  // i or j incremented twice

// Correct -- inline function
static inline int max_int(int a, int b) {
    return a > b ? a : b;
}
```

## Opaque types for encapsulation

```c
// In header: forward declaration only
typedef struct Parser Parser;

Parser *parser_create(const char *language);
int parser_parse(Parser *p, const char *source, size_t len);
void parser_destroy(Parser *p);

// In .c file: full definition is private
struct Parser {
    TSParser *ts;
    const TSLanguage *lang;
};
```

This pattern is used extensively in tree-sitter grammars and NIF resource types.
