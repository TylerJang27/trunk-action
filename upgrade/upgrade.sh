#!/bin/bash

set -euo pipefail

echo "about to run upgrade" # TODO: TYLER REMOVE

# trunk-ignore(shellcheck/SC2086): pass arguments directly as is
upgrade_output=$(${TRUNK_PATH} upgrade --no-progress -n ${UPGRADE_ARGUMENTS} | sed -e 's/\x1b\[[0-9;]*m//g' | grep "upgrade" -A 500)
title_message="Upgrade trunk"

echo "done running upgrade" # TODO: TYLER REMOVE

new_cli_version=$(echo "${upgrade_output}" | grep "cli upgrade" | awk '{print $NF}')
if [[ -n ${new_cli_version} ]]; then
  title_message="Upgrade trunk to ${new_cli_version}"
fi

echo "about to shutdown" # TODO: TYLER REMOVE

# Avoid triggering a git-hook during the pull request creation action, and avoid resetting git hook config via daemon
${TRUNK_PATH} daemon shutdown
git config --unset core.hooksPath

echo "done shutting down" # TODO: TYLER REMOVE

# Replace space indentation with bulleted list (including sub-bullets)
# trunk-ignore(shellcheck/SC2001): more complicated sed parsing required
formatted_output=$(echo "${upgrade_output}" | sed -e 's/^\(  \)\{0,1\}  /\1- /')

# TODO: TYLER FIX URL
# Generate markdown
description=$(UPGRADE_CONTENTS="${formatted_output}" envsubst <"${GITHUB_ACTION_PATH}"/upgrade_pr.md)

{
  echo "DESCRIPTION<<EOF"
  echo "${description}"
  echo "EOF"
} >>"${GITHUB_OUTPUT}"

echo "TITLE_MESSAGE=${title_message}" >>"${GITHUB_OUTPUT}"
