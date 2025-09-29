My NixOS configuration and home-manager config as a flake.

To build and install, use `sudo nixos-rebuild switch --flake .` or `nh os switch .`

To search, use `nh search`; To clean use `nh clean`.

To see nix documentation and options, use `manix` (uses channels, see `manix --update-cache` for more)

To see which packages use the most space, use `nix-tree`

To scan for vulnerabilities, use `, vulnix --system` (not installed by default)
