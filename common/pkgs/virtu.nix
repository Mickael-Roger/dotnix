{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    virt-manager
    libvirt
    qemu_full
    qemu-utils
    firecracker
    cdrkit
    virtiofsd
  ];
}
