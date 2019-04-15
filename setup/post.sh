 # source rvm (debian)
source ${HOME}/.rvm/scripts/rvm
# update rvm
rvm get stable --auto-dotfiles
# Install ruby + gem
rvm use $RUBY_VERSION --install --default

# Install tmuxinator (Optional, need ruby-gem)
gem install tmuxinator




