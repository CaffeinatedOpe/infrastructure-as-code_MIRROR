{ config, pkgs, lib, inputs, ... }:
{
	networking.firewall.enable = false;
  environment.systemPackages = with pkgs; [ headscale ];
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
