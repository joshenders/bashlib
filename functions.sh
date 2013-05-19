# This file is inteded to be 
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
    # usage: prompt "prompt message"

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

function top_level_parent_pid() {
    # usage: top_level_parent_pid "${PID:-$$}

    # Look up the top-level parent Process ID (PID) of the given PID, or the current
    # process if unspecified.
    # - http://stackoverflow.com/questions/3586888/

    # Look up the parent of the given PID.
    local pid="${1:-$$}"
    local stat=($(</proc/${pid}/stat))
    local ppid="${stat[3]}"

    # /sbin/init always has a PID of 1, so if you reach that, the current PID is
    # the top-level parent. Otherwise, keep looking.
    if [[ "${ppid}" -eq '1' ]] ; then
        echo "${pid}"
    else
        top_level_parent_pid "${ppid}"
    fi
}

function exit_with_usage() {
    # usage: exit_with_usage

    # cat << EOF >&2 works if you can shell out
    echo
"Usage: ${0##*/} [options] <arg>

Options:
    -a N, --apple=N    Do a thing
    -b,   --banana     Do another thing
" >&2
    exit 1

}
