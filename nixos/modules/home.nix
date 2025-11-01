{ pkgs, ... }:
{
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    git
    neovim
    tmux
    fzf
    ripgrep
    fd
    starship
    zsh
  ];

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;
  programs.tmux.enable = true;
  programs.starship = {
    enable = true;
  };

  home.file.".config" = {
    source = ../../config;
    recursive = true;
  };

  home.file.".local/bin" = {
    source = ../../bin;
    recursive = true;
  };

  home.file.".ssh/config" = {
    source = ../../ssh/config;
  };
}
