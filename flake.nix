{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let pkgs = nixpkgs.legacyPackages.${system};
          elm-spa-version = "0.6.4";
          elm-spa-repo = pkgs.fetchFromGitHub {
            owner = "ryannhg";
            repo = "elm-spa";
            rev = elm-spa-version;
            hash = "sha256-cZwTrwgLMsZcZwH+zys14cP4Ehy61+QJuylI6dgbq9s=";
          };
      in
        {
          packages.default = pkgs.buildNpmPackage {
            pname = "elm-spa";
            version = "6.0.4";
            src = "${elm-spa-repo}/src/cli";
            npmDepsHash = "sha256-yHcbrNkrYc+8iQ5ZZj5SJIYQxmDwq5yoYg67yfuQJBQ=";
            postInstall = ''
                        wrapProgram $out/bin/elm-spa \
                        --prefix PATH : ${pkgs.elmPackages.elm}/bin
                        '';
          };
      }
    );

}
