{ config, pkgs, lib, inputs, ... }: {
  networking.firewall.enable = false;
  environment.systemPackages = with pkgs; [ headscale ];
  networking.hostName = "heimdall";
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  environment.etc = {
    etc-files = {
      source = "/home/lucy/projects/infrastructure-as-code/nix/heimdall/config.yaml";
      mode = "0440";
    };
  };
}
