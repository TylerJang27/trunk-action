#!/bin/bash

set -euo pipefail

# Step 1: Run upgrade and strip ANSI coloring.
# trunk-ignore(shellcheck/SC2086): pass arguments directly as is
upgrade_output=$(${TRUNK_PATH} upgrade --no-progress -n ${UPGRADE_ARGUMENTS} | sed -e 's/\x1b\[[0-9;]*m//g')

# Step 2a: Parse output. If up to date, exit successfully.
if [[ ${upgrade_output} == *"Already up to date"* ]]; then
  echo "Already up to date."
  exit 0
fi

# Step 2b: Parse output. Strip launcher downloading messages and parse cli upgrade.
trimmed_upgrade_output=$(echo "${upgrade_output}" | grep "upgrade" -A 500)
title_message="Upgrade trunk"

if [[ ${trimmed_upgrade_output} == *"cli upgrade"* ]]; then
  new_cli_version=$(echo "${trimmed_upgrade_output}" | grep "cli upgrade" | awk '{print $NF}')
  title_message="Upgrade trunk to ${new_cli_version}"
fi

echo "TYLER DONE STEP 2" # TODO: TYLER REMOVE

# Step 3: Prepare for pull request creation action.
# Avoid triggering a git-hook, and avoid resetting git hook config via daemon
${TRUNK_PATH} daemon shutdown

echo "TYLER DONE STEP 2.5" # TODO: TYLER REMOVE
which git

git config --unset core.hooksPath

echo "TYLER DONE STEP 3" # TODO: TYLER REMOVE

# Step 4: Format upgrade output for PR.
# Replace space indentation with bulleted list (including sub-bullets)
# trunk-ignore(shellcheck/SC2001): more complicated sed parsing required
formatted_output=$(echo "${trimmed_upgrade_output}" | sed -e 's/^\(  \)\{0,1\}  /\1- /')

echo "TYLER DONE STEP 4" # TODO: TYLER REMOVE

# Step 5: Generate markdown
description=$(UPGRADE_CONTENTS="${formatted_output}" envsubst <"${GITHUB_ACTION_PATH}"/upgrade_pr.md)

echo "TYLER DONE STEP 5" # TODO: TYLER REMOVE

# Step 6: Write outputs
{
  echo "DESCRIPTION<<EOF"
  echo "${description}"
  echo "EOF"
} >>"${GITHUB_OUTPUT}"

echo "TITLE_MESSAGE=${title_message}" >>"${GITHUB_OUTPUT}"

echo "TYLER DONE STEP 6" # TODO: TYLER REMOVE
