{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot = {
    loader.grub = {
      # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      # devices = [ ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "iscsi_tcp" ];
  };

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    qemuGuest.enable = true;
    openiscsi = {
      enable = true;
      name = "iqn.2026-11.local.home:${config.networking.hostName}";
    };
  };

  # Longhorn fix
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  environment.systemPackages = with pkgs; (map lib.lowPrio [
    curl
    gitMinimal
    ssh-to-age
    nfs-utils
    openiscsi
    util-linux
    bash
    e2fsprogs
  ]);

  users.users.root = {
    openssh.authorizedKeys.keys =
    [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEa8nGQwd5Mbod2sCiLkNxbpGK2AZ6iwusxknoK9sJ54AAAABHNzaDo= yubikey-primary"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFZQUZtJ7hZdel51cXhIFUpUObofEzWgtSmUNGAly4JOAAAABHNzaDo= yubikey-backup"
    ] ++ (args.extraPublicKeys or []);
  };

  system.stateVersion = "26.05";

  # Automatic cleanup
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
}
