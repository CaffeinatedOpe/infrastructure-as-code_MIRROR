{ config, pkgs, lib, inputs, ... }:

{
  networking.hostName = "heimdall";
  environment.systemPackages = with pkgs; [
    headscale
  ];
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
			dns = { baseDomain = "caffeinatedope.net"; };
			server_url = "https://headscale.caffeinatedope.net:443";
      settings = {
        logtail.enabled = false;
        derp.enabled = true;
      };
    };
  };
}
