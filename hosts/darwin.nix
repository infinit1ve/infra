{ pkgs, homebrew, ... }:
{
  imports = [
    ./base.nix
  ];

  system = {
    stateVersion = 6;
    primaryUser = "infinitive";

    defaults = {
      NSGlobalDomain = {
        AppleICUForce24HourTime = false;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleInterfaceStyleSwitchesAutomatically = true;
      };
      menuExtraClock = {
        ShowDate = 0;
        Show24Hour = false;
        ShowAMPM = true;
      };
      dock = {
        tilesize = 62;
        largesize = 66;
        autohide = false;
        mru-spaces = false;
        orientation = "bottom";
        show-recents = false;
        showAppExposeGestureEnabled = false;
        persistent-apps = [
          {
            app = "/System/Cryptexes/App/System/Applications/Safari.app";
          }
          {
            app = "/Applications/Nix Apps/Beeper Desktop.app";
          }
          {
            app = "/Applications/Nix Apps/Discord.app";
          }
          {
            app = "/Applications/Things3.app";
          }
          {
            app = "/System/Applications/Mail.app";
          }
          {
            app = "/System/Applications/Calendar.app";
          }
          {
            app = "/System/Library/CoreServices/Siri.app";
          }
          {
            app = "/Applications/Nix Apps/Feishin.app";
          }
          {
            app = "/Applications/Xcode.app";
          }
          {
            app = "/Applications/Nix Apps/Zed.app";
          }
          {
            app = "/System/Applications/Utilities/Terminal.app";
          }
        ];
      };
      trackpad = {
        Clicking = true;
        TrackpadPinch = true;
        TrackpadRotate = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerVertSwipeGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadThreeFingerHorizSwipeGesture = 2;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };
      finder = {
        ShowPathbar = true;
        CreateDesktop = false;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "Nlsv";
      };
      controlcenter.BatteryShowPercentage = true;
      screencapture.target = "clipboard";
      loginwindow.GuestEnabled = false;
      iCal = {
        "first day of week" = "Monday";
        CalendarSidebarShown = false;
      };
      WindowManager.EnableStandardClickToShowDesktop = false;
    };
  };

  security = {
    pam = {
      services = {
        sudo_local = {
          enable = true;
          reattach = true;
          touchIdAuth = true;
          watchIdAuth = true;
        };
      };
    };
  };

  homebrew = {
    enable = true;
    user = "infinitive";
    brews = [
      "mas"
      "helm"
    ];
    casks = [
      "anki"
      "alcove"
      "alt-tab"
      "darkmodebuddy"
      "figma"
      "hyperkey"
      "linearmouse"
      "telegram-desktop"
      "microsoft-teams"
      "nextcloud"
      "steam"
    ];
    masApps = {
      # "Goodnotes" = 1444383602;
      # "xcode" = 497799835;
      # "Keynote" = 361285480;
      # "Numbers" = 361304891;
      # "Pages" = 361309726;
      # "TestFlight" = 899247664;
    };
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };
}
