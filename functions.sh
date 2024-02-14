# shellcheck shell=bash

format_seconds() {
    # usage: $0 <seconds>
    local seconds="${1}"
    local string days hours minutes remainder

    days=$((seconds / (3600 * 24)))
    if [[ "${days}" -gt 0 ]]; then
        string+="${days}d"
    fi

    hours=$(((seconds % (3600 * 24)) / 3600))
    if [[ ${hours} -gt 0 ]]; then
        string+="${hours}h"
    fi

    minutes=$(((seconds % 3600) / 60))
    if [[ ${minutes} -gt 0 ]]; then
        string+="${minutes}m"
    fi

    remainder=$((seconds % 60))
    if [[ ${remainder} -gt 0 ]]; then
        string+="${remainder}s"
    fi

    if [[ -n "${string}" ]]; then
        echo "${string}"
    fi
}

compare_versions() {
    # usage: $0 <version1> <version2>
    # expects version as w.x.y.z

    local version1 version2
    # Pad versions with leading zeros
    version1=$(printf "%s" "${1}" \
               | awk -F. '{printf "%04d.%04d.%04d.%04d\n", $1, $2, $3, $4}')
    version2=$(printf "%s" "${2}" \
               | awk -F. '{printf "%04d.%04d.%04d.%04d\n", $1, $2, $3, $4}')

    if [[ "${version1}" == "${version2}" ]]; then
        return 0
    elif [[ "${version1}" < "${version2}" ]]; then
        return 1
    else
        return 2
    fi
}

function check_dependencies() {
    # usage: $0 <space separated list of external programs>
    # This function must only consist of builtins

    local dependencies result in_path
    IFS=" " read -ra dependencies <<< "${@}"

    for utility in "${dependencies[@]}"; do
        result="$(type -t "${utility}")"

        if [[ "${result}" == 'builtin' ]]; then
            continue
        fi

        in_path="$(type "${utility}" >/dev/null 2>&1; echo ${?})"

        if [[ "${in_path}" -eq 0 ]]; then
            # set $utility to full local path of $utility
            eval "${utility}"="$(type -P "${utility}")"
        else
            echo "${0##*/}: Could not find \"$utility\" in \$PATH."    \
                 "Please verify that \"$utility\" is installed before" \
                 "running this script" >&2
            exit 1
        fi
    done
}

function prompt() {
    # usage: $0 <message>

    local message="${1}"
    local response

    while [[ -z "${response}" ]]; do
        read -rp "${message} [y/n] " response

        if [[ "${response}" =~ ^[yY]$ ]]; then
            printf "\n"
            return 0
        elif [[ "${response}" =~ ^[nN]$ ]]; then
            return 1
        else
            unset response
        fi
    done
}

function top_level_parent_pid() {
    # usage: $0 [pid]

    # Look up the top-level parent Process ID (PID) of the given PID, or the
    # current process if unspecified.
    # - http://stackoverflow.com/questions/3586888/

    # Look up the parent of the given PID.
    local pid="${1:-$$}"
    local stat
    IFS=" " read -r -a stat <<< "$(</proc/"${pid}"/stat)"
    local ppid="${stat[3]}"

    # /sbin/init always has a PID of 1, so if we reach that, the current PID
    # is the top-level parent. Otherwise, keep going.
    if [[ "${ppid}" -eq 1 ]] ; then
        echo "${pid}"
    else
        top_level_parent_pid "${ppid}"
    fi
}

function exit_with_error() {
    # usage: $0 <message>

    echo -e "${0##*/}: ${*}" >&2
    exit 1
}

function exit_with_usage() {
    # usage: $0

    # cat << EOF >&2 works too if you can shell out
    echo \
"Usage: ${0##*/} [options] <arg>

Options:
    -a N, --apple=N    Do a thing
    -b,   --banana     Do another thing
" >&2
    exit 1
}
