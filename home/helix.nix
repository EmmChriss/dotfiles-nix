{ pkgs, ... }:

# TODO: maybe colorize
# TODO: try nixd instead of nil
# NOTE: could not get helix to use nixd instead of nil last time
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.marksman
      # pkgs.nixd
      pkgs.nil
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
        rulers = [80 100 120 160];
        bufferline = "multiple";
        file-picker.hidden = false;
        lsp.display-messages = true;
        whitespace.render = "none";
        indent-guides = {
          render = true;
          character = "╎";
        };
      };
      keys.normal = {
        # swap yanking and non-yanking delete and change
        d = "delete_selection_noyank";
        A-d = "delete_selection";
        c = "change_selection_noyank";
        A-c = "change_selection";

        # join and yank to clipboard
        space.y = ":clipboard-yank-join";
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
