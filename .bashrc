if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Start of custom configuration
# -----------------------------------------------
# All of this is for color-coded `git` information in the CLI prompt.
# https://coderwall.com/p/pn8f0g/show-your-git-status-and-branch-in-color-at-the-command-prompt
COLOR_YELLOW="\033[0;33m"
COLOR_GREEN="\033[0;32m"
COLOR_BLUE="\033[0;34m"
COLOR_RED="\033[0;31m"
COLOR_RESET="\033[0m"

function git_color {
  local git_status="$(git status 2> /dev/null)"
  # If branches have diverged, show yellow.
  # If branches are ahead, show yellow.
  if [[ $git_status =~ "Your branch is ahead of" || $git_status =~ "have diverged" ]]; then
    echo -e $COLOR_YELLOW
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo -e $COLOR_GREEN
  else
    echo -e $COLOR_RED
  fi
}

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
  # Hide the hostname.
  # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u:\[\033[01;34m\]\w\[\033[01;31m\]'
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]'
  PS1+="\[\$(git_color)\]"                            # colors branch name based on `git status`
  PS1+=" \[\033[1m\]\$(parse_git_branch)\[\033[0m\]"  # bold branch name
  PS1+="\[$COLOR_BLUE\]\$\[$COLOR_RESET\] "           # '#' for root, else '$'
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi

# This doesn't have to be in the color-coding section.
function gitcommitreset() {
  local last_git_commit_message=$(git log -1 --pretty=%B)
  git reset --soft HEAD^
  git commit -m "$last_git_commit_message"
  git log
}
function gitter() {
  local repo_url=$1
  local repo_name=$(basename -s .git $repo_url)
  local git_commit_message=${2:-"feat: functionality for foundational tasks"}
  # git clone $repo_url
  # cd $repo_name
  rm -rf .git
  git init
  git add .
  gh repo create --public "$repo_name"
  git commit -m "$git_commit_message"
  git remote add origin $repo_url
  git push
}
# -----------------------------------------------
# End of custom configuration

unset color_prompt force_color_prompt
