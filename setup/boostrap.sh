#/usr/bin/env zsh
set -e

UNAME=`whoami`
DOTFILES=${HOME}/.dotfiles

is_command() { command -v $@ &> /dev/null; }

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

install_ohmyzsh() {
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    info "Installing oh-my-zsh..." >&2
    curl -fsSL install.ohmyz.sh | sh 1>&2
  fi
}

check_dotfile() {
  if [ ! -d ${DOTFILES} ]; then
    git clone git@github.com:SharkIng/.dotfiles.git ${DOTFILES}
  fi
}

(check_dotfile && install_ohmyzsh) || exit 1

link_file() {
  ln -fs $1 $2
  success "Symlinked $1 to $2"
}

symlink_dotfiles() {
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
  
  link_file ${DOTFILES}/zsh/motd/motd /etc/motd
}

symlink_dotfiles

install_python_venv() {
  # Install virtualenv
  pip install virtualenv 1>&2
  pip3 install virtualenv 1>&2
}

install_python_venv

install_rvm() {
  RUBY_VIERSION=2.6.2

  # Install RVM
  # Add Repo Keys
  gpg2 --recv-keys \
    409B6B1796C275462A1703113804BB82D39DC0E3 \
    7D2BAF1CF37B13E2069D6956105BD0E739499BDB

  # Install rvm
  \curl -sSL https://get.rvm.io | bash -s stable 1>&2
}

install_rvm

# Install Ruby
source ${HOME}/.rvm/scripts/rvm
# update rvm
rvm get stable --auto-dotfiles
# Install ruby + gem
rvm use $RUBY_VERSION --install --default

# Install system configs
${DOTFILES}/setup/system/plugins.sh
${DOTFILES}/setup/system/vim.sh
${DOTFILES}/setup/system/tmux.sh

# Install docker need sudo
sudo ${DOTFILES}/setup/system/docker.sh $UNAME

# Mike Directory
mkdir -p ${HOME}/dev/{$USER,repos,go,dockers,scripts,projects,virtualenv}