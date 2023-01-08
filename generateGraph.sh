#!/usr/bin/env bash
source common.sh

check_semgrep

SCRIPT_PATH="scripts/"
OUT_PATH="docs/files.md"

read_parameters $@

echo "flowchart LR" > ${OUT_PATH}

# title, filter, link-text
print_result() {
    # sed 's/^\s*\S*\s\S*\s\(.*\)$/ - \1/'
    LIST=$(echo "$SEMRES" | grep " $2 " | sort | uniq)
    if [ -z "$LIST" ]
    then
        >&2 echo "$1 is empty"
    else
        echo "$LIST" | \
            sed "s/^\\s*\\S*\\s\\(.*\\)\\s$2\\S*\\s\\(.*\\)$/   \1 $3 ${SCRIPT_NAME//\//\\\/} $(rev <<< $3)\> \2/"
    fi
}

analyse_file() {
    local SCRIPT_FILE="${1}"
    SCRIPT_NAME=${SCRIPT_FILE#$SCRIPT_PATH}
    # todo use json output
    SEMRES=$(run_semgrep rules-graph.yml "${SCRIPT_FILE}")
    >&2 echo $SEMRES

    print_result "Triggers" triggers --
    print_result "Affects" affects -.
}

find_and_handle_files "${SCRIPT_PATH}" analyse_file | sort | uniq >> ${OUT_PATH}

