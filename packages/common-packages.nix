{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ######## Text editors ########
    vim

    ######## CLI QoL tools ########
    tmux

    ######## Monitoring & tools ########
    fastfetch
    wireguard-tools
    btop # Task manager
    iotop
    dool # dstat "fork"
    acpi # Battery level
    ncdu # Disk space
    usbutils
    smartmontools # smartctl
    hdparm
    dig
    wget
    unzip

    ######## Etc. ########
    iptables
    openssl # Generate secure passwords with: $ openssl rand -base64 48
  ];
}
