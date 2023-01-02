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

cd "${SCRIPT_PATH}"

# todo use find instead of loop
for f in */; do
  cd $f;
  for t in *; do
    echo "## $f$t" >> ${OUT_PATH}
    echo "" >> ${OUT_PATH}
    # todo use json output
    SEMRES=$(semgrep --config=../../rules.yml "${t}" 2> /dev/null | sed "s/^\s*//;s/'//g;s/\"//g" | grep iob.js)

    print_result Subscriptions on
    print_result "Set State" setState
    print_result "Get State" getState
    print_result "Schedule" schedule

  done
  cd ..
done;
