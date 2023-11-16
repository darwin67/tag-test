#!/bin/bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "${CURRENT_BRANCH}" != "master" ]]; then
    echo "This script can only be ran on the 'master' branch."
    exit 1
fi

# Get the latest tag
LATEST=$(git describe --tags --abbrev=0)

echo "Latest: ${LATEST}"

# Split up the current format into an array using `.` and `-` as the delimiter
IFS='.' read -r -a DEPLOY <<< "${LATEST}"
IFS='-' read -r -a DATE <<< "${DEPLOY[0]}"

YEAR=${DATE[0]}
MONTH=${DATE[1]}
DAY=${DATE[2]}
INDEX=${DEPLOY[1]}

PREV_DATE="${YEAR}-${MONTH}-${DAY}"

# NOTE: For debugging
# echo "Year: ${YEAR}, Month: ${MONTH}, Index: ${INDEX}"

CURRENT_YEAR=$(date -u +'%Y')
CURRENT_MONTH=$(date -u +'%m')
CURRENT_DAY=$(date -u +'%d')

NEXT="v${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DAY}"

# If the day is different from the latest one
# that means we need to start a new tag with the current day
if [[ "${PREV_DATE}" != "${NEXT}" ]]; then
    NEXT="${NEXT}.01"
else
    # if current month is the same as the latest,
    # bump the index
    NEW_INDEX=$((${INDEX}+1))
    NEXT="${NEXT}.$(printf "%02d" "$NEW_INDEX")"
fi

echo "Next tag: ${NEXT}"

# Tag the repository with the new deployment tag.
# GitHub actions will then deploy the tag.
git tag ${NEXT} # && git push origin ${NEXT}
