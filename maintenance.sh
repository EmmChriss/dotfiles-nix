#!/bin/sh
nix flake update
sudo nixos-rebuild switch --flake . --upgrade
sudo nix-collect-garbage -d
sudo nix store optimise
sudo nix store verify --all
sudo nix store repair --all
nix run nixpkgs#bleachbit # system cleaning: tmpfiles, backups, history, etc
# nix run nixpkgs#pcmanfm # file manager to inspect results
