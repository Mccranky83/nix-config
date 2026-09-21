{
  lib,
  pkgs,
  nixos-apple-silicon,
  ...
}:
{
  imports = [
    nixos-apple-silicon.nixosModules.default
  ];

  # NOTE: do NOT autologin here (a bare session command = greetd restarts the desktop
  # without any authentication whenever the session exits, e.g. logout from the lock
  # screen would bypass it entirely). Keep tuigreet from modules/nixos/desktop.nix.

  zramSwap.memoryPercent = lib.mkForce 75;

  nix.settings = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  environment.systemPackages = with pkgs; [
    box64 # Linux Userspace x86 and x86_64 Emulator, run x86_64 apps(such as games, gui apps) on aarch64.
    # https://asahilinux.org/2024/12/muvm-x11-bridging/
    # https://github.com/nix-community/nixos-apple-silicon/issues/237
    # muvm # run x86_64 Apps/Games in a microVM, used as a workaround of apple silicon's 16k page size.
  ];

  # networking.wireless.iwd = {
  #   enable = true;
  #   settings.DriverQuirks.DefaultInterface = true;
  # };
  # configures the network interface(include wireless) via `nmcli` & `nmtui`
  networking.networkmanager.enable = true;

  # Specify path to peripheral firmware files.
  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = ./firmware;

    # since mesa 25.1(already in nixpkgs), support for asahi is enabled by default.
  };

  # Lid & PowerKey settings
  #
  # Suspend: Store system state to RAM - fast, requires minimal power to maintain RAM.
  # Hibernate: Store system state & RAM to Disk, and then poweroff the system.
  #
  # NOTE: Hibernate is not supported by Asahi Linux.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    # 'Docked' means: more than one display is connected or the system is inserted in a docking station
    HandleLidSwitchDocked = "ignore";

    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };
  systemd.targets.sleep.enable = true;
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernate = "no";
    AllowSuspendThenHibernate = "no";
    HibernateDelaySec = "5min";
  };

  # For ` to < and ~ to > (for those with US keyboards)
  # boot.extraModprobeConfig = ''
  #   options hid_apple iso_layout=0
  # '';
}
