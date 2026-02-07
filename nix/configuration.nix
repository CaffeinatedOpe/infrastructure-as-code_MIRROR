# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Bootloader.
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  sops = {
      defaultSopsFile = ./secrets/secrets.yaml;
      age.keyFile = "/var/lib/sops-nix/key.txt";
      secrets.password.neededForUsers = true;
      secrets.k3s-token = { };
  };
  security.sudo.wheelNeedsPassword = false;

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

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    usbutils
    rclone
    kakoune
    pnpm
    ffmpeg
    wget
    zsh
    fastfetch
    hyfetch
    git
    curl
    nfs-utils
    tailscale
    htop
    kitty
    nfs-utils
    libnfs
    bash
    fuse
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucy = {
    isNormalUser = true;
    description = "Lucy Fiedler";
    extraGroups = [ "wheel" "docker" "plugdev" ];
    hashedPasswordFile = config.sops.secrets.password.path;
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLwnw2cHE9/HeSkdJzs3zq76eZPPX4aKGj/zCu4joWM lucy"
    ];	
  };

  programs = rec {
    zsh.enable = true;
    zsh.ohMyZsh.enable = true;
  };

  services = {
    logind.settings.Login.HandlePowerKey = "ignore";
    rpcbind.enable = true;
    xserver.videoDrivers = [ "i915" ];
    openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
  	settings.KbdInteractiveAuthentication = false;
    };
    k3s = {
      enable = true;
      role = "server";
      tokenFile = config.sops.secrets.k3s-token.path;
    };
    openiscsi.enable = true;
    openiscsi.name = "${config.networking.hostName}";
  };

  system.stateVersion = "25.11";

}
