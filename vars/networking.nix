{ lib }:
rec {
  nameservers = [
    # IPv4
    "119.29.29.29" # DNSPod https://www.dnspod.cn/Products/publicdns
    "223.5.5.5" # AliDNS
    "1.1.1.1" # Cloudflare https://one.one.one.one/dns/
    # IPv6
    "2402:4e00::" # DNSPod
    "2400:3200::1" # Alidns
    "2606:4700:4700::1111" # Cloudflare
  ];

  ssh = {
    # this config will be written to /etc/ssh/ssh_known_hosts
    knownHosts =
      lib.attrsets.mapAttrs
        (host: value: {
          hostNames = [ host ];
          publicKey = value.publicKey;
        })
        {
          # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
          "github.com".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
  };
}
