# git-swi

`git switch` for lazy people :)

**Usage:** `git-swi SEARCH_PHRASE [OPTION_NUMBER]`

## What gives?

This shell script allows you to enter a search phrase instead of entering a full branch name (which could be pretty long on some projects).

Its logic is simple:

1. call `git branch` to check local branches
1. filter branches by `SEARCH_PHRASE` with `grep`
1. decide whether to execute `git switch` in the following manner:
    1. if 1 branch matched search phrase, `git switch` to that branch
    1. if 0 branches matched, then exit
    1. if >1 branches matched:
        1. if `OPTION_NUMBER` is missing, then print options and exit
        1. if `OPTION_NUMBER` is present, then `git switch` to that branch

## How to use?

Download `git-swi.sh` file.

Then include this line in your shell configuration, e.g. `~/.bashrc`, `~/.zshrc`, etc.

```shell
source /path/to/git-swi.sh
```

