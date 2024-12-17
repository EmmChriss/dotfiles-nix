{ ... }:

# TODO: look into why there is no config file generating
{
  programs.pqiv = {
    enable = true;
    settings.options = {
      lazy-load = 1;
      background-pattern = "black";
      command-1 = "thunar";
      auto-montage-mode = 1;
      low-memory = 1;
      watch-files = "off";
      browse = 1;
    };
    extraConfig = ''
    [keybindings]
    <Return> { montage_mode_enter() }
    '';
  };
}
