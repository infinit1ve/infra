{
  config,
  pkgs,
  ...
}:
{
  sops.secrets."services/k3s/token" = { };

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets."services/k3s/token".path;
    extraFlags = toString ([
	    "--cluster-init"
			"--disable servicelb"
			"--tls-san 10.12.3.200" # Change to your kube-vip virtual IP
    ] ++ (if config.networking.hostName == "mirax-nix" then [] else [ # Change the hostname string to a hostname of one of your nodes defined in flake.nix
	    "--server https://mirax-nix:6443" # Change it here too
    ]));
    clusterInit = (config.networking.hostName == "mirax-nix"); # As well as here
    manifests = {
      kube-vip.source = ./kube-vip.yaml;
      kube-vip-rbac.source = ./kube-vip-rbac.yaml;
      traefik-config.source = ./traefik-config.yaml;
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        80
        443
        2112
        6443
        2379
        2380
        10250
        5001
      ];
      allowedUDPPorts = [
        8472
      ];
    };
    usePredictableInterfaceNames = false;
  };
}
