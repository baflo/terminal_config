#---------------------------------------------------------------------------------------------------------------------------------------
#
#   Author: Kyle Brumm, Florian Bachmann
#   Description: File used to hold Bash configuration, aliases, functions, completions, etc...
#
#   Sections:
#   1.  ENVIRONMENT SETUP
#   2.  MAKE TERMINAL BETTER
#   3.  FOLDER MANAGEMENT
#   4.  MISC ALIAS'
#   5.  GIT SHORTCUTS
#   6.  Linux COMMANDS
#   7.  TAB COMPLETION
#
#---------------------------------------------------------------------------------------------------------------------------------------

GIT_PROJECT="baflo/terminal_config"
BASH_CONFIG_GIT_PATH="https://raw.githubusercontent.com/$GIT_PROJECT/master/"
BASH_CONFIG_GIT_INFO="https://api.github.com/repos/$GIT_PROJECT/commits/master"

BASH_CONFIG_REV_FILE=~/.config/bash_config_rev

#---------------------------------------------------------------------------------------------------------------------------------------
#   1.  ENVIRONMENT SETUP
#---------------------------------------------------------------------------------------------------------------------------------------

# Font style
BOLD=$(tput bold)
NORM=$(tput sgr0)

# Set colors to variables
black="\033[0;30m"
blackb="\033[1;30m"
red="\033[0;31m"
redb="\033[1;31m"
green="\033[0;32m"
greenb="\033[1;32m"
yellow="\033[0;33m"
yellowb="\033[1;33m"
blue="\033[0;34m"
blueb="\033[1;34m"
purple="\033[0;35m"
purbleb="\033[1;35m"
cyan="\033[0;36m"
cyanb="\033[1;36m"
white="\033[0;37m"
whiteb="\033[1;37m"

BLACK="\[$black\]"
BLACKB="\[$blackb\]"
RED="\[$red\]"
REDB="\[$redb\]"
GREEN="\[$green\]"
GREENB="\[$greenb\]"
YELLOW="\[$yellow\]"
YELLOWB="\[$yellowb\]"
BLUE="\[$blue\]"
BLUEB="\[$blueb\]"
PURPLE="\[$purple\]"
PURPLEB="\[$purpleb\]"
CYAN="\[$cyan\]"
CYANB="\[$cyanb\]"
WHITE="\[$white\]"
WHITEB="\[$whiteb\]"

# Config
latest_config_rev () {
  local result=$(curl $BASH_CONFIG_GIT_INFO 2> /dev/null)
  echo $(echo $result | sed 's/.*\"sha\"\: \"\([0-9a-z]*\)\",.*/\1/')
}

new_bash_config_available() {
  local remote_rev=$(latest_config_rev)
  local local_rev=$(if [[ -f $BASH_CONFIG_REV_FILE ]]; then cat $BASH_CONFIG_REV_FILE; fi)

  if [[ $remote_rev != $local_rev ]]
  then
    echo $remote_rev
  fi
}

# Register script for installing own tools
upgrade_bash_tools() {
  . <(curl "$BASH_CONFIG_GIT_PATH/bash_install.sh")
}

upgrade_bash_profile() {
  local remote_rev=$(new_bash_config_available)
  if [[ -z $remote_rev ]]
  then
    echo -e "${yellow}Bash config up to date."
  else
    wget -O ~/.bash_profile "$BASH_CONFIG_GIT_PATH/.bash_profile"
    echo -n $remote_rev > $BASH_CONFIG_REV_FILE
#    . ~/.bash_profile
    upgrade_bash_tools
  fi
}

# Get Git branch of current directory
git_upstream_target() {
    local branch=$(if [ ! -z $2 ]; then echo -n $2; elif [ ! -z $1 ]; then echo -n $1; else echo -n $(git branch -vv | sed -n 's/.*\[[0-9a-zA-Z]*\/\([0-9a-zA-Z]*\).*/\1/p'); fi)
    local remote=$(if [ ! -z $2 ]; then echo -n $1;                                    else echo -n $(git branch -vv | sed -n 's/.*\[\([0-9a-zA-Z]*\)\/[0-9a-zA-Z]*.*/\1/p'); fi)

    echo -n "$remote/$branch"
}
git_upstream_remote() {
    if [ ! -z $2 ]
    then
        echo -n $1
    else
        echo -n $(git_upstream_target | sed -n 's/\([0-9a-zA-Z]\)\/.*/\1/p')
    fi
}
git_upstream_branch() {
    if [ ! -z $2 ];
    then
        echo -n $2
    elif [ ! -z $1 ]
    then
        echo -n $1
    else
        echo -n $(git_upstream_target | sed -n 's/.*\/\([0-9a-zA-Z]\)/\1/p')
    fi
}
git_ahead_by() {
    local branch=$(git_upstream_branch $@)
    local remote=$(git_upstream_remote $@)
    echo -n $(git branch -vv | sed -n "s/.*\[$remote\/$branch: ahead \([0-9]*\).*/\1/p")
}
git_behind_by() {
    local branch=$(git_upstream_branch $@)
    local remote=$(git_upstream_remote $@)
    echo -n $(git branch -vv | sed -n "s/.*\[$remote\/$branch:.* behind \([0-9]*\).*/\1/p")
}
git_branch () {
    if git rev-parse --git-dir >/dev/null 2>&1
    then
	local remote=$(git_upstream_remote $@)
        local branch=$(git_upstream_branch $@)
        local target=" git:($remote/$branch"

	local ahead=$(git_ahead_by $remote $branch)
	local behind=$(git_behind_by $remote $branch)

        if [[ $ahead -gt 0 ]]
        then
            target+=", ahead $ahead"
 	fi

        if [[ $behind -gt 0 ]]
        then
            target+=", behind $behind"
        fi

	echo -n "$target)"
    else
        echo -n ""
    fi
}

