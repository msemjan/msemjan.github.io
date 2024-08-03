---
title: "Introduction Into FZF"
date: 2024-07-20T11:57:02+02:00
draft: false
toc: true
images:
tags:
  - fzf
  - Fuzzy finder
  - Terminal
  - CLI
---
## What Is `fzf`?

The [fzf](https://github.com/junegunn/fzf) is a general purpose fuzzy finder that can interactively filter any kind of list, command line history, processes, host names, bookmarks, git commits, or anything else. Ever since I've installed in on my computer, it completely changed the way I interact with my terminal. If you are a fan of command line tools, the fzf might be perfect thing for you as well.

## Installation

The fzf is in the repositories of most popular distributions and can be easily installed with a single command:

| Package Manager | Linux Distribution      | Command                            |
|-----------------|-------------------------|------------------------------------|
| APK             | Alpine Linux            | `sudo apk add fzf`                 |
| APT             | Debian 9+/Ubuntu 19.10+ | `sudo apt install fzf`             |
| Conda           |                         | `conda install -c conda-forge fzf` |
| DNF             | Fedora                  | `sudo dnf install fzf`             |
| Nix             | NixOS, etc.             | `nix-env -iA nixpkgs.fzf`          |
| Pacman          | Arch Linux              | `sudo pacman -S fzf`               |
| pkg             | FreeBSD                 | `pkg install fzf`                  |
| pkgin           | NetBSD                  | `pkgin install fzf`                |
| pkg_add         | OpenBSD                 | `pkg_add fzf`                      |
| Portage         | Gentoo                  | `emerge --ask app-shells/fzf`      |
| Spack           |                         | `spack install fzf`                |
| XBPS            | Void Linux              | `sudo xbps-install -S fzf`         |
| Zypper          | openSUSE                | `sudo zypper install fzf`          |

Alternatively, you can [build it](https://github.com/junegunn/fzf#using-git) from the source code.

Once everything is installed, you can try running the fzf for the first time by executing command:

```bash
fzf
```

By default the fzf without any arguments will search for all files inside the current directory. Once you start typing the fzf will dynamically match any search terms. Since it uses a fuzzy search algorithm, you don't have to type the name of the file exactly. The fzf can still find it.

Additionally, you can setup integration with your shell:
- bash
  ```bash
  eval "$(fzf --bash)"
  ```
- zsh
  ```zsh
  source <(fzf --zsh)
  ```
- fish
  ```fish
  fzf --fish | source
  ```

This will add the fzf key bindings and fuzzy completions. The new keybindings will be:
- `Ctrl+t` - list files and folders in current directory (e.g. you can use it like this: type `git add`, then press `Ctrl+t`, select a few files using `TAB`, finally `ENTER`. Git will add the selected files.)
- `Ctrl+r` - search history of shell commands
- `Alt+c` - fuzzy change directory

These key bindings can be [modified further](https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings) by user.

There is also a [fzf plugin for Vim](https://github.com/junegunn/fzf), which can be installed by adding these two lines into your `~/.vimrc` file (assuming that you are using [vim-plug](https://github.com/junegunn/vim-plug) package manager):

```vim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
```

## Search Syntax

Unless otherwise specified, fzf starts in "extended-search mode" where you can type in multiple search terms delimited by spaces. e.g. `^music .mp3$ sbtrkt !fire`.

| Token     | Match type                 | Description                          |
|-----------|----------------------------|--------------------------------------|
| `sbtrkt`  | fuzzy-match                | Items that match `sbtrkt`            |
| `'wild`   | exact-match (quoted)       | Items that include `wild`            |
| `^music`  | prefix-exact-match         | Items that start with `music`        |
| `.mp3$`   | suffix-exact-match         | Items that end with `.mp3`           |
| `!fire`   | inverse-exact-match        | Items that do not include `fire`     |
| `!^music` | inverse-prefix-exact-match | Items that do not start with `music` |
| `!.mp3$`  | inverse-suffix-exact-match | Items that do not end with `.mp3`    |

If you wish to search for an exact word or phrase, start fzf with `-e` or `--exact` option.

**Note**: When `--exact` is set, `'`-prefix "unquotes" the term.

A single bar character term acts as an OR operator. For example, the following query matches entries that start with `core` and end with either `go`, `rb`, or `py`.

```
^core go$ | rb$ | py$
```

## Using `fzf` In Your Scripts

The true power of the fzf can be shown when we use it for various scripts.

### Basic Idea

All of your scripts will be based on a single simple principle. We can pipe data into the fzf and then search in it using the fzf interface. The fzf will then output the selected text. For example, we can make a simple yes-no selector like this:

```bash
#!/bin/sh
selected=$(echo -e "Yes\nNo" | fzf --prompt "Select one of the options")
echo "User selected $selected"
```

The `--prompt` flag adds a message for the user. By the way, `-e` flag seems to be necessary in `echo`. I've tried without, but the text was on a single line, and therefore we would have gotten only a single option. Once executed, we will be prompted to select one of the two options:

```
╭────────────────────────────────────╮
│ Select one of the options          │
│   2/2 ──────────────────────────── │
│ ▌ Yes                              │
│   No                               │
╰────────────────────────────────────╯
```

Then the selected answer will be printed by using `echo`. This may seem simple, but it gives us wide possibilities. Below are a couple of simple examples to inspire you to write your own.

### Example - Integration With Tmux

If you are using Tmux, it may be interesting for you to use the fzf-tmux command instead of the plain fzf. It works well with Tmux and with a `p` flag the selection will display floating above the panes, and I find it more readable compared to launching fzf in a smaller pane.

If you are not using Tmux at the moment, the fzf-tmux will run the normal fzf. The fzf-tmux has the same options as the normal fzf.

### Example - Setting Size Of Fzf Window

The width and height of the frame around the fzf selector can be adjusted according to the one's preferences with `--weigth`/`-w` (for width) and `--heigth`/`-h` (for heigth) flags:

```bash
fzf -w 60% -h 30%
```

This will make the fzf's 60% of the window's width and 30% of the window's height.

### Example - Preview

It is possible to add a preview of the currently selected file. The preview is set using the `--preview` flag followed by a command that is used to create the preview. For example, you can be satisfied by using a simple `cat` command:

```bash
ls note | fzf --preview "cat ~/notes/{}"
```

The `{}` is replaced with the name of the selected file. The full path is necessary, because otherwise the `cat` will fail to find the file, unless you are in `notes` folder.

Since I actually have some notes at `~/notes`, here is an example:

```
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ >                                          ╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│   931/931 ──────────────────────────────── │ ---                                                                                                                      │ │
│   AWS_dynamodb.md                         ││ title: "Amazon Fargate"                                                                                                  │ │
│   AWS_elastic_block_storage_ebs.md         │ author: "Marek S."                                                                                                       │ │
│   AWS_elastic_cloud_compute_ec2.md         │ summary: "Amazon Fargate is a fully-managed serverless service for running containerized applications on AWS."           │ │
│   AWS_elastic_container_registry_ecr.md    │ date: 2023-07-11T15:21:21Z+0200                                                                                          │ │
│   AWS_elastic_container_service_ecs.md     │ type: note                                                                                                               │ │
│   AWS_elastic_file_system_efs.md           │ draft: true                                                                                                              │ │
│   AWS_elastic_kubernetes_service_eks.md    │ tags:                                                                                                                    │ │
│   AWS_elastic_load_balancer_elb.md         │   - "Containers"                                                                                                         │ │
│ ▌ AWS_fargate.md                           │   - "Container-Orchestration"                                                                                            │ │
│   AWS_index.md                             │                                                                                                                          │ │
│   AWS_lambda.md                            │                                                                                                                          │ │
│   AWS_list_of_services_with_descriptions.m │                                                                                                                          │ │
│   AWS_mq.md                                ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

The position, size, and text wrapping of the preview window can be changed, by using `--preview-window` with `right`, `left`, `top`, and `bottom` options, followed by `:` and size in percents, another `:` separator, and the last is either `wrap` or `nowrap`. E.g.:

```bash
ls note | fzf --preview-window=top:80%:nowrap --preview "cat ~/notes/{}"
```

### Example - Default Settings

Writing the same setting such as the width and height will quickly get old. If you always want the same setting, you can export the settings into the `FZF_DEFAULT_OPTS` environment variable, and fzf will use it.

In my `.bashrc` file I have the following export:

```bash
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview-window=right:70%:wrap'
```

It sets the default height of the fzf window to 40% (default is 100%, which I didn't like), `--layout=reverse` puts the prompt at the top instead of the default bottom, `--border` adds the border, and `--preview-window` sets the size of the window, puts it on the right side and sets the text wrapping.

All the options and their values can be found on the [fzf's Github page](https://github.com/junegunn/fzf)

### Example - Searching Notes

In the following example we have a fuzzy search for notes in our notes folder. If no matching note is found, a new one is conditionally created based on the user input.

```bash
#!/bin/sh
# Location of the notes
NOTES_FOLDER="$HOME/notes/"

# The extension/suffix that I want for my notes (my notes are in Markdown)
SUFFIX=".md"

# Select a file from the notes folder
selection=$(ls $NOTES_FOLDER | fzf-tmux $FZF_DEFAULT_OPTS \
            --prompt "Select a note" -h 80% -w 80% \
            --preview "cat $NOTES_FOLDER{}")

if [ -z "$selection" ]
then
  # If there isn't such a note ask user if the note should be created
  selection=$( \
              printf "Yes\nNo" | fzf-tmux $FZF_DEFAULT_OPTS -h 80% -w 80% \
              --prompt "There is no such entry. Create a new one?" \
             )

  case "$selection" in
    # The user wants the new note
    "Yes")
      # Prompt for the name of the new note
      echo "Name of the new article? (without $SUFFIX suffix)"
      read name
      header="# $name"

      # Remove spaces and convert the name to lower case
      selection="$(echo $name | sed -e 's/\(.*\)/\L\1/' | sed 's/\ /_/g').wiki"

      # Create the new wiki file
      touch "$NOTES_FOLDER$selection"

      # Insert the title
      echo "$header" >> "$NOTES_FOLDER$selection"
      echo "" >> "$NOTES_FOLDER$selection"

      # Insert the skeleton outline
      echo "## Introduction" >> "$NOTES_FOLDER$selection"
      echo "" >> "$NOTES_FOLDER$selection"

      echo "## Main Idea" >> "$NOTES_FOLDER$selection"
      echo "" >> "$NOTES_FOLDER$selection"

      echo "## Conclusions" >> "$NOTES_FOLDER$selection"
      echo "" >> "$NOTES_FOLDER$selection"

      echo "## Sources" >> "$NOTES_FOLDER$selection"
      echo "" >> "$NOTES_FOLDER$selection"
      ;;
    # The users selects no + default: Exit
    *)
      echo "Ok, ok ... I am quitting then.\n"
      exit
      ;;
  esac
fi

# If the note exists or was just created, open it in the default browser (you
# should have EDITOR variable defined)
$EDITOR "$NOTES_FOLDER$selection"
```

### Example - Emoji Selector

In this example we create a simple emoji picker.

First download the [emoji.txt](https://gist.github.com/keidarcy/128141ff30a8c3f9ddc0d6c3ecb5b334) file from Github. You can use `wget` or do it using your favorite browser:

```bash
wget https://gist.githubusercontent.com/keidarcy/128141ff30a8c3f9ddc0d6c3ecb5b334/raw/8fc6b9efe6b72e8a876639e239043d492e857746/emoji.txt
```

The content of the file looks something like this:
```
😌 :relieved:
😆 :satisfied:
😁 :grin:
😉 :wink:
😜 :stuck_out_tongue_winking_eye:
😝 :stuck_out_tongue_closed_eyes:
😀 :grinning:
😗 :kissing:
😙 :kissing_smiling_eyes:
😛 :stuck_out_tongue:
😴 :sleeping:
😟 :worried:
😦 :frowning:
```

Each line consists of an emoji and an emoji name separated by a single space. The script that selects an emoji, and removes the name is a trivial one-liner:

```bash
#!/bin/sh

cat emoji.txt | fzf |  cut -d ' ' -f 1 | xsel -ib
```

The `cut -d ' ' -f 1` cuts the input into two columns divided by a single space, then returns the value from the first column. The `xsel -ib` will copy the emoji into the clipboard. You can remove this part, or replace it with something else.

**Note**: Some emojies are missing in the file. I don't know why, it is not my file.

### Example - Select Songs In Cmus Using FZF

[Cmus](https://cmus.github.io/) is a small, fast CLI music player for Unix-like systems. This snippet shows a simple script that picks a song from a give folder. Than queues the song. Entire folders can be selected as well.

```bash
#!/bin/bash

# Folder where is your music
music_folder="/path/to/Music/"

# Select desired music using fzf
selection=$(find "$music_folder" | fzf-tmux --prompt "Select a song:")

# Quit if nothing was selected
if [[ $selection -ef $HOME ]]; then exit; fi

# Add the selected music to the queue using Cmus' CLI
cmus-remote -l "$selection"

# If a specific music file was selected, play it immediately
if   [ -f "$selection" ]; then cmus-remote -f "$selection"; fi
```

### Example - Multiple Selections

It is possible to select more than one entry with `-m`/`--multi` flag. I don't use this feature very often, but I have a nice example that might be useful: That is a simple one-liner files, which lets you select the files that should be staged using `git add` command:

```bash
git add $(fzf --multi)
```

You can select several options by pressing `TAB` key. This will select/unselect the current line and then move down. To select the entry and move the pointer down, press `Shift+TAB`.

## Conclusion

In this blog post I've showed you how to install the fuzzy finder and added several examples to help you get started. Ever since I've installed the fzf on my computer, the way I interact with terminal changed. The fzf is extremely useful tool that I would recommend to everyone who likes/needs to work with terminal everyday.

The possibility of using the fzf in scripts greatly extends its usefulness. I use it all the time to create simple CLI interfaces for selecting files or even simple Yes/No questions. Moreover there are many examples of scripts online. People use it for all sorts of things, including selecting browser bookmarks, simplifying interactions with Git, selecting panes in Tmux, selecting [jrnl](https://github.com/jrnl-org/jrnl) entries from a particular day, [selecting  Spotify songs](https://github.com/AndreaOrru/fzf-mopidy-spotify.vim), and so much more! There are many example on [fzf's Github wiki](https://github.com/junegunn/fzf/wiki/Examples).
