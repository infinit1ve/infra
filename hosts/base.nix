{ pkgs, ...} :
{
  environment.systemPackages = with pkgs; [
    beeper
    bitwarden-desktop
    discord
    firefox
    tailscale
    zed-editor
    feishin
    prismlauncher

    tailscale
    openssh
    libfido2
  ];

  nix.settings.experimental-features = "nix-command flakes";
}
