{pkgs, ...}: let
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
in {
  # Generated theme
  # To customize, see: https://github.com/lpnh/icons-brew.yazi
  xdg.configFile."yazi/theme.toml".source = ./config/yazi-theme-catppuccin.toml;

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

    # drag and drop
    xdragon
  ];

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    shellWrapperName = "y";

    plugins = {
      chmod = "${yazi-plugins}/chmod.yazi";
      max-preview = "${yazi-plugins}/max-preview.yazi";
      git = "${yazi-plugins}/git.yazi";
      fuse-archive = yazi-fuse-archive;
      ouch = yazi-ouch;
    };

    initLua = ''
      -- Initialize plugins at startup
      require("git"):setup()
      require("fuse-archive"):setup({ smart_enter = true })

      -- Header: show username/hostname
      Header:children_add(function()
      	if ya.target_family() ~= "unix" then
      		return ""
      	end
      	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
      end, 500, Header.LEFT)

      -- Status: show symbolic link
      function Status:name()
      	local h = self._current.hovered
      	if not h then
      		return ""
      	end

      	return " " .. h.name:gsub("\r", "?", 1)
      end

      -- Status: show user:group
      Status:children_add(function()
      	local h = cx.active.current.hovered
      	if h == nil or ya.target_family() ~= "unix" then
      		return ""
      	end

      	return ui.Line {
      		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
      		":",
      		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
      		" ",
      	}
      end, 500, Status.RIGHT)

    '';

    settings = {
      log.enabled = true;

      # default openers:
      # open: xdg-open; edit: $EDITOR; reveal: xdg-open $(dirname $1)
      opener = {
        # use vlc to open video files
        play = [
          {
            run = ''vlc "$@"'';
            orphan = true;
            desc = "VLC";
          }
        ];
        # use pqiv to open image files
        view = [
          {
            run = ''pqiv "$@"'';
            orphan = true;
            desc = "Image viewer";
          }
        ];
        # decompress using ouch
        extract = [
          {
            run = ''ouch decompress $@'';
            desc = "Extract archive";
          }
        ];
      };
      open = {
        prepend_rules = [
          # option to open text files
          {
            name = "*.html";
            use = ["edit" "open" "reveal"];
          }
          {
            mime = "text/*";
            use = ["edit" "open" "reveal"];
          }
          {
            mime = "application/json";
            use = ["edit" "open" "reveal"];
          }
          {
            name = "*.json";
            use = ["edit" "open" "reveal"];
          }
          {
            mime = "inode/empty";
            use = ["edit" "open" "reveal"];
          }

          # open video files in vlc
          {
            mime = "{audio,video}/*";
            use = ["play" "open" "reveal"];
          }

          # open images in pqiv
          {
            mime = "image/*";
            use = ["view" "open" "reveal"];
          }

          # fallback: choose your weapon
          {
            name = "*";
            use = ["open" "reveal" "edit" "view" "play"];
          }
        ];
      };
      plugin.prepend_fetchers = [
        # Fetch git status of files and folders using git plugin
        {
          id = "git";
          name = "*";
          run = "git";
        }
        {
          id = "git";
          name = "*/";
          run = "git";
        }
      ];
    };

    keymap = {
      manager.prepend_keymap = [
        # drop to shell
        {
          on = "!";
          run = ''shell "$SHELL" --block'';
          desc = "Open shell here";
        }

        # follow symlink
        {
          on = ["g" "l"];
          run = ''shell 'ya emit cd "$(readlink -f "$1")"' '';
          desc = "Follow hovered symlink";
        }

        # drag and drop files
        {
          on = "<C-n>";
          run = ''shell 'dragon -x -i -T "$@"' '';
          desc = "Drag and drop selection";
        }

        # transparently enter/leave archive files
        {
          on = "<Right>";
          run = "plugin fuse-archive --args=mount";
          desc = "Enter or Mount selected archive";
        }
        {
          on = "<Left>";
          run = "plugin fuse-archive --args=unmount";
          desc = "Leave or Unmount selected archive";
        }

        # compress files
        {
          on = ["C" "z"];
          run = "plugin ouch --args=zip";
          desc = "Compress files to ZIP";
        }
        {
          on = ["C" "t"];
          run = "plugin ouch --args=tar.gz";
          desc = "Compress files to ZIP";
        }

        # maximize preview
        {
          on = "i";
          run = "plugin max-preview";
          desc = "Maximize or restore preview";
        }

        # seek only one line in preview
        {
          on = "K";
          run = "seek -1";
          desc = "Seek up 1 units in the preview";
        }
        {
          on = "J";
          run = "seek +1";
          desc = "Seek down 1 units in the preview";
        }

        # interactively run shell command on '$'
        {
          on = "$";
          run = "shell --block --interactive";
          desc = "Interactively run shell command; alias to ':'";
        }

        # open to (e)dit
        {
          on = "e";
          run = "open --hovered";
          desc = "Open selected file";
        }
        {
          on = "E";
          run = "open --hovered --interactive";
          desc = "Open selected file with..";
        }

        # instead of opening, at least confirm
        {
          on = "<Enter>";
          run = "open --interactive";
          desc = "Open with ..";
        }

        # boomarks
        {
          on = ["g" "d"];
          run = "cd /mnt/data";
          desc = "Bookmark: Data partition";
        }
        {
          on = ["g" "w"];
          run = "cd /mnt/win";
          desc = "Bookmark: Win partition";
        }
        {
          on = ["g" "m"];
          run = "cd ~/Media";
          desc = "Bookmark: Media";
        }
        {
          on = ["g" "s"];
          run = "cd ~/Media/Pictures/Screenshots/";
          desc = "Bookmark: Screenshots";
        }
        {
          on = ["g" "c"];
          run = "cd ~/.config";
          desc = "Bookmark: Config";
        }
        {
          on = ["g" "n"];
          run = "cd ~/nix";
          desc = "Bookmark: Nix Config";
        }
      ];

      input.prepend_keymap = [
        {
          on = "<Esc>";
          run = "close";
          desc = "Cancel input";
        }
      ];
    };
  };
}
