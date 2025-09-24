{ pkgs, ... }:

let
  signature = "~/.ssh/id_2025_sign.pub";
  name = "EmmChriss";
  email = "emmchris@protonmail.com";
in
{
  # enable git
  programs.git = {
    enable = true;

    # git large file support
    lfs.enable = true;

    # git diff highlighter
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };

    # automatic git signing
    signing = {
      format = "ssh";
      signByDefault = true;
      key = signature;
    };
    
    userName = name;
    userEmail = email;
  };

  # jujutsu: enhanced git
  programs.jujutsu = {
    enable = true;
    settings = {
      user = { inherit name email; };

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
        "node normal" = { bold = false; };
        "node" = { bold = false; };
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
                format_short_change_id_with_hidden_and_divergent_info(self),
                if(empty, label("empty", "(empty)")),
                if(description,
                  description.first_line(),
                  label(if(empty, "empty"), description_placeholder),
                ),
                bookmarks,
                tags,
                working_copies,
                if(git_head, label("git_head", "HEAD")),
                if(conflict, label("conflict", "conflict")),
                if(!mine, author.name()),
              ) ++ "\n",
            )
          )
        '';

        # include changes in draft commit file
        draft_commit_description =''
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
        combo =
          let cmd = ''
              set -euo pipefail
              jj s --no-pager
              jj l --no-pager
            '';
          in ["util" "exec" "--" "bash" "-c" cmd ""];
        d = ["diff"];
        l = ["log" "-r" "@ | latest(heads(::@- & bookmarks())::@-, 3) | heads(::@- & bookmarks())"];
        ll = ["log" "-r" ".."];
        lb = ["log" "-r" "@ | ::@- & bookmarks()"];
        lt = ["log" "-r" "(trunk()..@):: | (trunk()..@)-"];
        s = ["status"];
        e = ["edit"];
        ed = ["edit"];
        # use `jj tug` to bring the last bookmark(s) to the parent change
        # NOTE: multiple bookmarks pointing to the same revision will all be pulled
        # use with `jj lb` to see which bookmark/bookmarks will be pulled
        tug = ["bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-"];
      };
      
      signing = {
        behaviour = "drop";
        backend = "ssh";
        key = signature;

        backends.ssh.allowed-signers = "~/.ssh/allowed-signers";
        backends.ssh.revocation-list = "~/.ssh/revocation-list";
      };

      git = {
        sign-on-push = true;
        auto-local-bookmark = true;
        push-new-bookmarks = true;
        private-commits = "description(glob:'wip:*')";
      };
    };
  };
}
