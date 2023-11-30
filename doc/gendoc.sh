#!/bin/bash

MODEL=gpt-4

file() {
  echo -e '
File: '"$1"'

```'"${2:-}"'
'"$(cat "$1")"'
```
'
}

prompt() {
  echo 'These files are for a Neovim plugin called genie.nvim:'
  file lua/genie/init.lua lua
  file test/genie_spec.lua lua
  echo ''
  echo 'INSTRUCTION:'
  echo 'Generate doc/genie.txt in raw vim help file format.'
}

ai() {
  openai api chat.completions.create -m $MODEL -g user "$(cat)"
}

main() {
  echo 'Generating doc/genie.txt ...' >&2

  prompt | ai > doc/genie.txt

  echo 'Finished' >&2
}

main
