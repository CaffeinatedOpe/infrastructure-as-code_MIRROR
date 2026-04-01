# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disk-config.nix
  ];
  hardware.cpu.x86.msr.enable = true;

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

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

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
    description = "Lucy";
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
    rpcbind.enable = true;
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
  };
  system.stateVersion = "25.11";
}
