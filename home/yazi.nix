{ pkgs, ... }:

let
  yazi-plugins = pkgs.fetchFromGitHub {
		owner = "yazi-rs";
		repo = "plugins";
		rev = "7afba3a73cdd69f346408b77ea5aac26fe09e551";
    hash = "sha256-w9dSXW0NpgMOTnBlL/tzlNSCyRpZNT4XIcWZW5NlIUQ=";
	};
  yazi-fuse-archive = pkgs.fetchFromGitHub {
    owner = "dawsers";
    repo = "fuse-archive.yazi";
    rev = "62d30df316f121468a6ba59332dd83231af54488";
    hash = "sha256-zTpOiXqHNtLHpz5DiHRpH/3KCGs2iAMs452a1hfIknU=";
  };
  yazi-ouch = pkgs.fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "b8698865a0b1c7c1b65b91bcadf18441498768e6";
    hash = "sha256-eRjdcBJY5RHbbggnMHkcIXUF8Sj2nhD/o7+K3vD3hHY=";
  };
in
{
  home.packages = with pkgs; [
    # file type detection
    file
  
    # json preview
    jq

    # file searching
    fd

    # file content searching
    ripgrep

    # extra navigation
    fzf

    # mount/unmount archive files
    fuse-archive

    # compress files
    ouch
  ];

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    shellWrapperName = "y";

    plugins = {
      chmod = "${yazi-plugins}/chmod.yazi";
      max-preview = "${yazi-plugins}/max-preview.yazi";
      fuse-archive = yazi-fuse-archive;
      ouch = yazi-ouch;
    };

    initLua = ''
      -- Some plugins need initialization
      require("fuse-archive"):setup({ smart_enter = true })
    '';

    settings = {
      log.enabled = true;

      # default openers:
      # open: xdg-open; edit: $EDITOR; reveal: xdg-open $(dirname $1)
      opener = {
        # use vlc to open video files
        play = [
          { run = ''vlc "$@"''; orphan = true; desc = "VLC"; }
        ];
        # use pqiv to open image files
        view = [
          { run = ''pqiv "$@"''; orphan = true; desc = "Image viewer"; }
        ];
        # remove extract option
        extract = [];
      };
      open = {
        prepend_rules = [
          # option to open text files
          { name = "*.html"; use = ["edit" "open" "reveal"]; }
          { mime = "text/*"; use = ["edit" "open" "reveal"]; }
          { mime = "application/json"; use = ["edit" "open" "reveal"]; }
          { name = "*.json"; use = ["edit" "open" "reveal"]; }
          { mime = "inode/empty"; use = ["edit" "open" "reveal"]; }

          # open video files in vlc
          { mime = "{audio,video}/*"; use = ["play" "open" "reveal"]; }

          # open images in pqiv
          { mime = "image/*"; use = ["view" "open" "reveal"]; }

          # fallback: choose your weapon
          { name = "*"; use = ["open" "reveal" "edit" "view" "play"]; }
        ];
      };
    };

    keymap = {
      manager.prepend_keymap = [
        # transparently enter/leave archive files
        { on = "<Right>"; run = "plugin fuse-archive --args=mount"; desc = "Enter or Mount selected archive"; }
        { on = "<Left>"; run = "plugin fuse-archive --args=unmount"; desc = "Leave or Unmount selected archive"; }

        # compress files
        { on = ["C" "z"]; run = "plugin ouch --args=zip"; desc = "Compress files to ZIP"; }
        { on = ["C" "t"]; run = "plugin ouch --args=tar.gz"; desc = "Compress files to ZIP"; }
      
        # maximize preview
        { on = "i"; run = "plugin max-preview"; desc = "Maximize or restore preview"; }

        # seek only one line in preview
        { on = "K"; run = "seek -1"; desc = "Seek up 1 units in the preview"; }
        { on = "J"; run = "seek +1"; desc = "Seek down 1 units in the preview"; }
      
        # interactively run shell command on '$'
        { on = "$"; run = "shell --block --interactive"; desc = "Alias to ':'"; }

        # open to (e)dit
        { on = "e"; run = "open --hovered"; desc = "Open selected file"; }
        { on = "E"; run = "open --hovered --interactive"; desc = "Open selected file with.."; }

        # instead of opening, at least confirm
        { on = "<Enter>"; run = "open --interactive"; desc = "Open with .."; }
      
        # boomarks
        { on = ["g" "d"]; run = "cd /mnt/data"; desc = "Bookmark: Data partition"; }
        { on = ["g" "w"]; run = "cd /mnt/win"; desc = "Bookmark: Win partition"; }
        { on = ["g" "p"]; run = "cd ~/Media/Pictures"; desc = "Bookmark: Pictures"; }
        { on = ["g" "c"]; run = "cd ~/.config"; desc = "Bookmark: Config"; }
        { on = ["g" "n"]; run = "cd ~/nix"; desc = "Bookmark: Nix Config"; }
      ];
    };
  };
}
