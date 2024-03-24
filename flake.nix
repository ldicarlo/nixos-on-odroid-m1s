{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    uboot-src = {
      flake = false;
      url = "github:u-boot/u-boot?rev=83cdab8b2c6ea0fc0860f8444d083353b47f1d5c";
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
      # https://github.com/gytis-ivaskevicius/orangepi-r1-plus-nixos-image/blob/3b6eb16c7aa406e10a9d8a0301bbe7a5a1cc7fe6/flake.nix#L30
      packages.uboot = pkgs.buildUBoot rec {
        extraMakeFlags = [ "all" "u-boot.itb" ];
        defconfig = "nanopi-r2s-rk3328_defconfig";
        extraMeta = {
          platforms = [ "aarch64-linux" ];
          license = pkgs.lib.licenses.unfreeRedistributableFirmware;
        };
        src = uboot;
        version = uboot.rev;
      };

    }



