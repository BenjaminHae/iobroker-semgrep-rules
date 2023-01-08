#!/usr/bin/env bash
if ! command -v semgrep &> /dev/null
then
    echo "semgrep could not be found"
    exit
fi

SCRIPT_PATH="scripts/"
OUT_PATH="docs/files.md"

if [ "$#" -ge 1 ]; then
    SCRIPT_PATH="${1}"
fi
if [ "$#" -ge 2 ]; then
    OUT_PATH="${2}"
fi

SCRIPT_PATH=$(readlink -m "${SCRIPT_PATH}")
[[ "${SCRIPT_PATH}" != */ ]] && SCRIPT_PATH="${SCRIPT_PATH}/"
OUT_PATH=$(readlink -m "${OUT_PATH}")
echo "Reading ${SCRIPT_PATH}"
echo "Output to ${OUT_PATH}"

echo "# Overview of objects used in ${SCRIPT_PATH}" > ${OUT_PATH}

# title, filter
print_result() {
    LIST=$(echo "$SEMRES" | grep " $2 " | sed 's/^\s*\S*\s\S*\s\(.*\)$/ - \1/' | sort | uniq)
    if [ -z "$LIST" ]
    then
        echo "$1 is empty"
    else
        echo "### $1" >> ${OUT_PATH}
        echo "" >> ${OUT_PATH}
        echo "$LIST" | sort | uniq >> ${OUT_PATH}
        echo "" >> ${OUT_PATH}
    fi
}

analyse_file() {
    local SCRIPT_FILE="${1}"
    echo "## ${SCRIPT_FILE#$SCRIPT_PATH}" >> ${OUT_PATH}
    echo "" >> ${OUT_PATH}
    # todo use json output
    SEMRES=$(semgrep --config=rules.yml "${SCRIPT_FILE}" 2> /dev/null | sed "s/^\s*//;s/'//g;s/\"//g" | grep iob.js)
    echo $SEMRES

    print_result "Subscriptions" on
    print_result "Set State" setState
    print_result "Get State" getState
    print_result "Schedule" schedule
}

find ${SCRIPT_PATH} -type f \( -iname "*.ts" -o -iname "*.js" \) -print0 | sort -z | while IFS= read -r -d '' file; do analyse_file "$file"; done

exit
cd "${SCRIPT_PATH}"
