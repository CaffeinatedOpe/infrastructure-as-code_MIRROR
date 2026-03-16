{ config, pkgs, lib, inputs, ... }:

{
  hardware.graphics = { 
    enable = true;
    extraPackages = with pkgs; [ 
      vpl-gpu-rt
      intel-media-driver 
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  services = {
    logind.settings.Login.HandlePowerKey = "ignore";
    xserver.videoDrivers = [ "i915" ];
    k3s = {
      enable = true;
      role = "server";
      tokenFile = config.sops.secrets.k3s-token.path;
    };
    openiscsi.enable = true;
    openiscsi.name = "${config.networking.hostName}";
  };
}
