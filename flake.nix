{
  description = "Personal computer home manager config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
    systems = {
      url = "github:nix-systems/default";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-awesome-neovim-plugins = {
      url = "github:m15a/flake-awesome-neovim-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    firefox-addons = {
      url = "github:osipog/nix-firefox-addons";
    };
  };

  outputs = inputs@{ nixpkgs, flake-utils, home-manager, flake-awesome-neovim-plugins, firefox-addons, ... }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          flake-awesome-neovim-plugins.overlays.default
          firefox-addons.overlays.default
        ];
      };
    in
    {
      packages.home-manager = pkgs.home-manager;

      packages.homeConfigurations = {
        branden = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home.nix
          ];
        };
      };
    });
}
