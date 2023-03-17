#!/bin/bash

set -euo pipefail

# trunk-ignore(shellcheck/SC2086): pass arguments directly as is
upgrade_output=$(${TRUNK_PATH} upgrade --no-progress -n ${UPGRADE_ARGUMENTS} | sed -e 's/\x1b\[[0-9;]*m//g')

if [[ ${upgrade_output} == *"Already up to date"* ]]; then
  echo "Already up to date."
  exit 0
fi

trimmed_upgrade_output=$(echo "${upgrade_output}" | grep "upgrade" -A 500)
title_message="Upgrade trunk"

new_cli_version=$(echo "${trimmed_upgrade_output}" | grep "cli upgrade" | awk '{print $NF}')
if [[ -n ${new_cli_version} ]]; then
  title_message="Upgrade trunk to ${new_cli_version}"
fi

# Avoid triggering a git-hook during the pull request creation action, and avoid resetting git hook config via daemon
${TRUNK_PATH} daemon shutdown
git config --unset core.hooksPath

# Replace space indentation with bulleted list (including sub-bullets)
# trunk-ignore(shellcheck/SC2001): more complicated sed parsing required
formatted_output=$(echo "${trimmed_upgrade_output}" | sed -e 's/^\(  \)\{0,1\}  /\1- /')

# Generate markdown
description=$(UPGRADE_CONTENTS="${formatted_output}" envsubst <"${GITHUB_ACTION_PATH}"/upgrade_pr.md)

{
  echo "DESCRIPTION<<EOF"
  echo "${description}"
  echo "EOF"
} >>"${GITHUB_OUTPUT}"

echo "TITLE_MESSAGE=${title_message}" >>"${GITHUB_OUTPUT}"
