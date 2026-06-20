# NixOS Configurations

Flake-based NixOS configurations for two hosts:

- `server`: daily workstation with local services.
- `xps-laptop`: Dell XPS laptop.

## Prerequisites

- Nix flakes enabled.
- Root SSH access to the private GitHub secrets repository used by `secretSrc`.
- The private secrets input currently requires impure evaluation.

## Validate

Run a lightweight evaluation check before switching:

```sh
nix flake check --no-build --impure
```

If you added new untracked files, use a local path flake reference until the files are added to git:

```sh
nix flake check --no-build --impure path:$PWD
```

Build a host without switching:

```sh
sudo nixos-rebuild build --flake .#server --impure
sudo nixos-rebuild build --flake .#xps-laptop --impure
```

## Rebuild

Apply the server configuration:

```sh
sudo nixos-rebuild switch --flake .#server --impure
```

Apply the laptop configuration:

```sh
sudo nixos-rebuild switch --flake .#xps-laptop --impure
```

## Update Inputs

Update all flake inputs:

```sh
nix flake update
```

Update only secrets:

```sh
nix flake lock --update-input secretSrc
```

Then rebuild the target host.

## Important Modules

- `common/base.nix`: shared basics.
- `common/desktop.nix`: desktop environment, audio, fonts, and desktop packages.
- `common/networking.nix`: NetworkManager, Tailscale, OpenSSH, Avahi, and shared firewall ports.
- `common/opencode.nix`: opencode, agentmemory, and LiteLLM configuration.
- `common/services.nix`: local service stack.
- `common/home-manager.nix`: user-level Home Manager configuration.

## Secrets

Secrets are currently provided by the private `secretSrc` flake input. Avoid printing evaluated secret values or committing generated files that contain secrets.
