{ pkgs, lib, config, inputs, ... }:

{
  packages = [ pkgs.nodePackages.pnpm ];
  languages.javascript.pnpm = {
    enable = true;
    install.enable = true;
  };
}
