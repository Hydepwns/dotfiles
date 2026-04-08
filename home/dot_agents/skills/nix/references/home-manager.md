---
title: Home Manager Declarative Dotfile Management
impact: HIGH
impactDescription: Standalone and NixOS-integrated Home Manager patterns for declarative user environment configuration.
tags: nix, home-manager, dotfiles, declarative, modules
---

# Home Manager Patterns

## Standalone Home Manager with flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.droo = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./home.nix ];
    };
  };
}
```

Apply: `home-manager switch --flake .#droo`

## home.nix structure

```nix
{ config, pkgs, lib, ... }:
{
  home.username = "droo";
  home.homeDirectory = "/home/droo";  # or /Users/droo on macOS

  # Packages (user-level)
  home.packages = with pkgs; [
    ripgrep fd bat jq
  ];

  # Programs with config
  programs.git = {
    enable = true;
    userName = "droo";
    userEmail = "droo@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      # Custom zsh init
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character.success_symbol = "[->](bold green)";
    };
  };

  # Dotfiles (raw file management)
  home.file.".config/foo/config.toml".text = ''
    [settings]
    key = "value"
  '';

  home.file.".config/foo/config.toml".source = ./config/foo.toml;

  # State version (do NOT change after first activation)
  home.stateVersion = "24.11";
}
```

## Writing a Home Manager module

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.myTool;
in {
  options.programs.myTool = {
    enable = lib.mkEnableOption "myTool";

    package = lib.mkPackageOption pkgs "myTool" { };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Configuration key-value pairs";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."mytool/config.toml".text =
      lib.concatStringsSep "\n"
        (lib.mapAttrsToList (k: v: "${k} = \"${v}\"") cfg.settings);
  };
}
```

## XDG integration

```nix
# Use xdg module for proper XDG paths
xdg.enable = true;

# Config files -> ~/.config/
xdg.configFile."foo/config.toml".source = ./foo.toml;

# Data files -> ~/.local/share/
xdg.dataFile."foo/data.db".source = ./data.db;

# Manage environment variables
home.sessionVariables = {
  EDITOR = "nvim";
  PAGER = "less";
};
```

## Activation scripts

```nix
# Run custom commands on home-manager switch
home.activation = {
  mySetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.local/state/myapp
  '';
};
```

## macOS specifics

Home Manager works on macOS without NixOS. Key differences:
- `home.homeDirectory = "/Users/droo"` (not `/home/droo`)
- No systemd -- use `launchd.agents` for services
- Some programs modules may not work (systemd-dependent)
- Use `nix-darwin` for system-level macOS config alongside Home Manager
