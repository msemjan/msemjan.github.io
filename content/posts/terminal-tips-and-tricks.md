---
title: "Terminal Tips and Tricks"
date: 2023-03-27T11:33:22+02:00
type: post
draft: false
author: M. Semjan
summary: "Learn tips and tricks for effective work with Terminal - useful tricks for both interactive shell usage and scripting are included."
tags:
  - Bash
  - Terminal
  - Scripting
  - Tips & Tricks
---
# Terminal Tips and Tricks

This cheat sheet shows you various tips and tricks for working with terminal.

## Interactive Shell

If you are using Ubuntu, you can open terminal with `CTRL + ALT + T` keyboard shortcut.

### Basic Tasks

- Print the current working directory: `pwd`
- List files in the current directory: `ls`
- List files in a list format: `ls -l`
- List all files (including hidden ones): `ls -a`
- List all files in a list format: `ls -al`
- List all files in a list format, and use a human readable format for file sizes: `ls -alh`
- Change into a directory: `cd my-directory`
- Move to the home directory: `cd ~`
- Go to the previous directory: `cd -` (useful, when you want to jump back and forth between two folders)
- Create an empty file: `touch my-file`
- Create a directory: `mkdir my-directory`
- Create a directory and `cd` into it: `mkdir dir_name && cd $_`
- Create a directory with it's parents: `mkdir -p path/to/some/dir`
- Create multiple subdirectories: `mkdir -p path/{subdirectory1,subdirectory2,subdirectory3}`
- Download a file from the internet:
  - Using `curl`: `curl -O URL`
  - Using `wget`: `wget URL`
