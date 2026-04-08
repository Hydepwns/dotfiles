---
title: Nix Profile and Generation Management
impact: MEDIUM
impactDescription: Commands and patterns for managing nix profile installations, upgrades, and generations.
tags: nix, profiles, nix-profile, generations
---

# Nix Profile Management

## Modern profile commands (nix profile)

```bash
# Install a package
nix profile install nixpkgs#ripgrep

# List installed packages
nix profile list

# Remove by index
nix profile remove 3

# Update all packages
nix profile upgrade '.*'

# Update specific package
nix profile upgrade packages.x86_64-linux.ripgrep

# Rollback to previous generation
nix profile rollback

# Show diff between generations
nix profile diff-closures
```

## Declarative profiles (preferred)

Instead of imperative `nix profile install`, declare packages in a flake:

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in {
      packages.aarch64-darwin.default = pkgs.buildEnv {
        name = "my-tools";
        paths = with pkgs; [
          ripgrep fd bat jq yq
          git gh
        ];
      };
    };
}
```

```bash
nix profile install .#default
```

## Registry management

```bash
# List registries
nix registry list

# Pin a registry entry to a specific rev
nix registry pin nixpkgs

# Add custom registry
nix registry add my-pkgs github:owner/my-pkgs

# Remove registry entry
nix registry remove my-pkgs

# Use pinned registry in commands
nix shell my-pkgs#sometool
```

## Garbage collection

```bash
# Remove old generations (keep last 7 days)
nix profile wipe-history --older-than 7d

# Garbage collect unreferenced store paths
nix store gc

# Legacy GC (also works)
nix-collect-garbage -d    # delete all old generations then GC
nix-collect-garbage --delete-older-than 30d
```

## Store inspection

```bash
# Query package dependencies
nix path-info -rsh /nix/store/...-ripgrep-14.0.0

# Why is something in the closure?
nix why-depends /nix/store/...-system /nix/store/...-openssl

# Show store path size
nix path-info -S /nix/store/...-ripgrep-14.0.0
```

## Channel alternatives

```bash
# Incorrect -- mutable channels
nix-channel --add https://nixos.org/channels/nixos-unstable
nix-channel --update

# Correct -- flake inputs with lockfile
# Pin nixpkgs in flake.nix inputs, use `nix flake update` to bump
```
