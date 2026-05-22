{
  description = "Nix flake for rusty-path-of-building";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
    rusty-path-of-building = {
      url = "github:meehl/rusty-path-of-building";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, crane, flake-utils, rusty-path-of-building }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.mkLib pkgs;

        version = "0.2.16";

        lzip = pkgs.stdenv.mkDerivation {
          pname = "lzip";
          inherit version;
          src = "${rusty-path-of-building}/lua/libs/lzip";

          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.luajit pkgs.zlib ];

          buildPhase = ''
            make LUA_IMPL=luajit
          '';

          installPhase = ''
            install -Dm755 lzip.so $out/lib/lua/${pkgs.luajit.luaversion}/lzip.so
          '';
        };

        luaPath = lzip + "/lib/lua/${pkgs.luajit.luaversion}";

        commonArgs = {
          src = rusty-path-of-building;

          nativeBuildInputs = with pkgs; [
            pkg-config
            makeWrapper
          ];

          buildInputs = with pkgs; [
            luajit
            luajit.pkgs.lua-curl
            luajit.pkgs.luautf8
            luajit.pkgs.luasocket
            openssl
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            vulkan-loader
            libxkbcommon
            wayland
            libx11
            libxcursor
            libxi
            libxrandr
            libGL
          ];

          LUA_LIB_DIR = "${pkgs.luajit}/lib";
        };

        cargoArtifacts = craneLib.buildDepsOnly (commonArgs // {
          pname = "rusty-path-of-building-deps";
        });

        package = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;

          pname = "rusty-path-of-building";
          inherit version;

          postInstall = ''
            install -Dm444 ${rusty-path-of-building}/assets/icon.png $out/share/icons/hicolor/256x256/apps/path-of-building.png
          '' + pkgs.lib.optionalString pkgs.stdenv.isLinux ''
            mkdir -p $out/share/applications

            cat > $out/share/applications/rusty-path-of-building-poe1.desktop << 'DESKTOP'
            [Desktop Entry]
            Name=Path of Building
            Comment=Offline build planner for Path of Exile
            Exec=rusty-path-of-building poe1
            Terminal=false
            Type=Application
            Icon=path-of-building
            Categories=Game;
            Keywords=poe;pob;pobc;path;exile;
            DESKTOP

            cat > $out/share/applications/rusty-path-of-building-poe2.desktop << 'DESKTOP'
            [Desktop Entry]
            Name=Path of Building 2
            Comment=Offline build planner for Path of Exile 2
            Exec=rusty-path-of-building poe2
            Terminal=false
            Type=Application
            Icon=path-of-building
            Categories=Game;
            Keywords=poe;pob;pobc;path;exile;
            DESKTOP
          '';

          postFixup = pkgs.lib.optionalString pkgs.stdenv.isLinux ''
            patchelf $out/bin/rusty-path-of-building \
              --add-rpath ${pkgs.lib.makeLibraryPath [
                pkgs.libxkbcommon
                pkgs.vulkan-loader
                pkgs.wayland
                pkgs.libx11
                pkgs.libxcursor
                pkgs.libxi
              ]}
          '' + ''
            wrapProgram $out/bin/rusty-path-of-building \
              --set LUA_PATH "${luaPath}/?.lua;$LUA_PATH" \
              --set LUA_CPATH "${luaPath}/?.so;$LUA_CPATH"
          '';
        });
      in
      {
        packages = {
          default = package;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ package ];
          packages = with pkgs; [ cargo rustc rust-analyzer clippy rustfmt ];
        };
      }
    );
}
