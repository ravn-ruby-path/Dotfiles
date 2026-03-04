{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.hydenix.inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.nixosModules.default
    ./modules/system
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users."ravn" =
      { ... }:
      {
        imports = [
          inputs.hydenix.homeModules.default
          ./modules/hm
        ];
      };
  };

  users.users.ravn = {
    isNormalUser = true;
    initialPassword = "0394661280";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;
  };

  hydenix = {
    enable = true;
    hostname = "ravn";
    timezone = "America/El_Salvador";
    locale = "en_US.UTF-8";
  };

  # ═══════════════════════════════════════════════════════════════
  # 🚀 CONFIGURACIÓN DE RED - OVERRIDE AGRESIVO DE DNS
  # ═══════════════════════════════════════════════════════════════

  networking = {
    networkmanager = {
      enable = true;
      dns = lib.mkForce "default";
      
      # Insertar DNS que sobrescriben DHCP
      insertNameservers = [ "1.1.1.1" "1.0.0.1" "9.9.9.9" ];
      
      wifi.powersave = false;
      ethernet.macAddress = "preserve";
      
      # Script para forzar DNS después de cada cambio de red
      dispatcherScripts = [
        {
          source = pkgs.writeText "force-cloudflare-dns" ''
            #!/bin/sh
            # Este script se ejecuta cada vez que cambia el estado de red
            
            INTERFACE="$1"
            ACTION="$2"
            
            # Solo actuar en la interface ethernet y cuando está up
            if [ "$INTERFACE" = "enp0s31f6" ] && [ "$ACTION" = "up" ]; then
              # Forzar DNS de Cloudflare
              ${pkgs.systemd}/bin/resolvectl dns "$INTERFACE" 1.1.1.1 1.0.0.1 9.9.9.9
              ${pkgs.systemd}/bin/resolvectl domain "$INTERFACE" '~.'
              ${pkgs.systemd}/bin/resolvectl dnsovertls "$INTERFACE" yes
              
              # Log para debug
              echo "$(date): Forced DNS on $INTERFACE" >> /var/log/dns-override.log
              ${pkgs.systemd}/bin/resolvectl status "$INTERFACE" >> /var/log/dns-override.log
            fi
          '';
          type = "basic";
        }
      ];
    };
    
    # DNS a nivel de sistema
    nameservers = lib.mkForce [ 
      "1.1.1.1"
      "1.0.0.1"
      "9.9.9.9"
    ];
    
    search = [ ];
    
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      
      # Bloquear completamente los DNS del ISP
      extraCommands = ''
        # Rechazar cualquier consulta DNS a servidores del ISP
        iptables -I OUTPUT -d 179.51.50.203 -p udp --dport 53 -j REJECT
        iptables -I OUTPUT -d 179.51.50.203 -p tcp --dport 53 -j REJECT
        iptables -I OUTPUT -d 179.51.50.202 -p udp --dport 53 -j REJECT
        iptables -I OUTPUT -d 179.51.50.202 -p tcp --dport 53 -j REJECT
        
        # También bloquear cualquier tráfico a esos IPs (por si acaso)
        iptables -I OUTPUT -d 179.51.50.203 -j REJECT
        iptables -I OUTPUT -d 179.51.50.202 -j REJECT
      '';
      
      extraStopCommands = ''
        # Limpiar reglas al detener firewall
        iptables -D OUTPUT -d 179.51.50.203 -p udp --dport 53 -j REJECT 2>/dev/null || true
        iptables -D OUTPUT -d 179.51.50.203 -p tcp --dport 53 -j REJECT 2>/dev/null || true
        iptables -D OUTPUT -d 179.51.50.202 -p udp --dport 53 -j REJECT 2>/dev/null || true
        iptables -D OUTPUT -d 179.51.50.202 -p tcp --dport 53 -j REJECT 2>/dev/null || true
        iptables -D OUTPUT -d 179.51.50.203 -j REJECT 2>/dev/null || true
        iptables -D OUTPUT -d 179.51.50.202 -j REJECT 2>/dev/null || true
      '';
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # 🔧 SYSTEMD-RESOLVED: MÁXIMA PRIORIDAD A CLOUDFLARE
  # ═══════════════════════════════════════════════════════════════
  
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ];
    fallbackDns = [ "8.8.8.8" "8.8.4.4" ];
    
    extraConfig = ''
      DNS=1.1.1.1 1.0.0.1 9.9.9.9
      FallbackDNS=8.8.8.8 8.8.4.4
      DNSOverTLS=yes
      LLMNR=no
      MulticastDNS=no
      Cache=yes
      CacheFromLocalhost=no
      DNSStubListener=yes
      ReadEtcHosts=yes
      Domains=~.
      # Preferir siempre nuestros DNS sobre los del DHCP
      DNSDefaultRoute=yes
    '';
  };

  # ═══════════════════════════════════════════════════════════════
  # 🔄 SERVICIO PARA FORZAR DNS AL INICIO
  # ═══════════════════════════════════════════════════════════════
  
  systemd.services.force-dns-override = {
    description = "Force Cloudflare DNS on network interface";
    after = [ "network-online.target" "systemd-resolved.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "force-dns" ''
        # Esperar a que la red esté lista
        sleep 3
        
        # Forzar DNS en la interface ethernet
        ${pkgs.systemd}/bin/resolvectl dns enp0s31f6 1.1.1.1 1.0.0.1 9.9.9.9
        ${pkgs.systemd}/bin/resolvectl domain enp0s31f6 '~.'
        ${pkgs.systemd}/bin/resolvectl dnsovertls enp0s31f6 yes
        
        # Verificar y loggear
        echo "=== DNS Override Applied ===" > /var/log/dns-override.log
        date >> /var/log/dns-override.log
        ${pkgs.systemd}/bin/resolvectl status enp0s31f6 >> /var/log/dns-override.log
        
        # Verificar que las reglas de firewall están activas
        echo "=== Firewall Rules ===" >> /var/log/dns-override.log
        ${pkgs.iptables}/bin/iptables -L OUTPUT -n | grep 179.51 >> /var/log/dns-override.log || echo "No firewall rules found" >> /var/log/dns-override.log
      '';
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # ⚡ OPTIMIZACIONES DEL KERNEL
  # ═══════════════════════════════════════════════════════════════
  
  boot.kernel.sysctl = {
    # TCP buffers
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    
    # BBR para conexiones con latencia variable
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    
    # Reduce latencia
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    
    # Optimizaciones para alta latencia
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_timestamps" = 1;
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_sack" = 1;
    
    # Reducir timeouts
    "net.ipv4.tcp_fin_timeout" = 15;
    "net.ipv4.tcp_keepalive_time" = 300;
    "net.ipv4.tcp_keepalive_probes" = 5;
    "net.ipv4.tcp_keepalive_intvl" = 15;
  };

  # ═══════════════════════════════════════════════════════════════
  # 📦 HERRAMIENTAS
  # ═══════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    nodejs_22
    corepack_22
    pnpm
    bun
    deno
    gcc
    git
    meld
    gh
    mtr
    iperf3
    tcpdump
    ethtool
    bandwhich
    nethogs
    speedtest-cli
    dnsutils
    traceroute
    iftop
    vnstat
    jq
    tldr
  ];

  environment.variables = {
    COREPACK_ENABLE_DOWNLOAD_PROMPT = "0";
  };

  # ═══════════════════════════════════════════════════════════════
  # 📊 MONITOR DE CALIDAD
  # ═══════════════════════════════════════════════════════════════
  
  systemd.services.network-quality-monitor = {
    description = "Monitor de calidad de red";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "check-network" ''
        echo "=== Network Quality Check ===" >> /var/log/network-quality.log
        date >> /var/log/network-quality.log
        ${pkgs.iputils}/bin/ping -c 5 1.1.1.1 2>&1 | tail -2 >> /var/log/network-quality.log
        ${pkgs.mtr}/bin/mtr -r -c 10 1.1.1.1 2>&1 >> /var/log/network-quality.log
        echo "" >> /var/log/network-quality.log
      '';
    };
  };
  
  systemd.timers.network-quality-monitor = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1h";
    };
  };

  system.stateVersion = "25.05";
}
