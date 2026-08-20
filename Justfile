hm-news:
    home-manager news --flake .

update:
    nix flake update && nix flake archive

os:
    nh os switch . --fallback --show-activation-logs --use-substitutes

home:
    nh home switch . --fallback --show-activation-logs --use-substitutes

upgrade: format update boot home clean

os-rollback:
    nh os rollback

home-rollback:
    home-manager switch --rollback --flake .

boot:
    nh os boot . --fallback --show-activation-logs --use-substitutes

test:
    nh os test . --fallback --show-activation-logs --use-substitutes

repair:
    nix-store --verify --repair --check-contents

clean:
    sudo journalctl --rotate --vacuum-time=48h
    nh clean all --optimise --ask --keep-since 2d
    just repair

clean-all:
    sudo journalctl --rotate --vacuum-time=1h
    nh clean all --optimise --ask --keep 2
    just repair

format:
    nix fmt -- .
