#!/bin/sh
nix flake update
nix flake archive
nh os switch .
nh clean all --keep-since 1h # keep current generations, you can manually clean up afterwards
sudo nix store optimise
nix-store --verify --repair --check-contents
