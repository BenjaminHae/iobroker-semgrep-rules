#!/usr/bin/env bash
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

echo "flowchart LR" > ${OUT_PATH}

# title, filter, link-text
print_result() {
    # sed 's/^\s*\S*\s\S*\s\(.*\)$/ - \1/'
    LIST=$(echo "$SEMRES" | grep " $2 " | sort | uniq)
    if [ -z "$LIST" ]
    then
        echo "$1 is empty"
    else
        echo "$LIST" | sed "s/^\\s*\\S*\\s\\(.*\\)\\s$2\\S*\\s\\(.*\\)$/   \1 $3 ${SCRIPT_NAME//\//\\\/} $(rev <<< $3)\> \2/" >> ${OUT_PATH}
    fi
}

#SEMRES=$(semgrep --config=rules-graph.yml "${SCRIPT_PATH}" 2> /dev/null | sed "s/^\s*//;s/'//g;s/\"//g" | grep iob.js)
#print_result "Triggers" triggers --
#print_result "Affects" affects -.

analyse_file() {
    local SCRIPT_FILE="${1}"
    SCRIPT_NAME=${SCRIPT_FILE#$SCRIPT_PATH}
    # todo use json output
    SEMRES=$(semgrep --config=rules-graph.yml "${SCRIPT_FILE}" 2> /dev/null | sed "s/^\s*//;s/'//g;s/\"//g" | grep iob.js)
    echo $SEMRES

    print_result "Triggers" triggers --
    print_result "Affects" affects -.
}

find ${SCRIPT_PATH} -type f \( -iname "*.ts" -o -iname "*.js" \) -print0 | sort -z | while IFS= read -r -d '' file; do analyse_file "$file"; done
