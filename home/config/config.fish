# set preferences
# TODO: find out if these really matter at all
set -x TERMINAL alacritty
set -x BROWSER librewolf
set -x EDITOR hx
set -x VISUAL hx
set -x PAGER less
# set -x OPERNER xdg-open

# TODO: some of these should be global; to reach graphical apps
set -x NODE_OPTIONS --max-old-space-size=1024
set -x CRYPTOGRAPHY_OPENSSL_NO_LEGACY 1
set -x JAVA_HOME /usr/lib/jvm/default/
set -x _JAVA_OPTIONS '-Dsun.java2d.opengl=true -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'
set -x _JAVA_AWT_WM_NONREPARENTING 1
# set -x PATH "$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bin:$HOME/.bin/desktop:$PATH"
# dircolors -c | sed 's/setenv/set -x/' | source

# Preferences
# TODO: fix dircolors
# dircolors -c | sed 's/setenv/set -x/' | source
# set -x LS_COLORS (sh -c 'eval $(dircolors $HOME/.config/DIR_COLORS); echo $LS_COLORS')
set -x LESS '-SIRNs --incsearch'
set -x BAT_THEME TwoDark

# Use terminal colors
# TODO: configure this
# set -U fish_color_autosuggestion      brblack
# set -U fish_color_cancel              -r
# set -U fish_color_command             brgreen
# set -U fish_color_comment             brmagenta
# set -U fish_color_cwd                 green
# set -U fish_color_cwd_root            red
# set -U fish_color_end                 brmagenta
# set -U fish_color_error               brred
# set -U fish_color_escape              brcyan
# set -U fish_color_history_current     --bold
# set -U fish_color_host                normal
# set -U fish_color_match               --background=brblue
# set -U fish_color_normal              normal
# set -U fish_color_operator            cyan
# set -U fish_color_param               brblue
# set -U fish_color_quote               yellow
# set -U fish_color_redirection         bryellow
# set -U fish_color_search_match        'bryellow' '--background=brblack'
# set -U fish_color_selection           'white' '--bold' '--background=brblack'
# set -U fish_color_status              red
# set -U fish_color_user                brgreen
# set -U fish_color_valid_path          --underline
# set -U fish_pager_color_completion    normal
# set -U fish_pager_color_description   yellow
# set -U fish_pager_color_prefix        'white' '--bold' '--underline'
# set -U fish_pager_color_progress      'brwhite' '--background=cyan'

# Refer to Hydro documentation
# See: https://github.com/jorgebucaran/hydro
# TODO: check out Hydro's configuration options

# ctrl-f to open file manager
bind \cf 'lf; commandline -f repaint'
