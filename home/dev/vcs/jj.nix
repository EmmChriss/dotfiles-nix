{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.home.vcs;
in
  lib.mkMerge [
    # use meld as default 3-way merge util
    {
      home.packages = [pkgs.meld];
      programs.jujutsu.settings.ui.merge-editor = "meld";
    }
    # configure jjui
    {
      programs.jjui = {
        enable = true;
        settings = {
          revisions.revset = "..";
          ui = {
            auto_refresh_interval = 3;
            flash_message_display_seconds = 0;
            colors = {
              "text" = {
                fg = "#F0E6D2";
                bg = "#1C1C1C";
              };
              "dimmed" = {fg = "#888888";};
              "selected" = {
                bg = "#4B2401";
                fg = "#FFD700";
              };
              "border" = {fg = "#3A3A3A";};
              "title" = {
                fg = "#FF8C00";
                bold = true;
              };
              "shortcut" = {fg = "#FFA500";};
              "matched" = {
                fg = "#FFD700";
                underline = true;
              };
              "source_marker" = {
                bg = "#6B2A00";
                fg = "#FFFFFF";
              };
              "target_marker" = {
                bg = "#800000";
                fg = "#FFFFFF";
              };
              "revisions rebase source_marker" = {bold = true;};
              "revisions rebase target_marker" = {bold = true;};
              "status" = {bg = "#1A1A1A";};
              "status title" = {
                fg = "#000000";
                bg = "#FF4500";
                bold = true;
              };
              "status shortcut" = {fg = "#FFA500";};
              "status dimmed" = {fg = "#888888";};
              "revset text" = {bold = true;};
              "revset completion selected" = {
                bg = "#4B2401";
                fg = "#FFD700";
              };
              "revset completion matched" = {bold = true;};
              "revset completion dimmed" = {fg = "#505050";};
              "revisions selected" = {bold = true;};
              "oplog selected" = {bold = true;};
              "evolog selected" = {
                bg = "#403010";
                fg = "#FFD700";
                bold = true;
              };
              "help" = {bg = "#2B2B2B";};
              "help title" = {
                fg = "#FF8C00";
                bold = true;
                underline = true;
              };
              "help border" = {fg = "#3A3A3A";};
              "menu" = {bg = "#2B2B2B";};
              "menu title" = {
                fg = "#FF8C00";
                bold = true;
              };
              "menu shortcut" = {fg = "#FFA500";};
              "menu dimmed" = {fg = "#888888";};
              "menu border" = {fg = "#3A3A3A";};
              "menu selected" = {
                bg = "#4B2401";
                fg = "#FFD700";
              };
              "confirmation" = {bg = "#2B2B2B";};
              "confirmation text" = {fg = "#F0E6D2";};
              "confirmation selected" = {
                bg = "#4B2401";
                fg = "#FFD700";
              };
              "confirmation dimmed" = {fg = "#888888";};
              "confirmation border" = {fg = "#FF4500";};
              "undo" = {bg = "#2B2B2B";};
              "undo confirmation dimmed" = {fg = "#888888";};
              "undo confirmation selected" = {
                bg = "#4B2401";
                fg = "#FFD700";
              };
              "preview" = {fg = "#F0E6D2";};
            };
          };
        };
      };
    }
    # jj base config
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {inherit (cfg) name email;};

          snapshot = {
            auto-update-stale = true;
            max-new-file-size = "10MiB";
          };

          colors = {
            commit_id = "magenta";
            change_id = "cyan";
            "working_copy empty" = "green";
            "working_copy placeholder" = "red";
            "working_copy description placeholder" = "yellow";
            "working_copy empty description placeholder" = "green";
            prefix = {
              bold = true;
              fg = "cyan";
            };
            rest = {
              bold = false;
              fg = "bright black";
            };
            "node elided" = "yellow";
            "node working_copy" = "green";
            "node conflict" = "red";
            "node immutable" = "red";
            "node normal" = {
              bold = false;
            };
            "node" = {
              bold = false;
            };
          };

          revset-aliases = {
            "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine()) | remote_bookmarks() | tags()";
          };

          ui = {
            default-command = "combo";
            pager = "${pkgs.delta}/bin/delta";
            diff-formatter = ":git";
            diff-editor = ":builtin";

            # verify signatures only when `show`-ing change
            show-cryptographic-signatures = true;
          };

          templates = {
            # terser node formatting
            log_node = ''
              label("node",
                coalesce(
                  if(!self, label("elided", "~")),
                  if(current_working_copy, label("working_copy", "@")),
                  if(conflict, label("conflict", "×")),
                  if(immutable, label("immutable", "*")),
                  label("normal", "·")
                )
              )
            '';

            # terser log
            log = ''
              if(root,
                format_root_commit(self),
                label(if(current_working_copy, "working_copy"),
                  separate(" ",
                    format_short_change_id_with_change_offset(self),
                    if(divergent, commit_id.shortest()),
                    if(empty, label("empty", "(empty)")),
                    if(description,
                      description.first_line(),
                      label(if(empty, "empty"), description_placeholder),
                    ),
                    bookmarks,
                    tags,
                    working_copies,
                    if(conflict, label("conflict", "conflict")),
                    if(!mine, author.name()),
                  ) ++ "\n",
                )
              )
            '';

            # include changes in draft commit file
            draft_commit_description = ''
              concat(
                coalesce(description, default_commit_description, "\n"),
                surround(
                  "\nJJ: This commit contains the following changes:\n", "",
                  indent("JJ:     ", diff.stat(72)),
                ),
                "\nJJ: ignore-rest\n",
                diff.git(),
              )
            '';
          };

          aliases = {
            combo = let
              cmd = ''
                set -euo pipefail
                jj s --no-pager
                jj l --no-pager
              '';
            in [
              "util"
              "exec"
              "--"
              "bash"
              "-c"
              cmd
              ""
            ];
            d = ["diff"];
            dt = ["diff" "--from" "fork_point(trunk() | @)"];
            l = [
              "log"
              "-r"
              "@ | latest(heads(::@- & bookmarks())::@-, 3) | heads(::@- & bookmarks())"
            ];
            ll = [
              "log"
              "-r"
              ".."
            ];
            lb = [
              "log"
              "-r"
              "@ | ::@- & bookmarks()"
            ];
            lt = [
              "log"
              "-r"
              "(trunk()..@):: | (trunk()..@)-"
            ];
            s = ["status"];
            e = ["edit"];
            ed = ["edit"];
            # use `jj tug` to bring the last bookmark(s) to the parent change
            # NOTE: multiple bookmarks pointing to the same revision will all be pulled
            # use with `jj lb` to see which bookmark/bookmarks will be pulled
            tug = [
              "bookmark"
              "move"
              "--from"
              "heads(::@- & bookmarks())"
              "--to"
              "@-"
            ];
          };

          signing = {
            behaviour = "own";
            backend = "ssh";
            key = cfg.signature;

            backends.ssh.allowed-signers = "~/.ssh/allowed-signers";
            backends.ssh.revocation-list = "~/.ssh/revocation-list";
          };

          remotes.origin = {
            auto-track-bookmarks = "glob:*";
          };

          git = {
            sign-on-push = true;
            private-commits = "description(glob:'wip:*')";
          };
        };
      };
    }
  ]
