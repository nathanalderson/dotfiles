#!/usr/bin/env zsh
#local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

setopt promptsubst

autoload -U add-zsh-hook

PROMPT_SUCCESS_COLOR=$fg_bold[magenta]
PROMPT_FAILURE_COLOR=$fg[red]
PROMPT_VCS_INFO_COLOR=$fg[yellow]
PROMPT_PROMPT=$fg_bold[magenta]
PROMPT_PROMPT_ROOT=$fg_bold[red]
GIT_DIRTY_COLOR=$fg[green]
GIT_CLEAN_COLOR=$fg[green]
GIT_PROMPT_INFO=$fg[green]

function prompt_color {
    if [[ $USER == "root" ]]; then
        echo %{$PROMPT_PROMPT_ROOT%}
    else
        echo %{$PROMPT_PROMPT%}
    fi
}

PROMPT='%{$PROMPT_SUCCESS_COLOR%}%~%{$reset_color%} %{$GIT_PROMPT_INFO%}$(git_prompt_info)%{$GIT_DIRTY_COLOR%}$(git_prompt_status) %{$reset_color%}$(prompt_color)»%{$reset_color%} '

#RPS1="${return_code}"
MODE_INDICATOR="%{$fg[blue]%}-- NORMAL --%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$GIT_PROMPT_INFO%})"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$GIT_DIRTY_COLOR%}✘"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$GIT_CLEAN_COLOR%}✔"

ZSH_THEME_GIT_PROMPT_ADDED="%{$GIT_DIRTY_COLOR%}✚%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$GIT_DIRTY_COLOR%}✹%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$GIT_DIRTY_COLOR%}✖%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$GIT_DIRTY_COLOR%}➜%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$GIT_DIRTY_COLOR%}═%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$GIT_DIRTY_COLOR%}✭%{$reset_color%}"
