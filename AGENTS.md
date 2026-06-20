# Project-Specific Agent Guidelines

## Overview

- This repository contains flake-based NixOS configurations for `server` and `xps-laptop`.
- Shared system modules live under `common/`.
- Role-focused shared modules include `common/desktop.nix`, `common/networking.nix`, `common/virtualization.nix`, `common/calendar.nix`, and `common/hardware.nix`.
- Host-specific configuration lives under `hosts/<host>/`.
- Home Manager configuration is centralized in `common/home-manager.nix`.
- Package category modules live under `common/pkgs/`.

## Rules

- Keep Nix changes minimal and preserve existing host behavior unless explicitly asked to refactor.
- Prefer direct attrpath assignments consistently when a module already uses them, to avoid duplicate attrset definitions.
- Avoid interpolating secrets into generated Nix store files, systemd commands, or Home Manager config.
- Keep server-only and workstation-only changes separated where possible.

## Validation Notes

- Use `nix flake check --no-build --impure` for lightweight evaluation checks when secrets/private inputs require impure evaluation.
- If evaluation fails on unrelated insecure packages, report the blocker instead of broadening insecure package allowances without request.

## Lessons Learned

- Duplicate attrset keys such as repeated `dconf.settings."org/gnome/desktop/wm/keybindings"` can block Nix evaluation; merge values into one attrset.
- Mixing `xdg = { configFile...; }` with `xdg.configFile...` assignments in the same attrset can produce duplicate attrpath errors; prefer one style.
