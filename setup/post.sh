# Install ruby + gem
rvm use $RUBY_VERSION --install --default

# Install tmuxinator (Optional, need ruby-gem)
gem install tmuxinator

# Install applications (using apt-get need sudo)
${DOTFILES}/setup/docker/docker.sh

# Mike Directory
mkdir -p ${HOME}/dev/{$USER,repos,go,dockers,scripts,projects,virtualenv}