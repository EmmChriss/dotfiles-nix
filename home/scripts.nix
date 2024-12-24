{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Volume control
    (writeShellApplication {
      name = "vol";
      runtimeInputs = [ pulseaudio ];
      text = ''
        # no args, print current volume
        if test $# = 0; then
        	current="$(pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | awk '{print $5}' | cut -d% -f1)"
        	echo "$current"
        	exit
        fi

        # at least one arg
        case $1 in
        	mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
        	*) pactl set-sink-volume @DEFAULT_SINK@ "$1" ;;
        esac
      '';
    })

    # Backlight control
    (writeShellApplication {
      name = "bl";
      runtimeInputs = [ brightnessctl bc ];
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
        set="''${set%.*}"                   # round to integer

        # set value && write new value to file
        $cmd s "$set%" && echo "$new" > "$XDG_RUNTIME_DIR/bl" && echo "$new"
      '';
    })
  
    # Preview files in terminal
    (writeShellScriptBin "preview" (builtins.readFile ./scripts/preview))
    # Rapid-charge mode for Lenovo laptops
    (writeShellScriptBin "ideapad-rc" (builtins.readFile ./scripts/ideapad-rc))
    # Reload YADM git repo; prepare to sync stuff
    (writeShellScriptBin "yadm-reload" (builtins.readFile ./scripts/yadm-reload))
  ];
}
