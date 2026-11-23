# Declarative Configurations
This repo contains my configurations. I liked the idea of declaratively managing my devices so I started looking into nix and helmfiles to have reproducible states on my machines.

> Note: I just recently started using nix and helm so if you want to use my configs expect weird choices and perhaps spaghetti code. I am no expert in those areas.

## What do I use?
Currently my main workhorse is a macOS laptop where I mostly stick to GUI tools out of habit. After having to reset it once I realized how painful it is to have to install and setup everything from scratch. Thankfully I found out about [nix-darwin](https://github.com/nix-darwin/nix-darwin) and the rest is history.

Oh and I also wanted to play around with Kubernetes for the first time, so I decided to run my nodes in VMs with NixOS.

Currently there's just a darwin setup, but I also want to look into having a NixOS config down the line.

## Setup
### macOS
To get started with mac you will of course need the nix package manager you can find on [the nixos website](https://nixos.org/download/).

Once installed, copy this repo wherever you find appropriate and go through the files to replace the mentions of `infinitive` to a username you'd like to use, as well as any other configs you want to change.

After doing that run the following command to switch to a new nix generation. Keep in mind that **this repo contains my settings and apps and your system may get changed in a way you don't prefer**

```
sudo darwin-rebuild switch --flake .#air
```

### k3s
The kubernetes setup is separated in 2 steps, those steps being the system itself, and then k3s on top of it + the services.

You will need [the nix package manager](https://nixos.org/download/) on your system before you start.

First, copy the repo to a directory you want to use.

Then look into `homelab/configuration.nix` and change out the ssh keys to your own as well as timezone and locale settings.

Then you can change the hostnames of k3s nodes in `flake.nix`. The amount of strings in the array corresponds to the amount of nodes that you want to run.

If you don't have `nixos-anywhere`, `colmena`, and `ssh-to-age` installed, enter the developer shell with
```
nix develop
```
To begin installing nodes, boot them with the NixOS live installer and set a root password to turn on ssh.
```
sudo passwd
```
Then run the following command for each node replacing the `<nodename>` with one of the nodenames you defined in `flake.nix`, and `<ip>` with the node's IP. Keep in mind, this config does **not** set a static IP, since it relies on that being set through the router.
```
nixos-anywhere --flake .#<nodename> --generate-hardware-config nixos-generate-config ./hardware/<nodename>/hardware-configuration.nix --build-on remote root@<ip>
```
After installing, follow the steps to setup [sops-nix](https://github.com/Mic92/sops-nix). You will need to modify the `.sops.yaml` found in this repo and define your secrets under `secrets/secrets.yaml`. Both `sops` and `ssh-to-age` are already included in the developer shell.

For initial k3s setup, you will need to create a private token for k3s as following:
```
services:
    k3s:
        token: <your-token-here>
```

After doing that, make sure the `kube-vip` has the correct settings for your network, those being your subnet and the virtual IP address you'd want to use. Define those under `homelab/k3s/kube-vip.yaml`. Then change the IP in `homelab/k3s/k3s.nix` to the same virtual IP you just decided on, and switch out the hostname to one of your nodes you defined in `flake.nix` (look for comments in the file).

Once everything is set up, roll it out with 
```
colmena apply
```
When the command finishes running, ssh into one of the nodes and run
```
kubectl get nodes
```
to verify cluster status.

If you wish to control the cluster from your machine, copy the connection details. **Make sure you don't overwrite your exising configs.**
```
scp root@<hostname>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
```
and change the IP to the virtual IP you decided on earlier with your preferred editor
```
nvim ~/.kube/config
```
If you want to run the same services I do, check out the readme under `homelab/helm/`
