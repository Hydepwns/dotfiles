---
title: Nix Flake Structure and Composition
impact: CRITICAL
impactDescription: Covers flake inputs, outputs, lock files, and the standard structure for reproducible Nix projects.
tags: nix, flakes, inputs, outputs, lock
---

# Flake Patterns

## Minimal flake structure

```nix
{
  description = "My project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.callPackage ./package.nix { };
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.go pkgs.gopls ];
        };
      }
    );
}
```

## Input patterns

```nix
inputs = {
  # Follow another input's nixpkgs (avoid duplicate nixpkgs)
  some-tool.url = "github:owner/tool";
  some-tool.inputs.nixpkgs.follows = "nixpkgs";

  # Non-flake input (raw source)
  skill-source = {
    url = "github:owner/skills";
    flake = false;
  };

  # Specific branch or rev
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  pinned.url = "github:owner/repo/abc123";
};
```

## Output schema

```nix
outputs = { self, nixpkgs, ... }: {
  # Packages (per-system)
  packages.x86_64-linux.default = derivation;
  packages.x86_64-linux.foo = derivation;

  # Dev shells (per-system)
  devShells.x86_64-linux.default = mkShell { };

  # NixOS modules (system-independent)
  nixosModules.default = { config, pkgs, ... }: { };

  # Home Manager modules
  homeManagerModules.default = { config, pkgs, ... }: { };

  # Overlays
  overlays.default = final: prev: { };

  # Apps (per-system, for `nix run`)
  apps.x86_64-linux.default = {
    type = "app";
    program = "${self.packages.x86_64-linux.default}/bin/foo";
  };

  # Templates (for `nix flake init`)
  templates.default = {
    path = ./template;
    description = "Default project template";
  };
};
```

## Lockfile management

```bash
nix flake lock                    # Create/update flake.lock
nix flake lock --update-input nixpkgs  # Update single input
nix flake update                  # Update all inputs
```

**Always commit flake.lock** -- it is the reproducibility guarantee.

## Dev shell patterns

```nix
devShells.default = pkgs.mkShell {
  packages = with pkgs; [ go gopls gotools ];

  # Environment variables
  GOPATH = "${toString ./.}/.go";

  # Shell hook (runs on entry)
  shellHook = ''
    echo "Dev environment loaded"
  '';

  # For C dependencies
  buildInputs = [ pkgs.openssl ];
  nativeBuildInputs = [ pkgs.pkg-config ];
};
```

## Overlay patterns

```nix
# Add or replace packages
overlays.default = final: prev: {
  myTool = final.callPackage ./package.nix { };

  # Override existing package
  git = prev.git.overrideAttrs (old: {
    patches = old.patches ++ [ ./my-patch.patch ];
  });
};

# Apply overlay
pkgs = import nixpkgs {
  inherit system;
  overlays = [ self.overlays.default ];
};
```

## Cross-system without flake-utils

```nix
# Manual eachSystem (avoid flake-utils dependency)
outputs = { self, nixpkgs }:
  let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux" "aarch64-linux"
      "x86_64-darwin" "aarch64-darwin"
    ];
    pkgsFor = system: nixpkgs.legacyPackages.${system};
  in {
    packages = forAllSystems (system: {
      default = (pkgsFor system).callPackage ./package.nix { };
    });
  };
```
