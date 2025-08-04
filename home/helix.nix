{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # marksman
      # nixd
      nil
      # rust-analyzer # installed through rustup
      # python312Packages.python-lsp-server
      taplo # toml
      zls
      # docker-langserver
      # docker-compose-langserver
      # elm-language-server
      # cmake-language-server
      bash-language-server
      typescript-language-server
      lua-language-server
      yaml-language-server
      # llvmPackages_19.clang-tools # provides clangd
      gdtoolkit_4
    ];
    ignores = [
      "!.gitignore"
      "target"
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
          y = "yank_joined_to_clipboard";
        };
      };
    };
    languages = {
      # language server definitions
      language-server = {
        typescript-language-server = {
          command = "${lib.getExe pkgs.bun}";
          args = ["--smol" "${pkgs.typescript-language-server}/lib/node_modules/typescript-language-server/lib/cli.mjs" "--stdio"];
        };
      };
    };
  };
}
