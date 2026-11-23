{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:nix-community/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, colmena, sops-nix, flake-utils, home-manager, ... }@ inputs :
    # Define k3s nodes
    let nodes = [
      "mirax-nix"
      "nolax-nix"
      "sonax-nix"
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit inputs;
    };

    in
    {
      # Install the server nodes using nixos-anywhere
      # nixos-anywhere --flake .#<nodename> --generate-hardware-config nixos-generate-config ./hardware/<nodename>/hardware-configuration.nix --build-on remote <hostname>
      nixosConfigurations = mkSystem nodes {
        system = "x86_64-linux";
      };

      # Colmena hive configuration to manage the servers after install
      colmenaHive = mkSystem nodes {
        system = "x86_64-linux";
        colmenaHive = true;
      };

      darwinConfigurations.air = mkSystem "air" {
        system = "aarch64-darwin";
        darwin = true;
      };
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixos-anywhere
            neovim
            ssh-to-age
            sops
            age
            helmfile
            git
            kubectl
          ] ++ [
            pkgs.colmena
          ];
        };
      }
    );

}
