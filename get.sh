# get.sh — the `get` shell function behind `got`.
#
# Sourced by bash and zsh (via the got-source rc hook, or ~/.shellx.rc
# on dots-managed machines).  POSIX-portable: no bashisms, no zshisms.
#
# `got` (~/.local/bin/got) holds all the logic; `get` is the thin shell
# wrapper that can cd first ("-": previous dir, or a leading directory).
get() {
    if [ $# -gt 0 ]; then
        if [ "$1" = "-" ]; then
            cd - || return 1
            shift
        elif [ -d "$1" ]; then
            cd -- "$1" || return 1
            shift
            # Re-entering the current directory explicitly, so `got`
            # lists it and can `find` the remaining names beneath it.
            if [ $# -gt 0 ]; then
                got "." "$@"
                return $?
            fi
            got
            return $?
        fi
    fi
    got "$@"
}
