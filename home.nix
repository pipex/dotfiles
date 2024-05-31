{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "flalanne";
  home.homeDirectory = "/Users/flalanne";

  fonts.fontconfig.enable = true;

  # Packages to install
  home.packages = [
    # pkgs is the set of all packages in the default home.nix implementation
    pkgs.gnumake
    pkgs.gcc
    pkgs.fzf
    pkgs.ripgrep
    pkgs.neovim
    pkgs.tmux
    pkgs.curl
    pkgs.openssh
    pkgs.lazygit
    pkgs.rustup
    pkgs.nixpkgs-fmt
    pkgs.jq
    pkgs.yq-go
    pkgs.mosh
    pkgs.bash
    pkgs.shellcheck
    pkgs.reattach-to-user-namespace
    pkgs.libiconv
    pkgs.colordiff
    (pkgs.callPackage ./balena-cli.nix {
      hash = "0m1vsww9swbl5raby00vzgb822pr8wbfsf696l609c3jdyv5yy3b"; 
      version = "18.1.5";
    })
    (pkgs.callPackage ./shell-gpt.nix { })
    (pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    pkgs.gh
    pkgs.go
    pkgs.bottom
    pkgs.gdu
    pkgs.alejandra
    pkgs.deadnix
    pkgs.statix
    pkgs.luarocks
    pkgs.python3
  ];

  # Install AstroVim
  xdg.configFile."nvim".recursive = true;
  xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    owner = "pipex";
    repo = "astrovim";
    rev = "c56993d0a30e745cda6673bbfa1daabb0cadb8a1";
    sha256 = "02v0dq6893dvq9l9iih1qj2mp39f0a2gl81ww88qf501c3f081l1";
  };
  # xdg.configFile."nvim".source = ./astronvim;

  xdg.configFile."oh-my-zsh".source = ./oh-my-zsh;

  home.file.".tmux.conf".source = ./tmux/tmux.conf;
  home.file.".tmux".recursive = true;
  home.file.".tmux".source = ./tmux;
  home.file.".tmux/plugins/tpm".source = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "v3.0.0";
    sha256 = "18q5j92fzmxwg8g9mzgdi5klfzcz0z01gr8q2y9hi4h4n864r059";
  };

  # Prettier
  home.file.".prettierrc.json".source = ./prettierrc.json;

  # Global shell aliases
  home.shellAliases = {
    ls = "ls --color=auto";
    ll = "ls -l";
    vi = "nvim";
    lg = "lazygit";
  };

  # Git config using Home Manager modules
  programs.git = {
    enable = true;
    userName = "Felipe Lalanne";
    userEmail = "1822826+pipex@users.noreply.github.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
      pull = {
        rebase = true;
      };
      core = {
        editor = "nvim";
        pager = "cat";
      };
    };
    aliases = {
      lg = "log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --all";
    };
  };

  programs.autojump = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    localVariables = {
      TZ = "America/Santiago";
      EDITOR = "nvim";
      # TERM = "screen-256color";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initExtra = ''
      export BUILDKIT_PROGRESS=plain
      export NVM_LOADED=false

      load_nvm() {
        # Do nothing if nvm has already been loaded
        [ -z "$NVM_LOADED" ] && return

        [ ! -d "$HOME/.nvm" ] && {echo "NVM not installed"; return 1}

        # Remove the custom functions created here
        unset -f node
        unset -f npm
        unset -f npx
        unset -f nvim
        unset -f nvm

        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        unset NVM_LOADED
      }


      # Create lazy versions of node/npm/nvm commands
      # that load nvm when first called 
      nvm() {
        load_nvm && nvm $*
      }

      npx() {
        load_nvm && npx $*
      }

      npm() {
        load_nvm && npm $*
      }

      node() {
        load_nvm && node $*
      }

      old_nvim=$(which nvim || echo "/bin/false")
      nvim() {
        load_nvm && nvim $* || eval $old_nvim $*
      }

      cb() {
        if [ -d .git ]; then
          ([ "$GIT_REPO_HOME" = "" ] || [ ! -d "$GIT_REPO_HOME" ]) && echo "Already in a git repository and not GIT_REPO_HOME defined" && return 1
          cd $GIT_REPO_HOME
        fi
         
        repo="$GIT_REPO"
        folder="$1"
        branch="$1"
        
        [ "$repo" = "" ] && echo "No GIT_REPO environment variable" && return 1

        if [ "$folder" = "" ]; then
          branch="$(git ls-remote --symref "git@github.com:$repo.git" HEAD | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')"
          folder="$branch"
        fi

        if [ -d "$folder" ]; then
          cd "$folder"
          [ ! -d ".git" ] && echo "Folder $folder exists but is not a git repository" && return 1
          return 0
        fi

        git clone --recurse-submodules "git@github.com:$repo.git" $folder && \
          cd $folder && \
          (git checkout $branch || git checkout -b $branch)

        if [ -f "package-lock.json" ]; then
          npm ci
        elif [ -f "package.json" ]; then
          npm i
        fi
      }
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      custom = "${config.xdg.configHome}/oh-my-zsh";
      theme = "pipex";
      extraConfig = ''
        DISABLE_MAGIC_FUNCTIONS="true";
      '';
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];
  };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
