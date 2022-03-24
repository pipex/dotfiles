{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "me";
  home.homeDirectory = "/home/me";

  # Packages to install
  home.packages = [
    # pkgs is the set of all packages in the default home.nix implementation
    pkgs.gnumake
    pkgs.gcc
    pkgs.nodejs-12_x
    pkgs.fzf
    pkgs.ripgrep
    pkgs.neovim
    pkgs.procps
    pkgs.tmux
    pkgs.curl
    pkgs.nixpkgs-fmt
    pkgs.openssh
    pkgs.lazygit
    pkgs.stylua
    pkgs.bash
  ];

  # Raw configuration files
  # home.file.".tmux/plugins/tpm".source = ./tools/tpm;
  # home.file.".tmux.conf".source = ./tmux.conf;
  # Install AstroVim
  home.file.".config/nvim".recursive = true;
  home.file.".config/nvim".source = pkgs.fetchFromGitHub {
    owner = "kabinspace";
    repo = "AstroVim";
    rev = "8478bba8c0bc9b0aaefd39fa3254c595db2a464d";
    sha256 = "0x1vp0aywn45dh64pgxybyw2csfmf3gjh1cbg4jjflcgb8i488dz";
  };
  home.file.".config/nvim/lua/user".source = ./astrovim;
  home.file."${config.xdg.configHome}/oh-my-zsh".source = ./oh-my-zsh;


  # Git config using Home Manager modules
  programs.git = {
    enable = true;
    userName = "pipex";
    userEmail = "1822826+pipex@users.noreply.github.com";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -l";
      update = "home-manager switch";
      vi = "nvim";
      lg = "lazygit";
    };
    localVariables = {
      TZ = "America/Santiago";
      TERM = "screen-256color";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      custom = "${config.xdg.configHome}/oh-my-zsh";
      theme = "pipex";
    };
  };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
