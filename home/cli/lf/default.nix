{
  lib,
  pkgs,
  ...
}: let
  preview = pkgs.writeShellApplication {
    name = "preview.sh";
    runtimeInputs = with pkgs; [coreutils file bat ouch exiftool jq];
    text = builtins.readFile ./preview.sh;
  };
in {
  home.packages = with pkgs; [preview eza fzf vimv-rs fd tree];

  programs.fish.interactiveShellInit = ''
    function lfcd --wraps="lf" --description="lf - Terminal file manager (changing directory on exit)"
      # `command` is needed in case `lfcd` is aliased to `lf`.
      # Quotes will cause `cd` to not change directory if `lf` prints nothing to stdout due to an error.
      cd "$(command lf -print-last-dir $argv)"
    end

    # do this by default
    alias lf=lfcd

    # ctrl-f to open file manager
    bind \cf 'lf; commandline -f repaint'
  '';

  xdg.configFile."lf/colors".source = ./colors;
  xdg.configFile."lf/icons".source = ./icons;

  programs.lf = {
    enable = true;
    previewer = {
      keybinding = "i";
      source = lib.getExe preview;
    };
    settings = {
      icons = true;
      incfilter = true;
      incsearch = true;
      cursorpreviewfmt = "\\033[7;2m";
    };
    keybindings = {
      "<enter>" = "shell";
      "." = "set hidden!";

      R = "bulk-rename";
      D = "delete";
      f = "filter";
      x = "extract";
      Z = "fzf_jump";

      # goto
      gL = "follow-link";
      gM = "goto-file";
      "g<space>" = "push :cd<space>";

      # copy stuff about file
      Yf = "yank-file";
      Yp = "yank-paths";
      Yd = "yank-dirname";
      Yb = "yank-basename";
      YB = "yank-basename-without-extension";
    };
    extraConfig = builtins.readFile ./lfrc;
  };
}
