{ inputs, ... } :

name:
{
  system,
  darwin ? false,
  colmenaHive ? false,
}:

let

  nodes = if builtins.isList name then name else [];
  colmenaOutput = (nodes != []) && colmenaHive;
  nodeBootstrap = (nodes != []) && !colmenaHive;

  machineConf = ../hosts/${if darwin then "darwin" else "nixos" }.nix;

  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
  # home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  # The basic imports for bootstrapping servers before updating age keys for sops secrets
  serverBootstrapModules = name : [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ../hardware/${name}/hardware-configuration.nix
    ../homelab/disk-config.nix
    ../homelab/configuration.nix
    { networking.hostName = name; }
  ];

  # Imports for everything requiring sops secrets
  serverModules = name : serverBootstrapModules name ++ [
    ../homelab/k3s/k3s.nix
  ];

  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

in
if !colmenaOutput then
if !nodeBootstrap then
systemFunc {
  inherit system;
  modules = [
    {
      nixpkgs = {
        config.allowUnfree = true;
      };
    }
  ] ++ [
    machineConf
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.infinitive = import ../user/home.nix;
      home-manager.extraSpecialArgs = { inherit darwin; };
      home-manager.backupFileExtension = "hmbak";
    }
  ];
}
else
inputs.nixpkgs.lib.genAttrs nodes (name:
  systemFunc {
    inherit system;
    modules = serverBootstrapModules name;
  }
)
else inputs.colmena.lib.makeHive (
  {
    meta = {
      nixpkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        overlays = [];
      };
    };
  }
  //
  (
    inputs.nixpkgs.lib.genAttrs nodes (name:
      {
        deployment = {
          targetHost = name;
          buildOnTarget = true;
        };
        imports = serverModules name;
      }
    )
  )
)
