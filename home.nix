{ config, lib, pkgs, ... }:

{
  home.username = "mccranky";
  home.homeDirectory = "/home/mccranky";

  home.packages = with pkgs; [
    git
  ];
  home.stateVersion = "26.11";
}
