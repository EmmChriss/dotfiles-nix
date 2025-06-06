{ ... }:

# TODO: add central colorscheme
# TODO: add autostarting daemon
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 14;
        normal = {
          family = "IosevkaTerm NFM";
          style = "Regular";
        };
      };
    
      colors = {
        draw_bold_text_with_bright_colors = true;
        bright = {
          black = "0x4C566A";
          blue = "0x81A1C1";
          cyan = "0x8FBCBB";
          green = "0xA3BE8C";
          magenta = "0xB48EAD";
          red = "0xBF616A";
          white = "0xECEFF4";
          yellow = "0xEBCB8B";
        };

        cursor = {
          cursor = "0xD8DEE9";
          text = "0x2E3440";
        };

        normal = {
          black = "0x3B4252";
          blue = "0x81A1C1";
          cyan = "0x88C0D0";
          green = "0xA3BE8C";
          magenta = "0xB48EAD";
          red = "0xBF616A";
          white = "0xE5E9F0";
          yellow = "0xEBCB8B";
        };

        primary = {
          background = "0x15171b";
          foreground = "0xD8DEE9";
        };
      };
    };
  };
}
