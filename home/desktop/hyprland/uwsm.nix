{...}: {
  xdg.configFile."uwsm/env-hyprland".text = ''
    export AQ_DRM_DEVICES="$(readlink -f /dev/dri/by-path/pci-0000:05:00.0-card):$(readlink -f /dev/dri/by-path/pci-0000:01:00.0-card)"
  '';

  xdg.configFile."uwsm/env".text = ''
    export XCURSOR_SIZE=24

    export QT_QPA_PLATFORM='wayland;xcb'
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    export NIXOS_OZONE_WL=1
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    export GDK_BACKEND='wayland,x11,*'
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland

    export MOZ_ENABLE_WAYLAND=1

    export _JAVA_AWT_WM_NONREPARENTING=1
    export _JAVA_OPTIONS='-Dsun.java2d.opengl=true -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'
    export CRYPTOGRAPHY_OPENSSL_NO_LEGACY='1'
    export OGL_DEDICATED_HW_STATE_PER_CONTEXT='ENABLE_ROBUST'
  '';
}
