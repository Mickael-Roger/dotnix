# Usage

Pre requisites: DO NOT FORGET TO CREATE AN SSH KEY FOR root user FOR GITHUB PRIVATE REPO (that contains a secrets file)


To update flake: `nix flake update`

Then:

`nixos-rebuild switch --flake .#server --impure`

Update secrets: `nixos-rebuild switch --update-input  secretSrc --flake .#server --impure`
