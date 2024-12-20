{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Volume control; requires pactl
    pulseaudio
    (writeShellScriptBin "vol" (builtins.readFile ./scripts/vol))
    # Preview files in terminal
    (writeShellScriptBin "preview" (builtins.readFile ./scripts/preview))
    # Rapid-charge mode for Lenovo laptops
    (writeShellScriptBin "ideapad-rc" (builtins.readFile ./scripts/ideapad-rc))
    # Reload YADM git repo; prepare to sync stuff
    (writeShellScriptBin "yadm-reload" (builtins.readFile ./scripts/yadm-reload))
  ];
}
