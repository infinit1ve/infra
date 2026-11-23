{ config, pkgs, darwin, lib, ... }:
let

  homeDir = if darwin then "/Users/infinitive" else "/home/infinitive";

in {
  home.username = "infinitive";
  home.homeDirectory = lib.mkForce (homeDir);

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    helmfile
    neovim
    nixos-anywhere
    colmena
    ssh-to-age
    sops
    age
    git
    btop
    fastfetch
    kubectl
    kubernetes-helm
    fortune
    cowsay
    lolcat
  ];

  home.file = {
    ".config/linearmouse/linearmouse.json" = {
      enable = darwin;
      source = ./dotfiles/linearmouse.json;
    };
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = lib.importTOML ./dotfiles/starship.toml;
    };

    zsh = {
      enable = true;
      shellAliases = {
        k = "kubectl";
        ha = "helmfile apply";
        hs = "helmfile sync";
      };
      initContent = ''
        export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
      '';
    };

    zed-editor = {
      enable = true;
      userSettings = lib.importJSON ./dotfiles/zed.json;
    };

    git = {
      enable = true;
      settings = {
        user.name = "Maksym Tarashchan";
        user.email = "contact@infinitive.cc";
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = ""; # needs to be empty to use terminal for ask pass
        credential.helper = "store";
        github.user = "infinit1ve";
        push.default = "tracking";
        init.defaultBranch = "main";
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "Host *" = {
          AddKeysToAgent = "yes";
          StrictHostKeyChecking = "accept-new";
        };
        "Host *-nix" = {
          User = "root";
          IdentityFile = "~/.ssh/id_ed25519_sk_primary";
          IdentitiesOnly = "yes";
          IdentityAgent = "none";
          SecurityKeyProvider = "internal";
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h:%p";
          ControlPersist = "10m";
        };
      };
    };
  };
}
