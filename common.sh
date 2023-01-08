check_semgrep() { if ! command -v semgrep &> /dev/null
    then
        echo "semgrep could not be found"
        exit
    fi
}

# sets SCRIPT_PATH and OUT_PATH
read_parameters() {
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
}

# $1: Search Path
# $2: callback function
find_and_handle_files() {
    find "${1}" -type f \( -iname "*.ts" -o -iname "*.js" \) -print0 | \
        sort -z | \
        while IFS= read -r -d '' file; do ${2} "$file"; done
}

# $1: rules-path
# $2: path to file
run_semgrep() {
    semgrep --config="${1}" "${2}" 2> /dev/null | \
        sed "s/^\s*//;s/'//g;s/\"//g" | \
        grep iob.js
}
