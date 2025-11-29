{
  description = "Mickael NixOS configuration for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    oldnixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  # Ensure Home Manager uses the same nixpkgs

    nur-repo.url = "github:nix-community/NUR";
    #nur.inputs.nixpkgs.follows = "nixpkgs";  # Ensure NUR uses the same nixpkgs

    ctfmgntSrc = { 
      url = "github:Mickael-Roger/ctf-mgnt/0.3";
      flake = false;
    };

    secretSrc = { 
      url = "git+ssh://git@github.com/Mickael-Roger/secrets";
      flake = false;
    };


  };

  outputs = { self, nixpkgs, home-manager, nur-repo, ctfmgntSrc, secretSrc, nixpkgs-unstable, oldnixpkgs, ... }: 
  let

    secrets = if builtins.pathExists ./secrets.nix
                then import ./secrets.nix
                else {};   

    unstable = import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };
    oldnixpkgs = import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };

    nur = import nur-repo { inherit pkgs; }; 

    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };


  in {

    nixosConfigurations = {
      
      # Home server configuration
      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/server/configuration.nix
          ./hosts/server/hardware-configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users = import ./common/home-manager.nix { inherit pkgs nur secretSrc;};

            home-manager.extraSpecialArgs = { inherit nur pkgs secretSrc; };  # Pass NUR to the Home Manager configuration
          } 
        ];

        specialArgs = { inherit ctfmgntSrc secretSrc unstable nixpkgs oldnixpkgs; };

      };

      # Dell XPS
      xps-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/xps-laptop/configuration.nix
          ./hosts/xps-laptop/hardware-configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users = import ./common/home-manager.nix { inherit pkgs nur secretSrc;};

            home-manager.extraSpecialArgs = { inherit nur pkgs secretSrc; };  # Pass NUR to the Home Manager configuration
          } 
        ];

        specialArgs = { inherit ctfmgntSrc secretSrc unstable oldnixpkgs; };

      };

    };

  };
}
