#/usr/bin/env zsh
set -e

UNAME=`whoami`
DOTFILES=${HOME}/.dotfiles

function is_command() { command -v $@ &> /dev/null; }

function info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

function success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

function fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

function install_ohmyzsh() {
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    info "Installing oh-my-zsh..." >&2
    curl -fsSL install.ohmyz.sh | sh 1>&2
  fi
}

function check_dotfile() {
  if [ ! -d ${DOTFILES} ]; then
    git clone git://github.com/SharkIng/.dotfiles.git ${DOTFILES}
  fi
}

(check_dotfile && install_ohmyzsh) || exit 1

function is_correct_repo() {
  CHECK_PATH=$1
  USER_AND_REPO=$2

  remote_url=$(git -C ${CHECK_PATH} remote get-url origin)
  
  if [[ $remote_url == "https://github.com/${USER_AND_REPO}.git" ]]; then
    echo "The remote repo check passed. Continue..."
  else
    echo "The remote repo check failed. Reconfigure the dotfiles..."
  fi  
}

function link_file() {
  ln -fs $1 $2
  success "Symlinked $1 to $2"
}

function symlink_dotfiles() {
  # Symlink original files.
  info "Symlinking dotfiles..."
  for source in `find ${DOTFILES} -maxdepth 2 -name \*.symlink`
  do
    dest="${HOME}/.`basename \"${source%.*}\"`"
    if [ -f $dest ] || [ -d $dest ]
    then
      info "Backing up original files..."
      mv $dest{,.original}
      link_file ${source} ${dest}
    else
      link_file ${source} ${dest}
    fi
  done

  # Symlink oh-my-zsh custom files
  info "Symlinking oh-my-zsh custom files..."
  link_file ${DOTFILES}/zsh/plugins/skywalker ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/
  link_file ${DOTFILES}/zsh/themes/skywalker.zsh-theme ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/
}

function install_rvm() {
  RUBY_VIERSION=3.2.2

  # Install RVM
  # Add Repo Keys
  gpg2 --recv-keys \
    409B6B1796C275462A1703113804BB82D39DC0E3 \
    7D2BAF1CF37B13E2069D6956105BD0E739499BDB

  # Install rvm
  \curl -sSL https://get.rvm.io | bash -s stable 1>&2
}

function install_nvm() {
  NODE_VIERSION=18.16.1
  NPM_VERSION=9.5.1

  # Install nvm
  \curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
}

if ! [ -d ${HOME}/.rvm ]; then
	install_rvm
elif ! [ -d ${HOME}/.nvm ]; then
	install_nvm
fi

# Install docker need sudo
sudo ${DOTFILES}/setup/system/docker.sh $UNAME
sudo ln -fs ${DOTFILES}/setup/motd/motd /etc/motd

# Mike Directory
mkdir -p ${HOME}/dev/{$USER,repos,go,dockers,scripts,projects,virtualenv}

# Install system configs
if ! [ -d ${HOME}/.vim ]; then
  ${DOTFILES}/setup/system/vim.sh
elif ! [ -d ${HOME}/.tmux ]; then
  ${DOTFILES}/setup/system/tmux.sh
fi
cat ${DOTFILES}/setup/system/plugins.sh | bash

symlink_dotfiles