# Set a specific color for the status of the Git repo
git_color() {
    local STATUS=`git status 2>&1`
    if [[ "$STATUS" == *'Not a git repository'* ]]
        then echo "" # nothing
    else
        if [[ "$STATUS" != *'working tree clean'* ]]
            then echo -e '\033[0;31m' # red if need to commit
        else
            if [[ "$STATUS" == *'Your branch is ahead'* ]]
                then echo -e '\033[0;33m' # yellow if need to push
            else
                echo -e '\033[0;32m' # else green
            fi
        fi
    fi
}

# Add ssh keys if needed
# https://confluence.atlassian.com/bitbucket/configure-multiple-ssh-identities-for-gitbash-mac-osx-linux-271943168.html
if [ ! $(ssh-add -l | grep -o -e id_rsa) ]; then
    ssh-add "$HOME/.ssh/id_rsa" > /dev/null 2>&1
fi

# Modify the prompt - Spacegray
export PS1=$CYAN'\u'$WHITE' at '$YELLOW'\h'$WHITE' → '$GREEN'[\w]\e[0m$(git_color)$(git_branch)\n'$WHITE'\$ '

# Set tab name to the current directory
export PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}\007"'

# Add color to terminal
export CLICOLOR=1
export LSCOLORS=GxExBxBxFxegedabagacad

# Setup RBENV stuff
export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Setup our $PATH
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.composer/vendor/bin

# Set default editor to neovim
export EDITOR=nvim

# Tell npm to compile and install all your native addons in parallel and not sequentially
export JOBS=max

# Bump the maximum number of file descriptors you can have open
ulimit -n 10240

# Print the date
date


#---------------------------------------------------------------------------------------------------------------------------------------
#   2.  MAKE TERMINAL BETTER
#---------------------------------------------------------------------------------------------------------------------------------------

# Misc Commands
alias resource='source ~/.bash_profile'                                         # Source bash_profile
bash-as() { sudo -u $1 /bin/bash; }                                             # Run a bash shell as another user
alias ll='ls -alh'                                                              # List files
alias llr='ls -alhr'                                                            # List files (reverse)
alias lls='ls -alhS'                                                            # List files by size
alias llsr='ls -alhSr'                                                          # List files by size (reverse)
alias lld='ls -alht'                                                            # List files by date
alias lldr='ls -alhtr'                                                          # List files by date (reverse)
alias lldc='ls -alhtU'                                                          # List files by date created
alias lldcr='ls -alhtUr'                                                        # List files by date created (reverse)
alias h="history"                                                               # Shorthand for `history` command
alias perm="stat -f '%Lp'"                                                      # View the permissions of a file/dir as a number
alias mkdir='mkdir -pv'                                                         # Make parent directories if needed
disk-usage() { du -hs "$@" | sort -nr; }                                        # List disk usage of all the files in a directory (use -hr to sort on server)
dirdiff() { diff -u <( ls "$1" | sort)  <( ls "$2" | sort ); }                  # Compare the contents of 2 directories
getsshkey() { pbcopy < ~/.ssh/id_rsa.pub; }                                     # Copy ssh key to the keyboard


# Editing common files
alias edithosts='atom /etc/hosts'                                               # Edit hosts file
alias editbash='atom ~/.bash_profile'                                           # Edit bash profile
alias editsshconfig='atom ~/.ssh/config'                                        # Edit the ssh config file
alias editsharedbash='atom ~/Dropbox/Preferences/home/.shared_bash_profile'     # Edit shared bash profile in Dropbox

