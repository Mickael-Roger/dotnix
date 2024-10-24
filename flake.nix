{
  description = "Mickael NixOS configuration for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  # Ensure Home Manager uses the same nixpkgs

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";  # Ensure NUR uses the same nixpkgs

    ctfmgntSrc = { 
      url = "github:Mickael-Roger/ctf-mgnt/0.3";
      flake = false;
    };

    esp32-idf-src = { 
      url = "github:mirrexagon/nixpkgs-esp-dev";
      flake = false;
    };

    secretSrc = { 
      url = "git+ssh://git@github.com/Mickael-Roger/secrets";
      flake = false;
    };


  };

  outputs = { self, nixpkgs, home-manager, nur, ctfmgntSrc, esp32-idf-src, secretSrc, nixpkgs-unstable, ... }: 
  let

    secrets = if builtins.pathExists ./secrets.nix
                then import ./secrets.nix
                else {};   
    unstable = import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };

  in {

    nixosConfigurations = {
      
      # Home server configuration
      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/server/configuration.nix
          ./hosts/server/hardware-configuration.nix
          home-manager.nixosModules.home-manager
        ];

        specialArgs = { inherit ctfmgntSrc esp32-idf-src secretSrc unstable; };

      };

      # Dell XPS
      xps-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/xps-laptop/configuration.nix
          ./hosts/xps-laptop/hardware-configuration.nix
          home-manager.nixosModules.home-manager
        ];

        specialArgs = { inherit ctfmgntSrc esp32-idf-src secretSrc unstable; };

      };

    };

    homeConfigurations = {
      # Example user on the server system
      mickael = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./common/home-manager.nix
        ];
        specialArgs = { inherit nur; };  # Pass NUR to the Home Manager configuration
      };
    };

  };
}
