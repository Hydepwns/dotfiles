---
title: Nix Derivations and Packaging
impact: HIGH
impactDescription: Patterns for stdenv.mkDerivation, language-specific builders, and Nix packaging conventions.
tags: nix, derivation, stdenv, mkDerivation, packaging
---

# Nix Packaging Patterns

## stdenv.mkDerivation (generic)

```nix
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mytool";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "mytool";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [ /* build-time tools: cmake, pkg-config */ ];
  buildInputs = [ /* runtime deps: openssl, zlib */ ];

  meta = with lib; {
    description = "A tool";
    homepage = "https://github.com/owner/mytool";
    license = licenses.mit;
    mainProgram = "mytool";  # required for `nix run`
    platforms = platforms.unix;
  };
}
```

## Language-specific builders

### Go

```nix
{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mytool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "mytool";
    rev = "v${version}";
    hash = "sha256-...";
  };

  vendorHash = "sha256-...";  # null if vendored in repo

  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  meta.mainProgram = "mytool";
}
```

### Rust

```nix
{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "mytool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "mytool";
    rev = "v${version}";
    hash = "sha256-...";
  };

  cargoHash = "sha256-...";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta.mainProgram = "mytool";
}
```

### Python

```nix
{ lib, python3Packages, fetchPypi }:

python3Packages.buildPythonApplication rec {
  pname = "mytool";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-...";
  };

  propagatedBuildInputs = with python3Packages; [
    click requests
  ];

  meta.mainProgram = "mytool";
}
```

### Node.js / npm

```nix
{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "mytool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "mytool";
    rev = "v${version}";
    hash = "sha256-...";
  };

  npmDepsHash = "sha256-...";

  meta.mainProgram = "mytool";
}
```

## Getting hashes

```bash
# For fetchFromGitHub -- use empty hash, nix will tell you the correct one
nix build .#mytool
# error: hash mismatch ... got: sha256-CORRECT_HASH_HERE

# Or use nix-prefetch
nix-prefetch-url --unpack https://github.com/owner/repo/archive/v1.0.0.tar.gz

# For cargoHash/vendorHash -- same trick: set to empty string, build, copy correct hash
```

## writeShellApplication (for scripts)

```nix
pkgs.writeShellApplication {
  name = "my-script";
  runtimeInputs = [ pkgs.jq pkgs.curl ];
  text = ''
    response=$(curl -s "$1")
    echo "$response" | jq '.data'
  '';
}
```

This is preferred over `writeShellScriptBin` because it runs shellcheck and
sets `set -euo pipefail` automatically.

## Override patterns

```nix
# Override arguments to a package function
pkgs.myTool.override {
  enableFeatureX = true;
}

# Override derivation attributes
pkgs.myTool.overrideAttrs (old: {
  patches = old.patches ++ [ ./fix.patch ];
  buildInputs = old.buildInputs ++ [ pkgs.libfoo ];
})

# Override Python packages
pkgs.python3.withPackages (ps: [ ps.requests ps.click ])
```
