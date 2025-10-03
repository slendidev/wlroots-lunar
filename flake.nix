{
  description = "Flake building local wlroots";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        wlrootsLocal = pkgs.stdenv.mkDerivation {
          pname = "wlroots";
          version = "local";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            meson
            ninja
            pkg-config
            wayland-scanner
            glslang
            hwdata
            wayland
            xwayland
            cairo
          ];

          buildInputs = with pkgs; [
            libliftoff
            libdisplay-info
            libGL
            libcap
            libinput
            libxkbcommon
            libgbm
            pixman
            seatd
            vulkan-loader
            wayland
            wayland-protocols
            xorg.libX11
            xorg.xcbutilerrors
            xorg.xcbutilimage
            xorg.xcbutilrenderutil
            xorg.xcbutilwm
            lcms2
            cmake
          ];

          mesonFlags = [
            "-Dxwayland=enabled"
          ];

          # Optionally, your postFixup from above:
          postFixup = ''
            mkdir -p $examples/bin
            cd ./examples
            for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
              cp "$binary" "$examples/bin/wlroots-$binary"
            done
          '';

          outputs = [
            "out"
            "examples"
          ];

          meta = with pkgs.lib; {
            description = "Modular Wayland compositor library (local build)";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };
      in
      {
        packages.default = wlrootsLocal;
      }
    );
}
