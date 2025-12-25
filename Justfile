hm-news:
    home-manager news --flake .

update:
    nix flake update && nix flake archive

os:
    nh os switch . --fallback

home:
    nh home switch . --fallback

os-rollback:
    nh os rollback

home-rollback:
    home-manager switch --rollback --flake .

boot:
    nh os boot . --fallback

test:
    nh os test . --fallback

repair:
    nix-store --verify --repair --check-contents

clean:
    sudo journalctl --rotate --vacuum-time=48h
    nh clean all --optimise --ask --keep-since 2d
    just repair

clean-all:
    sudo journalctl --rotate --vacuum-time=1h
    nh clean all --optimise --ask
    just repair

format:
    nix fmt -- .
