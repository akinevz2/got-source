# got-source

`get` / `got` — quick view + search over files and directories.

- **`got`** — the POSIX-sh script holding all the logic (listing,
  cat/bat display, grep, filename search + fzf picking, `$PATH`
  resolution).
- **`get`** — the thin shell function (bash/zsh) that can `cd` first
  (`-` for the previous directory, or a leading directory argument).

## Install

```sh
make install          # $HOME/.local prefix, hooks ~/.bashrc + ~/.zshrc
```

Knobs: `PREFIX=...`, `DESTDIR=...` (staging), `SKIP_RC=1` (files only),
`RC_FILES="..."` (explicit rc list). `make uninstall` removes the files
and strips the rc hooks; `make check` smoke-tests the tree.

## Usage

```
got                              ls -al the current directory
got @                            same as above
got @name [more...]              open <name> in $EDITOR; if <name> is not
                                 a local file, resolve it on $PATH and
                                 follow symlinks to the real file
got <dir> [names...]             ls the dir, then find each name beneath it
got <file...>                    cat/bat the files; symlinks print only
                                 their real path (readlink -f), so
                                 `get $(get <link>)` shows the contents
got <queries...> <file|dir>      grep each query (with file+line numbers);
                                 for a folder, find matching filenames
                                 under it and fzf-pick one
got <queries...> -- <file|dir>…  same, with an explicit queries/targets
                                 split
got -n <queries...> <dir>        filename search + fzf pick

get -                            cd to the previous directory first
get <dir> [names...]             cd into <dir>, then behave like `got .`
```

Split rule without `--`: an argument that exists as a file/dir is a
target, everything else is a query. If there are no queries at all,
targets are displayed; if there are queries, targets are searched.