# Navigation Shortcuts
alias ..='cl ..'
alias ...='cl ../../'
alias ....='cl ../../../'
alias .....='cl ../../../../'
alias ......='cl ../../../../'
alias .......='cl ../../../../../'
alias ........='cl ../../../../../../'
alias home='clear && cd ~ && ll'                                                # Home directory
alias downloads='clear && cd ~/Downloads && ll'                                 # Downloads directory
cs() { cd "$@" &&  ls; }                                                        # Enter directory and list contents with ls
cl() { cd "$@" && ll; }                                                         # Enter directory and list contents with ll
site() { clear && cl $HOME/sites/"$@"; }                                        # Access site folders easier
project() { clear && cl $HOME/projects/"$@"; }                                  # Access project folders easier
email() { clear && cl $HOME/projects/emails/"$@"; }                             # Access email folders easier


#---------------------------------------------------------------------------------------------------------------------------------------
#   3.  FOLDER MANAGEMENT
#---------------------------------------------------------------------------------------------------------------------------------------

# Clear a directory
cleardir() {
    while true; do
        read -ep 'Completely clear current directory? [y/N] ' response
        case $response in
            [Yy]* )
                bash -c 'rm -rfv ./*'
                bash -c 'rm -rfv ./.*'
                break;;
            * )
                echo 'Skipped clearing the directory...'
                break;;
        esac
    done
}

mktar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }    # Creates a *.tar.gz archive of a file or folder
mkzip() { zip -r "${1%%/}.zip" "$1" ; }               # Create a *.zip archive of a file or folder


#---------------------------------------------------------------------------------------------------------------------------------------
#   4.  MISC ALIAS'
#---------------------------------------------------------------------------------------------------------------------------------------

# Grunt
alias gw='grunt watch'    # Start the Grunt "watch" task
alias gbs='grunt bs'      # Start the Grunt "browser-sync" task

# Give a command alias returning date in format YYYY-MM-DD
alias rdate='echo -n `date +%Y-%m-%d`'

# npm
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'

# Compass
alias cw='compass watch'

# Run last command with sudo
alias fuck='sudo $(fc -ln -1)'

# Start a web server to share the files in the current directory
sharefolder() {
    # PHP
    path="$1"
    if [ -z "$path" ]; then
        path="."
    fi
    php -t $path -S localhost:5555
}

# Display the weather using wttr.in
weather() {
    location="$1"
    if [ -z "$location" ]; then
        location="dsm"
    fi

    curl http://wttr.in/$location?lang=en
}


#---------------------------------------------------------------------------------------------------------------------------------------
#   5.  GIT SHORTCUTS
#---------------------------------------------------------------------------------------------------------------------------------------

alias gitstats='git-stats'
alias gits='git status -s'
alias gita='git add -A && git status -s'
alias gitcom='git commit -am'
alias gitacom='git add -A && git commit -am'
alias gitc='git checkout'
alias gitcm='git checkout master'
alias gitcd='git checkout development'
alias gitcgh='git checkout gh-pages'
alias gitb='git branch'
alias gitcb='git checkout -b'
alias gitdb='git branch -d'
alias gitDb='git branch -D'
alias gitdr='git push origin --delete'
alias gitf='git fetch'
alias gitr='git rebase'
alias gitp='git push -u'
alias gitpl='git pull'
alias gitfr='git fetch && git rebase'
alias gitfrp='git fetch && git rebase && git push -u'
alias gitpo='git push -u origin'
alias gitpom='git push -u origin master'
alias gitphm='git push heroku master'
alias gitm='git merge'
alias gitmd='git merge development'
alias gitmm='git merge master'
alias gitcl='git clone'
alias gitclr='git clone --recursive'
alias gitamend='git commit --amend'
alias gitundo='git reset --soft HEAD~1'
alias gitm2gh='git checkout gh-pages && git merge master && git push -u && git checkout master'
alias gitrao='git remote add origin'
alias gitrso='git remote set-url origin'
alias gittrack='git update-index --no-assume-unchanged'
alias gituntrack='git update-index --assume-unchanged'
alias gitpullsubmodules='git submodule foreach git pull origin master'
alias gitremoveremote='git rm -r --cached'
alias gitlog="git log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)'"
alias gitlog-changes="git log --oneline --decorate --stat --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)'"
gitdbr() { git branch -d "$@" && git push origin --delete "$@"; }
gitupstream() { git branch --set-upstream-to="$@"; }
gitreset() {
    while true; do
        read -ep 'Reset HEAD? [y/N] ' response
        case $response in
            [Yy]* )
                bash -c 'git reset --hard HEAD'
                break;;
            * )
                echo 'Skipped reseting the HEAD...'
                break;;
        esac
    done
}

