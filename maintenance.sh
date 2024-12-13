#!/bin/sh
sudo nix-collect-garbage -d
sudo nix store verify --all
sudo nix store repair --all
nix flake update
sudo nixos-rebuild switch --flake . --upgrade
# nix run nixpkgs#bleachbit # system cleaning: tmpfiles, backups,  history, etc
# nix run nixpkgs#pcmanfm # file manager to inspect results
