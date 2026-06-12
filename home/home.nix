{...}: {
  imports = [
    ./gui
    ./cli
    ./bin
    ./dev
    ./desktop
  ];

  home = {
    username = "morga";
    homeDirectory = "/home/morga";

    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      PAGER = "less";
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      setSessionVariables = true;
      videos = "$HOME/Media/Videos";
      music = "$HOME/Media/Music";
      pictures = "$HOME/Media/Pictures";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # DO NOT CHANGE
  home.stateVersion = "24.11";
}
