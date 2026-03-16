# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  services.k3s.clusterInit = true;
  networking.hostName = "cerberus-0"; # Define your hostname.
}
