{pkgs, ...}: {
  home.packages = with pkgs; [
    # Volume control
    (writeShellApplication {
      name = "vol";
      runtimeInputs = [wireplumber bc];
      text = ''
        if test $# = 0; then
          # print usage
          echo "vol [DEVICE] get: prints volume"
          echo "vol [DEVICE] mute: toggle mute"
          echo "vol [DEVICE] VOL%[+/-]: increase/decrese/set volume"
          echo "DEVICE: sink/speaker | source/mic | [other input to wpctl]"
          exit
        elif test $# = 1; then
          # $1: N%[+/-] | mute | get
          dev=@DEFAULT_AUDIO_SINK@
          op="$1"
        elif test $# = 2; then
          # $1: [sink/speaker] | [source/mic]
          # $2: N%[+/-] | mute
          case "$1" in
            sink|speaker) dev=@DEFAULT_AUDIO_SINK@ ;;
            source|mic*) dev=@DEFAULT_AUDIO_SOURCE@ ;;
            *) dev="$1" ;;
          esac
          op="$2"
        fi

        case "$op" in
          get) wpctl get-volume "$dev" | grep Volume | cut -d' ' -f2 | tr -d '.' | bc ;;
        	mute) wpctl set-mute "$dev" toggle ;;
        	*) wpctl set-volume "$dev" "$op" ;;
        esac
      '';
    })

    # Backlight control
    (writeShellApplication {
      name = "bl";
      runtimeInputs = [
        brightnessctl
        bc
      ];
      text = ''
        device="$(echo /sys/class/backlight/amd* | cut -d/ -f5)"
        cmd="brightnessctl -m -e -d $device"

        # write default to cache file if unset
        if ! test -f "$XDG_RUNTIME_DIR/bl"; then
          # NOTE: this just gets level, doesn't undo exponentiation
          # echo "100*$($cmd g)/$($cmd m)" | bc > "$XDG_RUNTIME_DIR/bl"
          echo 60 > "$XDG_RUNTIME_DIR/bl"
        fi

        # get current level from cache file
        current="$(cat "$XDG_RUNTIME_DIR/bl")"

        # print current and exit
        print_current() {
          echo "$current"
          exit
        }

        # if no additional arguments
        if test $# = 0; then
          print_current
        fi

        # extract digits
        num="$(echo "$1" | tr -cd '[:digit:]')"

        # if no numbers in input
        if test -z "$num"; then
          print_current
        fi

        # either add to/sub from or set to value
        case "$1" in
          +*) new="$(echo "$current+$num" | bc)" ;;
          -*) new="$(echo "$current-$num" | bc)" ;;
          *)  new="$num" ;;
        esac

        # clamp new between 0 and 100
        test "$new" -gt 100 && new=100
        test "$new" -lt 0 && new=0

        # apply nonlinear interpolation
        # amounts to log_10(9x+1)
        set="$(echo "$new/100" | bc -l)"      # reduce to [0, 1]
        set="$(echo "9*$set+1" | bc -l)"      # apply 9x+1
        set="$(echo "l($set)/l(10)" | bc -l)" # apply log_10
        set="$(echo "$set*100" | bc)"         # apply x100
        set="''${set%.*}"                     # round to integer

        # write new value to file
        echo "$new" > "$XDG_RUNTIME_DIR/bl" && echo "$new"

        # set
        $cmd s "$set%" >/dev/null
      '';
    })

    # Rapid-charge mode for Lenovo laptops
    (writeShellScriptBin "ideapad-rc" (builtins.readFile ./scripts/ideapad-rc))
  ];
}
