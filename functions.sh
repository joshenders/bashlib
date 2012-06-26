function exit_with_error() {
    # usage: exit_with_error "error message"

    echo "${0##*/}: $@" >&2
    exit 1
}

function check_dependencies() {
    # This function should only consist of builtins
    # usage: check_dependencies "list of external programs"

    local dependencies="$@"

    for utility in $dependencies; do
        if [[ "$(type $utility >/dev/null 2>&1; echo $?)" -ne '0' ]]; then
             echo "${0##*/}: Could not find \"$utility\" in \$PATH. Please verify that \"$utility\" is installed before running this script" >&2
             exit 1
        else
            # set $utility to full path of $utility
            eval $utility=$(type -P $utility)
        fi
    done
}
