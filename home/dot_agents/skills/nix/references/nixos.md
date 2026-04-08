---
title: NixOS System Configuration Modules
impact: HIGH
impactDescription: NixOS module structure, service configuration, networking, and system-level declarative patterns.
tags: nix, nixos, modules, configuration, system
---

# NixOS Configuration Patterns

## Module structure

```nix
# /etc/nixos/configuration.nix or a flake-based module
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./users.nix
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    vim git curl wget
  ];

  # Enable services
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # System state version (do NOT change after install)
  system.stateVersion = "24.11";
}
```

## Writing a NixOS module

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.services.myService;
in {
  options.services.myService = {
    enable = lib.mkEnableOption "my service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.myService;
      description = "Package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.myService = {
      description = "My Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/myservice --port ${toString cfg.port}";
        DynamicUser = true;
        Restart = "on-failure";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
```

## Flake-based NixOS configuration

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
  {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.droo = import ./home.nix;
        }
      ];
    };
  };
}
```

## Rebuild commands

```bash
# Test without switching (dry run)
sudo nixos-rebuild dry-activate --flake .#myhost

# Build and switch
sudo nixos-rebuild switch --flake .#myhost

# Build and switch on next boot only
sudo nixos-rebuild boot --flake .#myhost

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

## Common service patterns

```nix
# Nginx reverse proxy
services.nginx = {
  enable = true;
  virtualHosts."myapp.example.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.myService.port}";
    };
  };
};

# Postgres
services.postgresql = {
  enable = true;
  ensureDatabases = [ "mydb" ];
  ensureUsers = [{
    name = "myuser";
    ensureDBOwnership = true;
  }];
};

# Firewall
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 22 ];
};
```

## nix-agent MCP workflow for NixOS changes

When using the nix-agent MCP server for NixOS automation:

1. **plan_change(goal)** -- returns scope (home-manager vs system) and whether mcp-nixos lookup is needed
2. **inspect_state(path)** -- read target config files
3. **apply_patch_set(patches)** -- apply changes with content verification
4. **run_formatters(files)** -- format with nixpkgs-fmt
5. **classify_change(files)** -- policy check (SSH, networking, hardware are high-risk)
6. **apply_change(intent, files, flake_uri)** -- dry-activate then switch

High-risk patterns that require human approval: SSH config, networking, hardware-configuration.nix.
