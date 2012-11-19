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
        if [[ "$(type -t $utility)" != 'builtin' ]]; then
            if [[ "$(type $utility >/dev/null 2>&1; echo $?)" -ne '0' ]]; then
                echo "${0##*/}: Could not find \"$utility\" in \$PATH. Please verify that \"$utility\" is installed before running this script" >&2
                exit 1
            else
                # set $utility to full path of $utility
                eval $utility="$(type -P $utility)"
             fi
        fi
    done
}

function prompt() {
    local message="$1"
    local response

    while [[ -z "$response" ]]; do
        read -p "$message [y/n] " response
        
        if [[ "$response" =~ ^[yY]$ ]]; then
            printf "\n"
            return 0
        elif [[ "$response" =~ ^[nN]$ ]]; then
            return 1
        else
            unset response
        fi
    done
}

