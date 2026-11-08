{ pkgs, ... }:

let
  username = "branden";
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in {
  home.username = username;
  home.homeDirectory = if isLinux then "/home/branden" else "/Users/branden";

  home.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # CLIs
    git
    git-machete
    gh
    tmux
    zsh
    starship
    tree-sitter
    ripgrep
    claude-code
    glow

    # Builds
    scala-cli
    nodejs_22
    jdk25
    maven

    # Language Servers
    nil
    emmylua-ls
    lombok
    jdt-language-server
    nil
    vtsls
    vue-language-server
    metals

    # Apps
    kitty
    slack

    # Music
    kew
    psst
    spotify

    # Fonts
    nerd-fonts.iosevka
  ] ++ (if isLinux then with pkgs; [ openvpn3 ] else []);

  home.file = {};

  home.sessionVariables = with pkgs; {
    JDTLS_JVM_ARGS = "-javaagent:${lombok.outPath}/share/java/lombok.jar";
    JDTLS_PATH = "${jdt-language-server.outPath}/bin/jdtls";

    JAVA_HOME = "${jdk25.outPath}";

    BKT_CONFIG_DIR = "$HOME/.config/bkt";

    VUE_LS_PATH = "${vue-language-server}/lib/language-tools/packages/language-server";

    GIT_EDITOR = "nvim";
    GIT_MACHETE_EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      set -g status-left-length 40
      set -g status-style bg=default
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {};

    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "lambda";
    };

    profileExtra = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
    '';
  };

  programs.starship = import ./starship.nix;

  programs.kitty = {
    enable = true;
    font = {
      name = "GoMono Nerd Font";
      size = 12;
    };
    themeFile = "PencilLight";
  };

  programs.neovim = with pkgs; import ./neovim.nix {
    inherit vimPlugins;
    inherit awesomeNeovimPlugins;
    inherit lombok;
  };

  programs.firefox = {
    enable = true;

    profiles.default = {
      extensions = {
        packages = with pkgs.firefoxAddons; [
          pkgs.firefoxAddons."1password-x-password-manager"
          darkreader
          ublock-origin
          kagi-search-for-firefox
        ];
      };

      settings = {
        "browser.startup.homepage" = "https://glance.branden.cafe";
      };
    };

    configPath = "Library/Application Support/org.nixos.firefox";
  };

  programs.gh = {
    enable = true;
    settings = {
      pager = "cat";
      git_protocol = "https";
      editor = "nvim";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      aliases = {
        co = "pr checkout";
      };
      spinner = "enabled";
    };
  };
}
