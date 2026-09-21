{ lib }:
{
  username = "mccranky";
  userfullname = "Annan Cai";
  useremail = "berkeleyblue02@gmail.com";
  networking = import ./networking.nix { inherit lib; };
  # Generated using: mkpasswd -m yescrypt --rounds=11
  # Password: long, strong random string (full charset)
  # Rotation policy: changed annually
  # Purpose: system login password only
  # https://man.archlinux.org/man/crypt.5.en
  initialHashedPassword = "$y$jFT$RG/sBZdarLggiHUk8qt9I0$tgGEtgtbhIK2e.q0hJuUpZxpcusBTtWqosPiLuPY4yA";
  # Public Keys that can be used to login to all my PCs, Macbooks, and servers.
  #
  # Since its authority is so large, we must strengthen its security:
  # 1. The corresponding private key must be:
  #    1. Generated locally on every trusted client via:
  #      ```bash
  #      # KDF: bcrypt with 256 rounds, takes 2s on Apple M2):
  #      # Passphrase: digits + letters + symbols, 12+ chars
  #      ssh-keygen -t ed25519 -a 256 -C "ryan@xxx" -f ~/.ssh/xxx
  #      ```
  #    2. Never leave the device and never sent over the network.
  # 2. Or just use hardware security keys like Yubikey/CanoKey.
  mainSshAuthorizedKeys = [
    # The main ssh keys for daily usage
  ];
  secondaryAuthorizedKeys = [
    # the backup ssh keys for disaster recovery
  ];
}
