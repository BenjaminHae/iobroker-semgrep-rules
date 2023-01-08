#!/usr/bin/env bash
source common.sh

check_semgrep

SCRIPT_PATH="scripts/"
OUT_PATH="docs/files.md"

read_parameters $@

echo "# Overview of objects used in ${SCRIPT_PATH}" > ${OUT_PATH}

# title, filter
print_result() {
    LIST=$(echo "$SEMRES" | grep " $2 " | sed 's/^\s*\S*\s\S*\s\(.*\)$/ - \1/' | sort | uniq)
    if [ -z "$LIST" ]
    then
        >&2 echo "$1 is empty"
    else
        echo "### $1"
        echo ""
        echo "$LIST" | sort | uniq
        echo ""
    fi
}

analyse_file() {
    local SCRIPT_FILE="${1}"
    echo "## ${SCRIPT_FILE#$SCRIPT_PATH}"
    echo ""
    # todo use json output
    SEMRES=$(run_semgrep rules.yml "${SCRIPT_FILE}" )
    >&2 echo $SEMRES

    print_result "Subscriptions" on
    print_result "Set State" setState
    print_result "Get State" getState
    print_result "Schedule" schedule
}

find_and_handle_files "${SCRIPT_PATH}" analyse_file >> ${OUT_PATH}
