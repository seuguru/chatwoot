{
  description = "A basic Ruby on Rails development environment using Nix Flakes";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-ruby}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShell = pkgs.mkShell {
          name = "rails-dev-shell";

          buildInputs = [
            nixpkgs-ruby.packages.aarch64-darwin."ruby-3.2.5"
            pkgs.libyaml
            pkgs.nodejs              # Node.js for Rails asset pipeline
            pkgs.yarn                # Yarn package manager
            pkgs.sqlite              # SQLite database (or change to your preferred DB)
            pkgs.postgresql          # PostgreSQL (if needed)
            pkgs.redis               # Redis (if needed)
            pkgs.openssl             # Required by many gems
            pkgs.libxml2             # Required by some gems
            pkgs.libxslt             # Required by some gems
            pkgs.zlib                # Required by some gems
            pkgs.gcc                 # For compiling native extensions
            pkgs.gnumake             # Make tool for some gems
            pkgs.tzdata
            pkgs.lazygit
          ];

          shellHook = ''
            # Ensure the Nix-provided Ruby is prioritized in PATH
            # Ensure Bundler is available
            if ! command -v bundle &> /dev/null; then
              gem install bundler --no-document
            fi

            # Install Rails if not already installed
            if ! command -v rails &> /dev/null; then
              gem install rails --no-document
            fi

            export BUNDLE_PATH=.bundle
            export BUNDLE_APP_CONFIG=.bundle
            export BUNDLE_DISABLE_SHARED_GEMS=true
            export CPATH=${pkgs.libyaml.dev}/include:$CPATH

            alias ra="./bin/rails"

            echo "Ruby on Rails development environment ready!"
          '';
        };
      });
}
