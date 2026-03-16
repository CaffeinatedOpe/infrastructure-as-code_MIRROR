{ config, pkgs, lib, inputs, ... }: {
  networking.firewall.enable = false;
  environment.systemPackages = with pkgs; [ headscale docker-compose ];
  networking.hostName = "heimdall";

  environment.etc = {
    docker-configs = { source = ../../hosts/heimdall/docker-configs; };
  };

  virtualisation.docker = {
    enable = true;
    # Set up resource limits
    daemon.settings = {
      experimental = true;
      default-address-pools = [{
        base = "172.30.0.0/16";
        size = 24;
      }];
    };
  };
  systemd.services.my-docker-compose = {
    script = ''
      docker-compose -f ${../../hosts/heimdall/docker-compose/security.yaml}
    '';
    wantedBy = [ "multi-user.target" ];
    after = ["docker.service" "docker.socket"];
  };
}