function gitpall {
    POSITIONAL=()
    MESSAGE=""
    REMOTE=$(git_upstream_remote)
    BRANCH=$(git_upstream_branch)

    # Parse options
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -m|--message)
                MESSAGE="$2"
                shift
                shift
                ;;
            -r|--remote)
                REMOTE="$2"
                shift
                shift
                ;;
            -b|--branch)
                BRANCH="$2"
                shift
                shift
                ;;
            *)
                POSITIONAL+=("$1")
                shift
                ;;
        esac
    done

    # ALL_POSITIONAL=${POSITIONAL[@]}
    DIR=${POSITIONAL[0]}
    if [ "$DIR" == "" ]
    then
        DIR="."
    fi

    # Add directory
    git checkout "$BRANCH" > /dev/null
    git add "$DIR" > /dev/null

    # Handle commit if any changes
    git diff --cached --exit-code > /dev/null
    if [ $? != 0 ]
    then
        # Add message
        if [ "$MESSAGE" == "" ]
        then
            git commit
        else
            git commit -m "$MESSAGE"
        fi

        # Handle if noting was committed
        if [ $? != 0 ]
        then
            echo -e "${yellow}Exit without committing..."
            return
        fi
    else
        echo -e "${yellow}Nothing to commit..."
        return
    fi

    # Check remote status
    if [[ $(git_behind_by "$REMOTE" "$BRANCH") -gt 0 ]]
    then
        echo -ne "${yellow}The branch is behind by $(git_behind_by) commits. Do you want to continue?${white} [y/n]: "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[nN] ]]
        then
            echo -e "${yellow}Breaking process...${white}"
	    return
        fi
    fi

    if [ $(git_ahead_by "$REMOTE" "$BRANCH") == 0 ]
    then
        echo -e "${yellow}Nothing to push."
        return
    fi

    # Push to remote
    if [ "$?" == 0 ]
    then
        echo -ne "${yellow}Do you want to push to ${REMOTE}/${BRANCH}?${white} [y/n] " && read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo -e "${yellow}Pushing...${white}"
            git push $REMOTE $BRANCH
            return
        fi
    else
        echo -e "${yellow}Exit without pushing..."
    fi

}



#---------------------------------------------------------------------------------------------------------------------------------------
#   6.  Linux COMMANDS
#---------------------------------------------------------------------------------------------------------------------------------------

# Nothing to see here


#---------------------------------------------------------------------------------------------------------------------------------------
#   7.  TAB COMPLETION
#---------------------------------------------------------------------------------------------------------------------------------------

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal" killall;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Bash completion for the `site` alias
_local_site_complete() {
    local cur prev opts
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    opts=$(ls $HOME/sites/)
    COMPREPLY=( $(compgen -W "$opts" -- $cur) )
}
complete -o nospace -F _local_site_complete site

# Bash completion for the `project` alias
_local_project_complete() {
    local cur prev opts
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    opts=$(ls $HOME/projects/)
    COMPREPLY=( $(compgen -W "$opts" -- $cur) )
}
complete -o nospace -F _local_project_complete project

# Bash completion for the `emails` alias
_local_email_complete() {
    local cur prev opts
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    opts=$(ls $HOME/projects/emails/)
    COMPREPLY=( $(compgen -W "$opts" -- $cur) )
}
complete -o nospace -F _local_email_complete email

# Bash completion for checking out Git branches
_git_checkout_branch_complete() {
    local cur prev opts
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    opts=$(git branch | cut -c 3-)

    COMPREPLY=( $(compgen -W "$opts" -- $cur) )
}
complete -o nospace -F _git_checkout_branch_complete gitc
complete -o nospace -F _git_checkout_branch_complete gitdb
complete -o nospace -F _git_checkout_branch_complete gitDb
complete -o nospace -F _git_checkout_branch_complete gitdbr

# Bash completion for the `wp` command (wp-cli)
_wp_complete() {
    local OLD_IFS="$IFS"
    local cur=${COMP_WORDS[COMP_CWORD]}

    IFS=$'\n';  # want to preserve spaces at the end
    local opts="$(wp cli completions --line="$COMP_LINE" --point="$COMP_POINT")"

    if [[ "$opts" =~ \<file\>\s* ]]
    then
        COMPREPLY=( $(compgen -f -- $cur) )
    elif [[ $opts = "" ]]
    then
        COMPREPLY=( $(compgen -f -- $cur) )
    else
        COMPREPLY=( ${opts[*]} )
    fi

    IFS="$OLD_IFS"
    return 0
}
complete -o nospace -F _wp_complete wp


## Install apps that are missing
curl_nc_tf() {
	curl -H 'Cache-Control: no-cache' $1 > $2
}

create() {
    mkdir -p "$(dirname $"$1")" && touch "$1" > /dev/null
}



