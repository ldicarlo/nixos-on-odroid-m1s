{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    uboot = {
      flake = false;
      # url = "github:u-boot/u-boot?rev=83cdab8b2c6ea0fc0860f8444d083353b47f1d5c"; # this is the current nixos version of u-boot
      url = "github:ldicarlo/u-boot-m1s/uboot-m1s"; # this is the current version in nixos with the patch for the M1S
      # url = "github:rockchip-linux/u-boot";
    };
  };
  description = "Build image";
  outputs = { self, nixpkgs, uboot, nixos-hardware, ... }:
    let
      x86_64pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
      aarch64pkgs = import nixpkgs { system = "aarch64-linux"; config.allowUnfree = true; };
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
      defaultPackage.uboot = x86_64pkgs.pkgsCross.aarch64-multiplatform.buildUBoot rec {
        extraMakeFlags = [
          # "ARCH=arm64"
          # "CROSS_COMPILE=aarch64-linux-gnu-"
        ];
        # defconfig = "nanopi-r2s-rk3328_defconfig";
        defconfig = "odroid-m1s-rk3566_defconfig";
        # defconfig = "rk3568_defconfig";
        extraMeta = {
          platforms = [ "aarch64-linux" ];
          license = x86_64pkgs.lib.licenses.unfreeRedistributableFirmware;
        };
        src = uboot;
        version = uboot.rev;
        filesToInstall = [ "u-boot.itb" "idbloader.img" "u-boot-rockchip.bin" ];
        patches = [ ];
        # BL31 = "${aarch64pkgs.rkbin}/bin/rk35/rk3588_bl31_v1.45.elf";
        BL31 = "${aarch64pkgs.rkbin}/bin/rk35/rk3568_bl31_v1.44.elf";
      };

    };



}
