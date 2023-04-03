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
          elm-spa-version = "6.0.4";
          elm-spa-repo = pkgs.fetchFromGitHub {
            owner = "ryannhg";
            repo = "elm-spa";
            rev = elm-spa-version;
            hash = "sha256-cZwTrwgLMsZcZwH+zys14cP4Ehy61+QJuylI6dgbq9s=";
          };
      in
        {
          packages = {
            default = pkgs.buildNpmPackage {
              pname = "elm-spa";
              version = elm-spa-version;
              src = "${elm-spa-repo}/src/cli";
              npmDepsHash = "sha256-yHcbrNkrYc+8iQ5ZZj5SJIYQxmDwq5yoYg67yfuQJBQ=";
              postInstall = ''
                        wrapProgram $out/bin/elm-spa \
                        --prefix PATH : ${pkgs.elmPackages.elm}/bin
                        '';
            };
            elmSpa = self.packages.${system}.default;
            elmSpaGen = pkgs.stdenvNoCC.mkDerivation {
              name = "elm-spa-gen";
              src = ./.;
              buildDependencies = [ self.packages.${system}.default ];
              buildPhase = "${self.packages.${system}.default}/bin/elm-spa gen";
              installPhase = "mkdir $out; cp -r .elm-spa $out";
              meta.description = "Create the .elm-spa directory for elm-spa to use.";
            };
          };
      }
    );

}
