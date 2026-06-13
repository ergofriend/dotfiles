{
  description = "ergofriend dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      home-manager,
      nixpkgs,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkHome =
        {
          homeDirectory,
          system,
          username,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [
            ./nix/home-manager/home.nix
            {
              home = {
                inherit homeDirectory username;
              };
            }
          ];
        };
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          skillspector = pkgs.mkShell {
            packages = with pkgs; [
              git
              gnumake
              python312
              uv
            ];
          };
        }
      );

      homeConfigurations = {
        kasu-linux = mkHome {
          system = "x86_64-linux";
          username = "kasu";
          homeDirectory = "/home/kasu";
        };

        kasu-darwin = mkHome {
          system = "aarch64-darwin";
          username = "kasu";
          homeDirectory = "/Users/kasu";
        };

      };
    };
}
