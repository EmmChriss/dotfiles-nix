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
