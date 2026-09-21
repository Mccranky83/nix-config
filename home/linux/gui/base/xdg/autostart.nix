{
  pkgs,
  pkgs-master,
  lib,
  ...
}:
{
  # XDG autostart entries. All of them are globally ordered after the
  # xdg-desktop-portal stack via `systemd.user.units."app-@autostart.service"`
  # in modules/nixos/desktop/xdg.nix, so sandboxed apps (nixpak: firefox,
  # telegram, ...) don't race the portal at login and end up with broken
  # FileChooser/OpenURI until manually restarted.
  xdg.autostart.enable = true;
  # This fixes nixpak sandboxed apps (like firefox) accessing mapped folders correctly
  xdg.autostart.entries = [
    "${pkgs.foot}/share/applications/foot.desktop"
    "${pkgs.alacritty}/share/applications/Alacritty.desktop"

    # nixpaks
    "${pkgs.firefox}/share/applications/firefox.desktop"
    "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
  ];
}
