# Helmfiles
I decided to control my cluster with Helmfiles since they are much less overhead than something like ArgoCD for my use case.

Currently I run things like Paperless-ngx, Navidrome and others, all on top of the wonderful [bjw-s/app-template](https://github.com/bjw-s-labs/helm-charts). Each folder under `./values/` contains their own helmfiles to keep everything separated and to prevent having an enormous singular helmfile.yaml. Instead, those smaller Helmfiles get imported in the main one.

## Installing
Having [the helmfile cli](https://github.com/helmfile/helmfile) installed is a prerequisite, as well as managing secrets via [sops](https://github.com/getsops/sops). If you are using the nix package manager, this repo contains a devshell with everything required installed. You can access it with
```
nix develop
```
If you are installing anything requiring PostgreSQL, I would recommend looking into [CloudnativePG](https://github.com/cloudnative-pg/cloudnative-pg), the services here use it, so sync the cnpg helmfile contents first to install its CRDs.
```
cd values/cnpg && helmfile sync
```
After a successful sync, look through the services you want to install and make sure you set up the secrets in `secrets/secrets.yaml`. A line like `.Values.services.email.user` in Go templates translates to the following secrets.yaml structure
```
services:
    email:
        user: <your-username>
```
The secrets get injected through the helmfiles, so make sure the yaml files requiring them are Go templates ending with `.gotmpl` and the helmfiles have a block like
```
environments:
  default:
    secrets:
      - ../../secrets/secrets.yaml
```
For the full secrets structure I use, consult the `secrets.example.yaml`. If you also want to use [bitwarden-portal](https://github.com/baragoon/bitwarden-portal), create a separate sops secrets file next to its values file, an example is also there.

For the first setup after CNPG, use
```
helmfile sync
```
From that point onward use
```
helmfile apply
```
