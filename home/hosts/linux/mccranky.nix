{ config, ... }:
let
  hostName = "mccranky"; # Define your hostname.
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ../../linux/gui.nix
  ];

  programs.ssh.settings."github.com".IdentityFile = "${config.home.homeDirectory}/.ssh/${hostName}";

  modules.desktop.gaming.enable = false;
  modules.desktop.niri.enable = true;

  # Laptop defaults: backlight 3 min, screen off 6 min, lock 20 min.
  modules.desktop.hypridle = {
    keyboardBacklightTimeout = 180;
    screenOffTimeout = 360;
    lockTimeout = 1200;
  };

  # The built-in laptop speakers are quiet, so boost above the -23 dB default.
  services.easyeffects.extraPresets."loudness-normalization".output."autogain#0".target = -12.0;
}
