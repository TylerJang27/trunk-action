#!/bin/bash

set -euo pipefail

# trunk-ignore(shellcheck/SC2086): pass arguments directly as is
upgrade_output=$(${TRUNK_PATH} upgrade --no-progress -n ${UPGRADE_ARGUMENTS} | sed -e 's/\x1b\[[0-9;]*m//g' | grep "upgrade" -A 500)
new_cli_version=$(echo "${upgrade_output}" | grep "cli upgrade" | awk '{print $NF}')
title_message="Upgrade trunk"

if [[ -n ${new_cli_version} ]]; then
  title_message="Upgrade trunk to ${new_cli_version}"
fi

# Avoid triggering a git-hook during the pull request creation action, and avoid resetting git hook config via daemon
${TRUNK_PATH} daemon shutdown
git config --unset core.hooksPath
rm -f .trunk/landing-state.json

# trunk-ignore(shellcheck/SC2001): more complicated sed parsing required
formatted_output=$(echo "${upgrade_output}" | sed -e 's/^\(  \)\{0,1\}  /\1- /')

# TODO: TYLER FIX URL
description=$(UPGRADE_CONTENTS="${formatted_output}" envsubst <upgrade_pr.md)

# TODO: TYLER ATTEMPT TO CLEAN THIS UP
# trunk-ignore(shellcheck/SC2129): Write multi-line value to output

{
  echo "DESCRIPTION<<EOF"
  echo "${description}"
  echo "EOF"
} >>"${GITHUB_OUTPUT}"
# echo "DESCRIPTION<<EOF" >>"${GITHUB_OUTPUT}"
# echo "${description}" >>"${GITHUB_OUTPUT}"
# echo "EOF" >>"${GITHUB_OUTPUT}"

echo "TITLE_MESSAGE=${title_message}" >>"${GITHUB_OUTPUT}"