- You can use `TAB` to auto-complete a command or a folder/file name, after you've written several letters
- Get a list of all environment variables: `env`
- Get help with a given command: `man command`
- Redirect the `STDOUT` output of one command into the `STDIN` of another command: `command1 | command2`
- Redirect the `STDOUT` output of a command into a file: `command > /path/to/file.txt` (if the file doesn't exist, it will be created, if it exists, it will be overwritten)
- Append the `STDOUT` output of a command into a file: `command >> /path/to/file.txt` (if the file doesn't exist, it will be created, if it exists, it won't be overwritten)
- Display a simple calendar: `cal` (or `cal -3` to display three months)

### Running Scripts

- Give your user ability to run a script: `chmod u+x my-script.sh`
- Remove your user's ability to run a script: `chmod u-x my-script.sh`
- Run the script from the current directory: `./my-script.sh`
- Run the script from a different directory: `./path/to/my-script.sh`
- You can create a directory for your executable scripts (e.g. `~/bin`), move your scripts there, and add this directory to your path (`export PATH=$PATH:~/bin`). You can then you can run your script without `./` or the path (e.g. `my-script.sh`)

### History

- View commands you've used in the past: `history`
- For a more convenient browsing of history: `history | less`
- Search for some pattern in history: `history | grep "pattern"`
- Click `CTRL + R` and start typing, this will bring up the last command that matches what you've written. Click `CTRL + R` repeatedly to find older matches
- Use arrow up and down to "scroll" through recent commands
- Re-run the last command: `!!`
- Re-run the last command, but as a superuser: `sudo !!`
- Refer to the n-th command in the history: `!n`
- Refer to the n-th command from the end in the history: `!-n`
- Re-run the second last command: `!-2`
- Refer to the most recent command in the history starting with `string`: `!string`, e.g. `!cd`

### Administrative Tasks

- Update and upgrade Debian-based Linux distros: `sudo apt-get install && sudo apt-get upgrade`
- Install a package in Debian-based Linux distros: `sudo apt-get install some-package`
- Search for a package in repositories: `apt search my-query` (this is useful, if you are not sure, what is the package with a program called)
- Show details of a package: `apt show some-package`
- Shutdown the computer: `sudo shutdown -h now`
- Restart the computer immediately: `sudo shutdown -r now`
- Restart the computer in 60 minutes: `sudo shutdown -r +60`
- Continually monitor a log file: `tail -f /var/log/some.log`
- Get your IP address: `ifconfig`
- Get your external address: `curl ipecho.net/plain; echo`
- Test connectivity to a website: `ping -c 10 URL`
- Task monitor: `top` or for more colorful option `htop`

### Development

- Start a simple server in any directory: `python -m SimpleHTTPServer 8000` (you need Python installed)

### Remote Shell

### Automating Common Tasks

If you often run a long command (either with many flags and options, or several commands chained together), it you probably should create a alias to simplify running the command.

To create a alias, add the line that looks like this to your `~/.bashrc` file:
```bash
alias cmd='my-very-very-long-often-used-command'
```

Replace everything between the quotes with your command and it's flags and options. Make sure that you use the single quote (`'`) and not the double quote (`"`). When you are done with adding `~/.bashrc`, close and reopen terminal, or run `source ~/.bashrc`.

You can then use the alias like a normal command:
```bash
cmd
```

The alias doesn't have to be a complete command, it can contain just the flags and options, and you add some input parameter when you use the alias:
```bash
cmd "some input"
```

Disadvantage of aliases is that you can not pass parameters that are "in the middle" of the command. But you can functions that use parameters to your `~/.bashrc`, e.g.:
```bash
repeat ()
{
  local count="$1" i;
  shift;
  for i in $(_seq 1 "$count");
  do
    eval "$@";
  done
}

# Subfunction needed by `repeat'.
_seq ()
{
  local lower upper output;
  lower=$1 upper=$2;

  if [ $lower -ge $upper ]; then return; fi
  while [ $lower -lt $upper ];
  do
    echo -n "$lower "
    lower=$(($lower + 1))
  done
  echo "$lower"
}
```
This function repeats a given command given number of times. Example usage:
```bash
repeat 10 echo foo
```

Here is a couple of aliases from my `.bashrc` for inspiration:
```bash
# Make outputs more colorful
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# some ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

## Debian/Ubuntu
alias age='sudo apt-get'
alias ags='apt search'
alias apu='sudo apt update && sudo apt upgrade'

## Faster navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Frequently used commands
alias c='clear' # you can use CTRL+L instead, if you haven't remaped it like I did
alias h='history'
alias ss="ps -aux"
alias dot='ls .[a-zA-Z0-9_]*'
alias texclean='rm -f *.toc *.aux *.log *.cp *.fn *.tp *.vr *.pg *.ky'
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias more=less
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Tmux
alias ta='tmux attach-session -t $(tmux list-sessions | fzf | cut -d":" -f 1)'
alias ts='tmux new-session -s'      # create a new named session
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'       # kill all the server and all the sessions
alias tkss='tmux kill-session -t'   # kill a named session

## Simple fun or useful stuff
alias wttr='curl wttr.in/<your-town>'
alias clear='[ $[$RANDOM % 15] = 0 ] && timeout 1 cmatrix || clear'

# Common misspellings
alias mroe='more'
alias moar='more'
alias pdw='pwd'
alias exot='exit'

# Dice
alias d4='shuf -i1-4 -n1'
alias d6='shuf -i1-6 -n1'
alias d8='shuf -i1-8 -n1'
alias d20='shuf -i1-20 -n1'
alias d60='shuf -i1-60 -n1'

# Git
# You must install Git first
alias gs='git status'
alias gl='git log --graph --oneline --all'
alias ga='git add .'
alias gc='git commit -m' # requires you to type a commit message
alias gp='git push'
alias gau='git add -u'
alias grm='git rm $(git ls-files --deleted)'

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
```

## Scripting

You can use all the tricks from interactive section while scripting.

### Comment Your Code

You will thank me when you return to your script after longer period of time and won't remember what it does and why.

I also recommend using longer versions of the flags, when writing a script, because it documents the script. E.g instead of `-q` use `--quiet`.

### Make Script Exit On Fail

```bash
set -o errexit
# OR
set -e
```

### Make Script Fail When It Uses Undeclared Variables

```bash
set -o nounset
# OR
set -u
```

### Consider Using Functions In Longer Scripts

Functions make your code more readable, document it, and make it more reusable. With exception of the small scripts, it is a good idea to use functions.

Syntax for writing functions is:
```bash
function function_name () {
  # function code`
}

# Or
function_name () {
  # function code`
}

# It can be written in a single line
function_name() { command1; command2; }
```

## Multi-Line Output And Input

You can use documents to output a multi-line message. E.g. for outputting a help message:
```bash
cat << EOF
usage: up [--level <n>| -n <levels>][--help][--version]

Report bugs to: support@up.app
up home page: https://up.app
EOF
```

You can also load multi-line string into a variable like this:
```bash
read -d '' variable <<- EOF
This is a very long document.
It has several lines.
And one more.
You can even your variables, such as "$USER"
EOF

# Now you can use your variable
```

### Use = Instead Of == For String Comparisons

Note that `==` is a synonym for `=`, therefore only use a single `=` for string comparisons.

### Command Substitution

Command substitution replaces a command with it's output. You can use `$(command)` or surround the command with backticks (legacy approach to command substitution), but `$(command)` is recommended. Example:
```bash
user=`echo “$UID”`
user=$(echo “$UID”)
```

### Use Read-Only To Declare Static Variables

Static variables can not be changed once defined in a script. Example usage:
```bash
readonly password_file="/etc/passwd"
```

### Check Your Scripts With Shell Check Tool

Use [ShellCheck tool](https://www.tecmint.com/shellcheck-shell-script-code-analyzer-for-linux/) to find warnings and suggestions concerning bad code in bash/sh shell scripts.

### Always Surround Your Variables With Quotation Marks

Surround your variables with quotation mark to ensure that variables are referenced correctly. This is especially important if your variable has several words separated with spaces. Without the quotation marks, Bash will interpret the next word as the beginning of the next command.

A variable in single quotes `'` is treated as a literal string, and not as a variable. Variables in quotation marks `"`  are treated as variables.

### Break Up Scripts Into Multiple Files

You can import variables and functions defined in another files with `source` command. E.g.:
```bash
source ~/.bash_aliases
```

This specific line can often be seen in `~/.bashrc` files, because people who have many aliases like to write them into `~/.bash_aliases`. Some people also create a separate file for their functions (`~/.bash_functions`).

When you source, all lines of code will be executed (including creation of aliases), so keep that in mind.

### Environment Variables

There are various special, pre-defined environment variables, which you can use:
- `$#` - Returns the number of parameters passed to the script
- `$@` - List of all the command line parameters passed to the script
- `$?` - Returns the exit status of the last process to run
- `$$` - The process ID (PID) of the current script
- `$USER` - The username of the user who is currently logged in
- `$HOSTNAME` - The host name of the computer you are using
- `$PWD` - The current working directory
- `$HOME` - The home folder of the current user
- `$SECONDS` - Number of seconds the script has been running for
- `$RANDOM` - Returns a random number
- `$LINENO` - Returns the current line number of the script

## Conclusion

We looked at various tips and tricks that will help you use Bash interactively or for scripting.
