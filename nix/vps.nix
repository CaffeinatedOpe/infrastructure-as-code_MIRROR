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
      enabled = true;
      address = "0.0.0.0";
			port = 8080;
      settings = {
        server_url = "https://headscale.caffeinatedope.net:443";
        derp.enabled = true;
      };
    };
  };
};
