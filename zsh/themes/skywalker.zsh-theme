# skywalker.zsh-theme
# By: SharkIng

REV_GIT_DIR=""

autoload -U add-zsh-hook

chpwd_git_dir_hook() { REV_GIT_DIR=`command git rev-parse --git-dir 2>/dev/null`; }
add-zsh-hook chpwd chpwd_git_dir_hook
chpwd_git_dir_hook

# Get the last command exit code at previous line's end
previous_align_right() {
    # CSI ref: https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_sequences
    local new_line='
    '
    local str="$1"

    # Get space_size
    local zero_pattern='%([BSUbfksu]|([FB]|){*})'
    local len=${#${(S%%)str//$~zero_pattern/}}
    local size=$(( $COLUMNS - $len ))

    local previous_line="\033[1A"
    local cursor_back="\033[${size}G"
    echo "${previous_line}${cursor_back}${str}${new_line}"
}

get_exit_code() {
  local exit_code=$?
  if [[ $exit_code != 0 ]]; then
    local exit_code_warn="%{$fg[246]%}exit:%{$fg_bold[red]%}${exit_code}%{$reset_color%}"
    previous_align_right "$exit_code_warn"
  fi
}

# Get local time
get_date_time() {
  # %D: date
  # %T: time
  echo "%{$fg[yellow]%}[%{$fg[yellow]%}%D{%Y-%m-%d %H:%M:%S}%{$fg[yellow]%}]"
}

# Get user and hostname
get_user_and_hostname() {
  # %n: username
  # %m: hostname
  echo "%{$fg_bold[red]%}➜ %{$fg_bold[yellow]%}%n%{$fg[cyan]%}@%{$fg_bold[green]%}%M %{$reset_color%}"
}

# Get current directory
get_current_dir() {
  # %~: pwd
  echo "%{$fg_bold[green]%}%p%{$fg[cyan]%}%~"
}


# rev_parse_find(filename:string, path:string, output:boolean)
# reverse from path to root wanna find the targe file
# output: whether show the file path
rev_parse_find() {
    local target="$1"
    local current_path="${2:-`pwd`}"
    local whether_output=${3:-false}
    local parent_path="`dirname $current_path`"
    while [[ "$parent_path" != "/" ]]; do
        if [ -e "${current_path}/${target}" ]; then
            if $whether_output; then echo "$current_path"; fi
            return 0; 
        fi
        current_path="$parent_path"
        parent_path="`dirname $parent_path`"
    done
    return 1
}
# Get development envrioment

iscommand() { command -v "$1" > /dev/null; }
prompt_node_version() {
    if rev_parse_find "package.json" || rev_parse_find "node_modules"; then
        if iscommand node; then
            local NODE_PROMPT_PREFIX="%{$FG[239]%}using:%{$FG[120]%}"
            local NODE_PROMPT="node `node -v`"
        else
            local NODE_PROMPT_PREFIX="%{$FG[242]%}[%{$FG[009]%}need:"
            local NODE_PROMPT="Nodejs%{$FG[242]%}]"
        fi
        echo "${NODE_PROMPT_PREFIX}${NODE_PROMPT}%{$reset_color%}"
    fi
}

prompt_python_version() {
    local PYTHON_PROMPT_PREFIX="%{$FG[239]%}using:%{$FG[123]%}"
    if rev_parse_find "venv"; then
        local PYTHON_PROMPT="`$(rev_parse_find venv '' true)/venv/bin/python --version 2>&1`"
        echo "${PYTHON_PROMPT_PREFIX}${PYTHON_PROMPT}%{$reset_color%}"
    elif rev_parse_find "requirements.txt"; then
        if iscommand python; then
            local PYTHON_PROMPT="`python --version 2>&1`"
        else
            PYTHON_PROMPT_PREFIX="%{$FG[242]%}[%{$FG[009]%}need:"
            local PYTHON_PROMPT="Python%{$FG[242]%}]"
        fi
        echo "${PYTHON_PROMPT_PREFIX}${PYTHON_PROMPT}%{$reset_color%}"
    fi
}

get_dev_env() {
    local SEGMENT_ELEMENTS=(node python)
    for element in "${SEGMENT_ELEMENTS[@]}"; do
        local segment=`prompt_${element}_version`
        if [ -n "$segment" ]; then 
            echo "$segment "
            break
        fi
    done
}

# Virtualenv infomation
get_venv_info() { 
  [ $VIRTUAL_ENV ] && echo "$FG[242](%{$FG[159]%}$(basename $VIRTUAL_ENV)$FG[242])%{$reset_color%}"; 
}

# Get git action
get_git_action() {
  if [[ -z "$REV_GIT_DIR" ]]; then return 1; fi
  local action=""
  local rebase_merge="${REV_GIT_DIR}/rebase-merge"
  local rebase_apply="${REV_GIT_DIR}/rebase-apply"
	if [[ -d "$rebase_merge" ]]; then
    local rebase_step=`cat "${rebase_merge}/msgnum"`
    local rebase_total=`cat "${rebase_merge}/end"`
    local rebase_process="${rebase_step}/${rebase_total}"
  if [[ -f "${rebase_merge}/interactive" ]]; then
    action="REBASE-i"
  else
    action="REBASE-m"
  fi
	elif [[ -d "$rebase_apply" ]]; then
    local rebase_step=`cat "${rebase_apply}/next"`
    local rebase_total=`cat "${rebase_apply}/last"`
    local rebase_process="${rebase_step}/${rebase_total}"
    if [ -f "${rebase_apply}/rebasing" ]; then
        action="REBASE"
    elif [ -f "${rebase_apply}/applying" ]; then
        action="AM"
    else
        action="AM/REBASE"
    fi
  elif [ -f "${REV_GIT_DIR}/MERGE_HEAD" ]; then
      action="MERGING"
  elif [ -f "${REV_GIT_DIR}/CHERRY_PICK_HEAD" ]; then
      action="CHERRY-PICKING"
  elif [ -f "${REV_GIT_DIR}/REVERT_HEAD" ]; then
      action="REVERTING"
  elif [ -f "${REV_GIT_DIR}/BISECT_LOG" ]; then
      action="BISECTING"
  fi

	if [[ -n "$rebase_process" ]]; then
		action="$action $rebase_process"
	fi
    if [[ -n "$action" ]]; then
		action="|$action"
	fi

  echo "$action"

}

# Get git infoation
get_git_info() {
  # git_prompt_info() setting
  ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[239]%}git:%{$fg[blue]%}(%{$fg[red]%}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})%{$fg[green]%}✓%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_DIRTY="`get_git_action`%{$fg[blue]%})%{$fg[red]%}✗%{$reset_color%}"

  echo %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}
}

VIRTUAL_ENV_DISABLE_PROMPT=true

local SKYWALKER_PROMPT_PERVIOUS='`get_exit_code`'
local SKYWALKER_PROMPT_HEAD='╭─$(get_date_time) $(get_user_and_hostname) $(get_current_dir) $(get_dev_env) $(get_git_info)'
local SKYWALKER_PROMPT_FOOT='╰──➤ $(get_venv_info)'

PROMPT="$SKYWALKER_PROMPT_PERVIOUS
$SKYWALKER_PROMPT_HEAD
$SKYWALKER_PROMPT_FOOT"
