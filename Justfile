update:
    nix flake update && nix flake archive

switch:
    nh os switch .

boot:
    nh os boot .

clean:
    journalctl --rotate --vacuum-time=48h
    nh clean all --optimise --ask --keep-since 2d
    nix-store --verify --repair --check-contents

clean-all:
    journalctl --rotate --vacuum-time=1h
    nh clean all --optimise --ask
    nix-store --verify --repair --check-contents

format:
    nix fmt -- .
