{ pkgs, lib, ... }:

# TODO: maybe colorize
# TODO: try nixd instead of nil
# NOTE: could not get helix to use nixd instead of nil last time
let
  yazi-picker = pkgs.writeShellApplication {
    name = "yazi-picker";
    runtimeInputs = with pkgs; [ yazi zellij ];
    text = ''
      paths=$(yazi --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)

      if [[ -n "$paths" ]]; then
      	zellij action toggle-floating-panes
      	zellij action write 27 # send <Escape> key
      	zellij action write-chars ":$1 $paths"
      	zellij action write 13 # send <Enter> key
      else
      	zellij action toggle-floating-panes
      fi
    '';
  };
  open-yazi-picker = pkgs.writeShellApplication {
    name = "open-yazi-picker";
    runtimeInputs = with pkgs; [ zellij yazi-picker ];
    text = ''
      zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- bash ${lib.getExe yazi-picker} open
    '';
  };
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # import script into user profile
      open-yazi-picker
    
      # marksman
      # nixd
      nil
      rust-analyzer
      # python312Packages.python-lsp-server
      # taplo # toml
      # zls
      # docker-langserver
      # docker-compose-langserver
      # elm-language-server
      # cmake-language-server
      # bash-language-server
      typescript-language-server
      # lua-language-server
      # yaml-language-server
      # llvmPackages_19.clang-tools # provides clangd
      gdtoolkit_4
    ];
    ignores = [
      "target/"
      "!.gitignore"
      "node_modules"
    ];
    settings = {
      theme = "onedark";
      editor = {
        mouse = false;
        color-modes = true;
        rulers = [80 120 160];
        bufferline = "multiple";
        file-picker.hidden = false;
        lsp = {
          display-messages = true;
          display-progress-messages = true;
        };
        whitespace.render = "none";
        indent-guides = {
          render = true;
          character = "╎";
        };
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "disable";
        };
      };
      keys.normal = {
        # swap yanking and non-yanking delete and change
        d = "delete_selection_noyank";
        A-d = "delete_selection";
        c = "change_selection_noyank";
        A-c = "change_selection";

        space = {
          # join and yank to clipboard
          y = ":clipboard-yank-join";

          # file picker in yazi with zellij
          z = ":sh open-yazi-picker";
        };
      };
    };
    languages = {
      # language server definitions
      language-server = {
        # nixd.command = "${pkgs.nixd}/bin/nixd";
        nil.command = "${pkgs.nil}/bin/nil";
      };

      # language configurations
      languages = [
        { name = "nix"; language-servers = [ "nixd" ]; }
      ];
    };
  };
}
