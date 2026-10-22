{
  description = "Mickael NixOS configuration for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  # Ensure Home Manager uses the same nixpkgs

    nur-repo.url = "github:nix-community/NUR";
    #nur.inputs.nixpkgs.follows = "nixpkgs";  # Ensure NUR uses the same nixpkgs

    yt-x = {
      url = "github:Benexl/yt-x";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    himalaya.url = "github:pimalaya/himalaya/4df380ba857532eb471f3e740c0208a35c64fb5c";
    himalaya.inputs.nixpkgs.follows = "nixpkgs-unstable";

    neverest.url = "github:pimalaya/neverest/19cb351063753028277c86cad9546b5121f1427e";
    neverest.inputs.nixpkgs.follows = "nixpkgs-unstable";

    carillon.url = "github:pimalaya/carillon";
    carillon.inputs.nixpkgs.follows = "nixpkgs-unstable";

    email-tui.url = "github:Mickael-Roger/email-tui/v0.2.0";
    email-tui.inputs.nixpkgs.follows = "nixpkgs-unstable";

    codex.url = "github:openai/codex/rust-v0.163.0";
    codex.inputs.nixpkgs.follows = "nixpkgs-unstable";

    ctfmgntSrc = { 
      url = "github:Mickael-Roger/ctf-mgnt/0.3.3";
      flake = false;
    };

    secretSrc = { 
      url = "git+ssh://git@github.com/Mickael-Roger/secrets";
      flake = false;
    };


  };

  outputs = { nixpkgs, home-manager, nur-repo, ctfmgntSrc, secretSrc, nixpkgs-unstable, yt-x, himalaya, neverest, carillon, email-tui, codex, ... }:
  let
    system = "x86_64-linux";

    unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

    nur = import nur-repo { inherit pkgs; }; 

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    codexPackage = pkgs.callPackage "${codex}/codex-rs/default.nix" {
      version = "0.163.0";
      rustPlatform = pkgs.rustPlatform // {
        buildRustPackage = f: pkgs.rustPlatform.buildRustPackage (args:
          let attrs = f args;
          in attrs // {
            cargoBuildFlags = [ "-p" "codex-cli" ];
            installPhase = ''
              install -Dm755 target/*/release/codex "$out/bin/codex"
            '';
            cargoLock = attrs.cargoLock // {
              # The upstream flake omits hashes for several Git dependencies.
              allowBuiltinFetchGit = true;
              outputHashes = { };
            };
          }
        );
      };
    };

    mkHost = host: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        (./hosts + "/${host}/configuration.nix")
        (./hosts + "/${host}/hardware-configuration.nix")
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = import ./common/home-manager.nix {
            inherit pkgs nur secretSrc;
            himalayaPackage = himalaya.packages.${system}.default.overrideAttrs (old: {
              checkFlags = (old.checkFlags or "") + ''
                --skip shared::attachment::list::tests::control_characters_from_the_sender_are_not_printed
                --skip shared::envelope::list::tests::control_characters_from_the_sender_are_not_printed
              '';
             });
             neverestPackage = neverest.packages.${system}.default;
             carillonPackage = carillon.packages.${system}.default;
             mailtuiPackage = email-tui.packages.${system}.default;
             inherit codexPackage;
           };
          home-manager.extraSpecialArgs = { inherit nur pkgs secretSrc; };
        }
      ];

      specialArgs = { inherit ctfmgntSrc secretSrc unstable nixpkgs yt-x; };
    };

  in {

    nixosConfigurations = {
      server = mkHost "server";
      xps-laptop = mkHost "xps-laptop";
    };

  };
}
