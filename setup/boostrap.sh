#/usr/bin/env zsh

export DOTFILES=${HOME}/.dotfiles

if [ ! -d ${DOTFILES} ]; then
  git clone git@github.com:SharkIng/.dotfiles.git ${DOTFILES}
fi

# Mike Directory
mkdir -p ${HOME}/dev/{$USER,repos,go,dockers,scripts,projects,venv}

source ${DOTFILES}/bin/install_pkg.sh
source ${DOTFILES}/bin/is_command.sh

install_zsh() {
    # other ref: https://unix.stackexchange.com/questions/136423/making-zsh-default-shell-without-root-access?answertab=active#tab-top
    local UNAME="$1"
    if [ -z "${ZSH_VERSION}" ]; then
        if is_command zsh || install_via_manager zsh; then
            chsh $UNAME -s `command -v zsh`
            return 0
        else
            echo "ERROR, plz install zsh manual."
            return 1
        fi
    fi
}

install_ohmyzsh() {
  if [[ ! -d "${HOME}/.oh-my-zsh" && (-z "${ZSH}" || -z "${ZSH_CUSTOM}") ]]; then
    echo "Installing oh-my-zsh..." >&2
    install_via_manager git
    curl -fsSL install.ohmyz.sh | sh
  fi
}

(install_zsh "$1" && install_ohmyzsh) || exit 1

symlink_zsh_dotfiles() {
  # Symlink custome zsh files
  ln -fs ${DOTFILES}/zsh/env.symlink ${HOME}/.env
  ln -fs ${DOTFILES}/zsh/zshrc.symlink ${HOME}/.zshrc

  ln -fs ${DOTFILES}/zsh/plugins/skywalker ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/
  ln -fs ${DOTFILES}/zsh/themes/skywalker.zsh-theme ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/

  # Symlink git global configs
  ln -fs ${DOTFILES}/git/gitconfig.symlink ${HOME}/.gitconfig
  ln -fs ${DOTFILES}/git/gitignore.symlink ${HOME}/.gitignore
}

symlink_dotfiles

install_python_venv() {
  # Install virtualenv
  pip install virtualenv
  pip3 install virtualenv
}

install_python_venv

install_ruby() {
  RUBY_VIERSION=2.6.2

  # Install RVM
  # Add Repo Keys
  gpg2 --recv-keys \
    409B6B1796C275462A1703113804BB82D39DC0E3 \
    7D2BAF1CF37B13E2069D6956105BD0E739499BDB

  # Install rvm
  \curl -sSL https://get.rvm.io | bash -s stable

  # Add rvm group to user
  usermod -aG rvm sharking

  # source rvm (debian)
  source ${HOME}/.rvm/scripts/rvm

  # Install ruby + gem
  rvm get stable --auto-dotfiles
  rvm use $RUBY_VERSION --install --default
}

install_ruby

# Install system configs
${DOTFILES}/setup/system/plugins.sh
${DOTFILES}/setup/system/vim.sh
${DOTFILES}/setup/system/tmux.sh

# Install applications (using apt-get need sudo)
${DOTFILES}/setup/docker/docker.sh
