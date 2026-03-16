{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, sops-nix, disko, home-manager, ... }: {
    nixosConfigurations = let commonModules = [
      ./configuration.nix
      disko.nixosModules.disko
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.lucy = ./home.nix;
      }
    ];
    cerberusModules = commonModules ++ [
      ./cerberus/shared.nix
    ]; in {  
      cerberus-0 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = cerberusModules ++ [
          ./cerberus/cerberus-init/config.nix
        ];
      };
      cerberus-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = cerberusModules ++ [
          ./cerberus/cerberus-worker/config.nix
          ./node-configs/cerberus-1.nix
        ];
      };
      cerberus-2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = cerberusModules ++ [
          ./cerberus/cerberus-worker/config.nix
          ./node-configs/cerberus-2.nix
        ];
      };
      heimdall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./heimdall/heimdall.nix
        ];
      };
    };
  };
}
