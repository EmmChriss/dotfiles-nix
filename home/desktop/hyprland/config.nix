{lib, ...}: let
  lua = lib.generators.mkLuaInline;
in {
  # See https://wiki.hypr.land/Configuring/Basics/Variables/
  wayland.windowManager.hyprland.settings.config = {
    debug = {
      disable_logs = true;
      disable_time = true;
    };

    general = {
      gaps_in = 3;
      gaps_out = 5;
      border_size = 1;
      col.active_border = lua ''{ colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 }'';
      col.inactive_border = "rgba(595959aa)";

      layout = "dwindle";
      no_focus_fallback = true;

      snap.enabled = true;
    };

    decoration = {
      rounding = 3;

      blur = {
        # enabled = true;
        enabled = false;
        size = 3;
        passes = 1;
      };

      shadow = {
        # enabled = true;
        enabled = false;
        # color = "rgba(1a1a1aee)";
      };
    };

    animations = {
      enabled = true;
      workspace_wraparound = true;
    };

    input = {
      # layout
      kb_layout = "us,hu,ro";
      kb_variant = ",qwerty";
      kb_model = "pc105";
      kb_options = "grp:shifts_toggle";
      kb_rules = "";

      # keyboard
      repeat_rate = 50;
      repeat_delay = 300;
      numlock_by_default = true;

      # touchpad
      scroll_method = "2fg";
      follow_mouse = 2;
      float_switch_override_focus = 2;

      touchpad = {
        tap_to_click = true;
        drag_lock = 2;
        natural_scroll = false;
      };
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      force_default_wallpaper = 0;
      vrr = 1;

      mouse_move_enables_dpms = true;
      key_press_enables_dpms = true;

      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;
    };

    render = {
      direct_scanout = 1;
      new_render_scheduling = true;
    };

    dwindle = {
      preserve_split = true;
      permanent_direction_override = true;
    };
  };
}
