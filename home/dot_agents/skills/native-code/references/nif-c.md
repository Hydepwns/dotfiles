---
title: C NIF Implementation with erl_nif.h
impact: CRITICAL
impactDescription: Covers C NIF function signatures, term extraction, resource objects, and memory management via the erl_nif API.
tags: nif, c, beam, native, memory
---

# C NIF Patterns

NIFs written in C using the `erl_nif.h` API.

## NIF function signature

```c
#include <erl_nif.h>

static ERL_NIF_TERM
my_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    // argv[0], argv[1], ... are the Elixir arguments
    // return an ERL_NIF_TERM
}
```

## Term extraction (Elixir -> C)

```c
// Integer
int value;
if (!enif_get_int(env, argv[0], &value)) {
    return enif_make_badarg(env);
}

// Binary
ErlNifBinary bin;
if (!enif_inspect_binary(env, argv[0], &bin)) {
    return enif_make_badarg(env);
}
// bin.data is a pointer, bin.size is the length
// VALID ONLY for this NIF call -- do not store

// Atom (as string)
char atom_buf[256];
if (!enif_get_atom(env, argv[0], atom_buf, sizeof(atom_buf), ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
}

// List iteration
ERL_NIF_TERM head, tail = argv[0];
while (enif_get_list_cell(env, tail, &head, &tail)) {
    int item;
    if (!enif_get_int(env, head, &item)) {
        return enif_make_badarg(env);
    }
    // process item
}
```

## Term construction (C -> Elixir)

```c
// Atom
enif_make_atom(env, "ok")

// Integer
enif_make_int(env, 42)

// Binary (copy data into BEAM-managed binary)
ErlNifBinary out_bin;
enif_alloc_binary(result_len, &out_bin);
memcpy(out_bin.data, result_data, result_len);
ERL_NIF_TERM bin_term = enif_make_binary(env, &out_bin);

// Tuple {:ok, value}
enif_make_tuple2(env,
    enif_make_atom(env, "ok"),
    enif_make_int(env, 42))

// Tuple {:error, reason}
enif_make_tuple2(env,
    enif_make_atom(env, "error"),
    enif_make_atom(env, "invalid_input"))

// List
ERL_NIF_TERM list = enif_make_list(env, 0);  // empty list
for (int i = count - 1; i >= 0; i--) {
    list = enif_make_list_cell(env, items[i], list);
}
```

## Resource objects

For native state that outlives a single NIF call (handles, connections, parsers):

```c
static ErlNifResourceType *PARSER_RESOURCE;

typedef struct {
    TSParser *parser;
    const TSLanguage *language;
} ParserResource;

// Destructor -- called by BEAM GC
static void parser_resource_dtor(ErlNifEnv *env, void *obj) {
    (void)env;
    ParserResource *res = (ParserResource *)obj;
    if (res->parser) {
        ts_parser_delete(res->parser);
        res->parser = NULL;
    }
}

// Register in load callback
static int load(ErlNifEnv *env, void **priv, ERL_NIF_TERM info) {
    (void)priv; (void)info;
    PARSER_RESOURCE = enif_open_resource_type(
        env, NULL, "parser",
        parser_resource_dtor,
        ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER,
        NULL);
    if (!PARSER_RESOURCE) return -1;
    return 0;
}

// Create resource
static ERL_NIF_TERM
parser_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    (void)argc;
    ParserResource *res = enif_alloc_resource(PARSER_RESOURCE, sizeof(*res));
    if (!res) return enif_make_atom(env, "error");

    res->parser = ts_parser_new();
    // ... configure parser ...

    ERL_NIF_TERM term = enif_make_resource(env, res);
    enif_release_resource(res);  // BEAM now owns it
    return enif_make_tuple2(env, enif_make_atom(env, "ok"), term);
}

// Use resource
static ERL_NIF_TERM
parser_parse(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    (void)argc;
    ParserResource *res;
    if (!enif_get_resource(env, argv[0], PARSER_RESOURCE, (void **)&res)) {
        return enif_make_badarg(env);
    }
    // use res->parser
}
```

### Incorrect: forgetting enif_release_resource

```c
// Incorrect -- resource is leaked, destructor never called
ERL_NIF_TERM term = enif_make_resource(env, res);
return term;  // missing enif_release_resource

// Correct -- release after make_resource, BEAM GC handles cleanup
ERL_NIF_TERM term = enif_make_resource(env, res);
enif_release_resource(res);
return term;
```

## Dirty NIF declaration

```c
static ErlNifFunc nif_funcs[] = {
    // Regular NIF (< 1ms)
    {"fast_hash", 1, fast_hash_nif, 0},

    // Dirty CPU-bound (> 1ms computation)
    {"slow_compute", 1, slow_compute_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},

    // Dirty I/O-bound (file/network)
    {"read_file", 1, read_file_nif, ERL_NIF_DIRTY_JOB_IO_BOUND},
};

ERL_NIF_INIT(Elixir.MyApp.Native, nif_funcs, load, NULL, NULL, NULL)
```

## NIF init and lifecycle

```c
// Full lifecycle
static int load(ErlNifEnv *env, void **priv, ERL_NIF_TERM info);
static int upgrade(ErlNifEnv *env, void **priv, void **old_priv, ERL_NIF_TERM info);
static void unload(ErlNifEnv *env, void *priv);

ERL_NIF_INIT(Elixir.MyApp.Native, nif_funcs, load, NULL, upgrade, unload)
//           ^module atom          ^funcs     ^load ^reload ^upgrade ^unload
```

## Tree-sitter grammar NIFs

Tree-sitter parsers compile as C libraries. Wrap them as NIF resources:

```c
// Parser resource holds TSParser + TSTree
// Parse function: takes source binary, returns tree resource
// Query function: takes tree resource + query string, returns matches as list

// Key pattern: TSTree is immutable after parse, safe to query from multiple NIFs
// Key pattern: TSParser is NOT thread-safe, one per resource
```

## Makefile for NIF compilation

```makefile
CFLAGS = -O2 -Wall -Wextra -Werror -fPIC -std=c11
CFLAGS += -I$(ERTS_INCLUDE_DIR)
LDFLAGS = -shared

# macOS needs different flags
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    LDFLAGS += -undefined dynamic_lookup -flat_namespace
endif

all: priv/my_nif.so

priv/my_nif.so: c_src/my_nif.c
	@mkdir -p priv
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

clean:
	rm -f priv/my_nif.so
```
