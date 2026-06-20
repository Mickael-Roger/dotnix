{
  description = "Mickael NixOS configuration for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  # Ensure Home Manager uses the same nixpkgs

    nur-repo.url = "github:nix-community/NUR";
    #nur.inputs.nixpkgs.follows = "nixpkgs";  # Ensure NUR uses the same nixpkgs

    yt-x = {
      url = "github:Benexl/yt-x";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ctfmgntSrc = { 
      url = "github:Mickael-Roger/ctf-mgnt/0.3.3";
      flake = false;
    };

    secretSrc = { 
      url = "git+ssh://git@github.com/Mickael-Roger/secrets";
      flake = false;
    };


  };

  outputs = { nixpkgs, home-manager, nur-repo, ctfmgntSrc, secretSrc, nixpkgs-unstable, yt-x, ... }:
  let
    system = "x86_64-linux";

    unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

    nur = import nur-repo { inherit pkgs; }; 

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
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

          home-manager.users = import ./common/home-manager.nix { inherit pkgs nur secretSrc; };
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
