---
title: Nix Language Syntax and Core Idioms
impact: CRITICAL
impactDescription: Foundational Nix language patterns including let bindings, attribute sets, builtins, and expressions.
tags: nix, language, syntax, builtins, expressions
---

# Nix Language Patterns

## Core idioms

### let bindings over rec

```nix
# Incorrect -- rec allows self-reference but risks infinite recursion
rec {
  x = 1;
  y = x + 1;
}

# Correct -- let scopes cleanly
let
  x = 1;
  y = x + 1;
in { inherit x y; }
```

### Selective inherit over `with`

```nix
# Incorrect -- `with pkgs;` shadows names silently
with pkgs; [
  git
  jq
  curl
]

# Correct -- explicit inherit or qualified names
[
  pkgs.git
  pkgs.jq
  pkgs.curl
]

# Also correct -- selective inherit in a let
let
  inherit (pkgs) git jq curl;
in [ git jq curl ]
```

### Function patterns

```nix
# Destructured args with defaults and extra-arg passthrough
{ lib, pkgs, config, ... }:
{
  # module body
}

# Named function for reuse
greet = name: "Hello, ${name}";

# Set pattern with @-binding
mkService = { port, host ? "0.0.0.0", ... }@args:
  lib.mkMerge [ /* use args */ ];
```

### String interpolation

```nix
# Multi-line strings (indented strings) -- strips leading whitespace
description = ''
  A multi-line
  description here.
'';

# Interpolation
configFile = pkgs.writeText "config.json" ''
  {"port": ${toString port}, "host": "${host}"}
'';

# Path interpolation (copies to store)
src = ./src;  # path literal -- entire directory copied to /nix/store
```

### Useful builtins

```nix
builtins.attrNames set          # list of keys
builtins.attrValues set         # list of values
builtins.map f list             # transform list
builtins.filter pred list       # filter list
builtins.elem x list            # membership test
builtins.hasAttr name set       # key existence
builtins.readFile path          # read file contents
builtins.fromJSON str           # parse JSON
builtins.toJSON value           # serialize to JSON
builtins.trace msg value        # debug print (returns value)
builtins.throw msg              # abort evaluation
builtins.tryEval expr           # { success, value } without aborting
```

### lib functions (from nixpkgs)

```nix
lib.mkIf condition value        # conditional module value
lib.mkMerge [ a b ]             # merge module values
lib.mkDefault value             # lower priority default
lib.mkForce value               # override everything
lib.mkOption { type, default, description }  # declare option
lib.optionalString bool str     # conditional string
lib.optionals bool list         # conditional list elements
lib.mapAttrs f set              # transform attrset values
lib.filterAttrs pred set        # filter attrset
lib.genAttrs names f            # generate attrset from name list
lib.recursiveUpdate a b         # deep merge attrsets
lib.pipe value [ f1 f2 f3 ]    # pipeline (f3 (f2 (f1 value)))
```

### Type system (for module options)

```nix
lib.types.bool
lib.types.int
lib.types.str
lib.types.path
lib.types.package
lib.types.listOf type
lib.types.attrsOf type
lib.types.nullOr type
lib.types.enum [ "a" "b" ]
lib.types.oneOf [ type1 type2 ]
lib.types.submodule { options = { ... }; }
```
