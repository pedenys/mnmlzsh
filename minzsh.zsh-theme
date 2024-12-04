# allow parameters to be expanded
setopt promptsubst

# load colors
autoload -U colors && colors 

# set symbol for prompt
MIN_BASE_COLOR=cyan
MIN_ERROR_COLOR=red
MIN_PROMPT_SYMBOL="•➜"
STALE_COLOR=orange
CLEAN_COLOR=green

min_prompt() {
  echo -n "%(?.%F{$MIN_BASE_COLOR}.%F{$MIN_ERROR_COLOR})$MIN_PROMPT_SYMBOL%f "
}

min_current_dir() {
  echo -n "%F{$MIN_BASE_COLOR}%c %f"
}

min_git_branch()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo "$branch "
  fi
}

min_git_status() {
  #   current_branch=$(git rev-parse --abbrev-ref HEAD)
  #   upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
  # if [[ $current_branch == $upstream_branch ]]; then
  #   echo -n "Clean"
  # else
  #   echo -n "Stale"
  # fi

  (( $+commands[git] )) || echo "no git command";
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

   if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(command git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref="◈ $(command git describe --exact-match --tags HEAD 2> /dev/null)" || \
    ref="➦ $(command git rev-parse --short HEAD 2> /dev/null)"
    # if [[ -n $dirty ]]; then
    #   prompt_segment yellow black
    # else
    #   prompt_segment green $CURRENT_FG
    # fi

    local ahead behind
    ahead=$(command git log --oneline @{upstream}.. 2>/dev/null)
    behind=$(command git log --oneline ..@{upstream} 2>/dev/null)
    if [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$'\u21c5'
    elif [[ -n "$ahead" ]]; then
      PL_BRANCH_CHAR=$'\u21b1'
    elif [[ -n "$behind" ]]; then
      PL_BRANCH_CHAR=$'\u21b0'
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${${ref:gs/%/%%}/refs\/heads\//%F{$STALE_COLOR}%$PL_BRANCH_CHAR%f }${vcs_info_msg_0_%% }${mode}"
  fi
}

PROMPT='$(min_current_dir)$(min_git_status) $(min_prompt)'



