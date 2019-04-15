#/usr/bin/env zsh

export DOTFILES=${HOME}/.dotfiles

if [ ! -d ${DOTFILES} ]; then
  git clone git@github.com:SharkIng/.dotfiles.git ${DOTFILES}
fi

# Mike Directory
mkdir -p ${HOME}/dev/{$USER,repos,go,dockers,scripts,projects,venv}

is_command() { command -v $@ &> /dev/null; }

install_ohmyzsh() {
  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    echo "Installing oh-my-zsh..." >&2
    curl -fsSL install.ohmyz.sh | sh
  fi
}

install_ohmyzsh || exit 1

symlink_dotfiles() {
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

install_ruby || exit 1

# Install system configs
${DOTFILES}/setup/system/plugins.sh
${DOTFILES}/setup/system/vim.sh
${DOTFILES}/setup/system/tmux.sh
