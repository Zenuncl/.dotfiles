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
    git clone https://github.com/SharkIng/.dotfiles.git ${DOTFILES}
  fi
}

(check_dotfile && install_ohmyzsh) || exit 1

is_correct_repo() {
  CHECK_PATH=$1
  USER_AND_REPO=$2

  remote_url=$(git -C ${CHECK_PATH} remote get-url origin)
  
  if [[ $remote_url == "https://github.com/${USER_AND_REPO}.git" ]]; then
    echo "The remote repo check passed. Continue..."
  else
    echo "The remote repo check failed. Reconfigure the dotfiles..."
  fi  
}

link_file() {
  dest=$2
  if [ -f ${dest} ] || [ -d ${dest} ]
  then
    info "Backing up original files..."
    mv ${dest} ${dest}.original
    ln -fs $1 $2
  else
    ln -fs $1 $2
  fi
  success "Symlinked $1 to $2"
}

symlink_dotfiles() {
  # Symlink original files.
  info "Symlinking dotfiles..."
  for source in `find ${DOTFILES} -maxdepth 2 -name \*.symlink`
  do
    dest="${HOME}/.`basename \"${source%.*}\"`"
    link_file ${source} ${dest}
  done

  # Symlink oh-my-zsh custom files
  info "Symlinking oh-my-zsh custom files..."
  link_file ${DOTFILES}/zsh/plugins/skywalker ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/skywalker
  link_file ${DOTFILES}/zsh/themes/skywalker.zsh-theme ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/skywalker.zsh-theme

  # Symlink .config subdirectories
  if [ ! -d "${HOME}/.config" ]; then
    mkdir -p ${HOME}/.config
  fi
  link_file ${DOTFILES}/config/git ${HOME}/.config/git
  link_file ${DOTFILES}/config/alacritty ${HOME}/.config/alacritty
  link_file ${DOTFILES}/config/starship ${HOME}/.config/starship
  if [ ! -d "${HOME}/.config/awesome" ]; then
    git clone --recurse-submodules --remote-submodules \
      --depth 1 -j 2 https://github.com/lcpz/awesome-copycats.git /tmp/awesome && \
      mv -bv /tmp/awesome/{*,.[^.]*} ${HOME}/.config/awesome; rm -rf /tmp/awesome
    success "Successfully cloned awesome-copycat repo to ~/.config/awesome..."
  else
    link_file ${DOTFILES}/config/awesome/rc.lua ${HOME}/.config/awesome/rc.lua
    link_file ${DOTFILES}/config/awesome/themes/skywalker ${HOME}/.config/awesome/themes/skywalker
  fi
}

symlink_dotdir() {
  link_file ${DOTFILES}/bin ${HOME}/.bin
  link_file ${DOTFILES}/ssh ${HOME}/.ssh
  if [ -d "${HOME}/.ssh.original/" ]; then
    mv ${HOME}/.ssh.original/* ${HOME}/.ssh/
    rm -rf ${HOME}/.ssh.original
    success "Copied old .ssh files to ssh directory..."
  fi
}

# Link motd file
sudo ln -fs ${DOTFILES}/setup/motd/motd /etc/motd

# Mike Directory
mkdir -p ${HOME}/dev/{$USER,repos,go,dockers,scripts,projects,virtualenv}

# Install system configs
if ! [ -d ${HOME}/.vim ]; then
  ${DOTFILES}/setup/system/20-vim.sh
elif ! [ -d ${HOME}/.tmux ]; then
  ${DOTFILES}/setup/system/20-tmux.sh
fi
cat ${DOTFILES}/setup/system/25-plugins.sh | bash

symlink_dotfiles
symlink_dotdir

chsh -s /usr/bin/zsh
