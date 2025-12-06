{pkgs, ...}: {
  programs.tofi = {
    enable = true;
    settings = {
      width = "100%";
      height = "100%";
      border-width = "0";
      outline-width = "0";
      padding-left = "40%";
      padding-top = "35%";
      result-spacing = "25";
      num-results = "5";
      font = "${pkgs.open-fonts}/share/fonts/truetype/NotoSansMono-Regular.ttf";
      hint-font = "false";
      background-color = "#000A";
      input-color = "#88c0d0";
      hide-cursor = "true";
      text-cursor = "true";
      text-cursor-style = "block";
      text-cursor-corner-radius = "3";
      text-cursor-thickness = "5";
      fuzzy-match = "true";
    };
  };
}
