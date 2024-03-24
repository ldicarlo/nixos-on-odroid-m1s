{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    uboot-src = {
      flake = false;
      url = "github:ldicarlo/u-boot-m1s";
      # url = "github:ldicarlo/u-boot-m1s?rev=83cdab8b2c6ea0fc0860f8444d083353b47f1d5c";
    };
  };
  description = "Build image";
  outputs = { self, nixpkgs, uboot-src, nixos-hardware, ... }:
    let
      x86_64pkgs = nixpkgs.legacyPackages.${"x86_64-linux"};
    in
    rec {
      devShells.x86_64-linux.default = x86_64pkgs.mkShell
        {
          buildInputs = with x86_64pkgs;
            [
              dtc
              minicom
              screen
              picocom
              usbutils
              zlib
              bison
              flex
              gcc
            ];
        };
      packages.x86_64-linux.uboot = x86_64pkgs.pkgsCross.aarch64-multiplatform.buildUBoot {
        version = uboot-src.shortRev;
        src = uboot-src;
        defconfig = "odroid-c4_defconfig";
        #  extraMeta.platforms = [ "aarch64-linux" ];
        filesToInstall = [
          #   "u-boot.itb"
          #   "spl/u-boot-spl.bin"
        ];
        makeFlags = [
          # "ARCH=arm64"
          # "SHELL=${pkgs.bash}/bin/bash"
          # "DTC=${pkgs.dtc}/bin/dtc"
          # "CROSS_COMPILE=${pkgs.stdenv.cc.targetPrefix}"

        ];
        patches = [ ];
      };
    };

}



