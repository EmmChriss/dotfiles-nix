update:
    nix flake update && nix flake archive

switch:
    nh os switch . --fallback --repair

boot:
    nh os boot . --fallback --repair

clean:
    sudo journalctl --rotate --vacuum-time=48h
    nh clean all --optimise --ask --keep-since 2d
    nix-store --verify --repair --check-contents

clean-all:
    sudo journalctl --rotate --vacuum-time=1h
    nh clean all --optimise --ask
    nix-store --verify --repair --check-contents

format:
    nix fmt -- .
