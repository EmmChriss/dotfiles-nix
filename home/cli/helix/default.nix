{
  pkgs,
  lib,
  ...
}: {
  programs.helix = {
    enable = true;
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
        rulers = [
          80
          120
          160
        ];
        bufferline = "multiple";
        trim-trailing-whitespace = true;
        file-picker.hidden = false;
        lsp.display-progress-messages = true;
        whitespace.render = "none";
        indent-guides = {
          render = true;
          character = "╎";
        };
        smart-tab.enable = false;
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "disable";
        };
      };
      keys.normal = {
        # C-arrow movement
        C-left = "move_prev_word_start";
        C-right = "move_next_word_start";

        # swap yanking and non-yanking delete and change
        d = "delete_selection_noyank";
        A-d = "delete_selection";
        c = "change_selection_noyank";
        A-c = "change_selection";

        # join and yank to clipboard
        space.y = "yank_joined_to_clipboard";

        # Print the current line's git blame information to the statusline.
        space.B = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
      };
      keys.insert = {
        C-left = "move_prev_word_start";
        C-right = "move_next_word_start";
      };
    };
    languages.language = [
      {
        name = "scss";
        language-servers = [
          {name = "some-sass-language-server";}
        ];
      }
      {
        name = "css";
        language-servers = [
          {name = "some-sass-language-server";}
        ];
      }
    ];
    languages.language-server = {
      typescript-language-server = {
        command = "${lib.getExe pkgs.bun}";
        args = [
          "--smol"
          "${pkgs.typescript-language-server}/lib/node_modules/typescript-language-server/lib/cli.mjs"
          "--stdio"
        ];
      };
      some-sass-language-server = {
        command = "some-sass-language-server --stdio";
        args = ["--stdio"];
        # see https://wkillerud.github.io/some-sass/language-server/settings.html for all available settings
        config.somesass.workspace.loadPaths = [];
      };
    };
  };
}
