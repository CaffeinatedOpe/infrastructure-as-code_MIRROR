{ config, pkgs, lib, inputs, ... }:
let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/81b871c9b50f3c7115d78a45af0b42d7406abc81)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in
{
  environment.systemPackages = with pkgs; [
    unstable.headscale
  ];
  networking.hostName = "heimdall";
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  services = {
    tailscale.enable = true;
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        server_url = "https://headscale.caffeinatedope.net:443";
        dns.base_domain = "caffeinatedope.service";
        logtail.enabled = false;
        derp.enabled = true;
      };
    };
  };
}
