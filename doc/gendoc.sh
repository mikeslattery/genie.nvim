#!/bin/bash

# Generate plugin help documentation using AI
# Usage: doc/gendoc.sh

# Requirements:
# - git is installed and this is a git project
# - name of plugin is embedded in the github project URL.
# - OPENAI_API_KEY is set or is in .env file
# - openai-python is installed and openai is in PATH
# - curl is installed

set -euo pipefail

MODEL='gpt-4o'
LICENSE='MIT'

# Get the base name of the project.
get_name() {
  git remote get-url origin | \
    sed 's/.*\/\([^\/]*\)\.git/\1/; s/^n\?vim-//; s/\.n\?vim$//;'
}

get_http_url() {
  git remote get-url origin | sed -E 's#git@github.com:(.*)#https://github.com/\1#; s#\.git$##;'
}

load_vars() {
  # Change directory to project root.
  cd "$(git rev-parse --show-toplevel)"

  URL="$(get_http_url)"
  NAME="$(get_name)"
  if [[ -f .env ]]; then
    source .env
    export OPENAI_API_KEY
  fi
}

mdfile() {
  ext="$(echo -n "$1" | sed -E 's/^.*\.([^\.]*)$/\1/;')"
  echo -e '
File: '"$1"'

```'"${ext}"'
'"$(cat "$1")"'
```'
}

prompt() {
  examples='https://raw.githubusercontent.com/folke/lazy.nvim/main/lua/lazy/example.lua'

  echo "Here is example use of lazy.nvim package manager:"
  echo ''
  echo '```lua'
  curl -sSf "$examples"
  echo '```'
  echo ''
  echo "These files are for a Neovim plugin called ${NAME}:"
  for file in $(git ls-files | grep -E '.\.(lua|vim)$'); do
    mdfile "$file"
  done
  echo ''
  echo "The current date is $(date)."
  echo "The ${NAME} plugin repo is at ${URL}"
  echo ''
  echo 'INSTRUCTION:'
  echo "Generate doc/${NAME}.txt for $NAME Neovim plugin, in raw vim help file format."
  echo "Do not generate within markdown, but only as raw txt."
  echo "Any install instructions should be based on vim-plug and lazy.nvim package managers."
  echo "Include a copyright and mention of ${LICENSE} license."
}

ai() {
  openai api chat.completions.create -m "$MODEL" -g user "$(cat)"
}

main() {
  echo "Generating doc/${NAME}.txt ..." >&2

  load_vars
  prompt | ai > "doc/${NAME}.txt"

  echo 'Finished.' >&2
}

main
