# ═══════════════════════════════════════════════════════════════
# 📊 DIAGNOSTICS AND LOGS - System health, disk and journal monitoring
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/07-logs.mdx
# 🎯 Purpose: Monitor system status, network, disk usage and journal logs
# ──── Overview: 8 targets for diagnostics, logs and network analysis ────
#
# 🧪 Dry Run (preview without executing):
#    (all targets are read-only / diagnostic — no DRY_RUN needed)

.PHONY: sys-status sys-disk log-net log-watch log-boot log-err log-svc log-net-enhanced

# === Health and Diagnostics ===

# ═══════════════════════════════════════════════════════════════
# 🏥 SYS-STATUS - Combined dashboard and detailed system status
# ═══════════════════════════════════════════════════════════════
# ──── Reports hostname, NixOS version, disk, generations and git state ─
sys-status: ## System health dashboard and report
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🏥 sys-status · system health dashboard$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(BLUE)  Core:$(NC)\n"
	@NIXOS_VER=$$(nixos-version 2>/dev/null | cut -d' ' -f1 || echo 'N/A'); \
	printf "    $(BLUE)hostname:$(NC)  $(GREEN)$$(hostname)$(NC)\n"; \
	printf "    $(BLUE)NixOS:$(NC)     $(GREEN)$$NIXOS_VER$(NC)\n"
	@printf "    $(BLUE)flake:$(NC)     "
	@if nix flake metadata --json . >/dev/null 2>&1; then \
		printf "$(GREEN)✓ valid$(NC)\n"; \
	else \
		printf "$(RED)✗ invalid$(NC)\n"; \
	fi
	@printf "\n$(BLUE)  Storage:$(NC)\n"
	@DISK=$$(df -h /nix 2>/dev/null | tail -1 | awk '{print $$5" used ("$$4" free)"}' || echo 'N/A'); \
	printf "    $(BLUE)disk /nix:$(NC) $(GREEN)$$DISK$(NC)\n"
	@GENS_OUT=$$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null); \
	if [ -z "$$GENS_OUT" ]; then \
		printf "    $(BLUE)gens:$(NC)      $(YELLOW)needs sudo$(NC)\n"; \
	else \
		TOTAL=$$(echo "$$GENS_OUT" | grep -c .); \
		CURRENT=$$(echo "$$GENS_OUT" | grep current | awk '{print $$1" ("$$2" "$$3")"}'); \
		printf "    $(BLUE)gens total:$(NC) $(GREEN)$$TOTAL$(NC)\n"; \
		printf "    $(BLUE)current:$(NC)    $(GREEN)$$CURRENT$(NC)\n"; \
	fi
	@printf "\n$(BLUE)  Health:$(NC)\n"
	@if git diff-index --quiet HEAD -- 2>/dev/null; then \
		printf "    $(BLUE)git:$(NC)       $(GREEN)✓ clean$(NC)\n"; \
	else \
		printf "    $(BLUE)git:$(NC)       $(YELLOW)⚠ uncommitted changes$(NC)\n"; \
	fi
	@FAILED=$$(systemctl --failed --no-legend 2>/dev/null | wc -l); \
	if [ "$$FAILED" -eq 0 ]; then \
		printf "    $(BLUE)services:$(NC)  $(GREEN)✓ all running$(NC)\n"; \
	else \
		printf "    $(BLUE)services:$(NC)  $(RED)✗ $$FAILED failed$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • disk details:   $(BLUE)make sys-disk$(NC)\n"
	@printf "  • error logs:     $(BLUE)make log-err$(NC)\n"
	@printf "  • live logs:      $(BLUE)make log-watch$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 💾 SYS-DISK - Detailed disk usage report for key partitions
# ═══════════════════════════════════════════════════════════════
# ──── Uses duf if available, falls back to df ────────────────
sys-disk: ## Show disk usage info
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)💾 sys-disk · partition and home usage$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if command -v duf >/dev/null 2>&1; then \
		duf -only local / /nix/store $(HOME); \
	else \
		printf "$(DIM)  /$(NC)\n"; \
		df -h / | tail -1 | awk '{printf "    size: %s  used: %s  avail: %s  use%%: %s\n",$$2,$$3,$$4,$$5}'; \
		printf "$(DIM)  /nix/store$(NC)\n"; \
		df -h /nix/store | tail -1 | awk '{printf "    size: %s  used: %s  avail: %s  use%%: %s\n",$$2,$$3,$$4,$$5}'; \
		printf "$(DIM)  $(HOME)$(NC)\n"; \
		df -h $(HOME) | tail -1 | awk '{printf "    size: %s  used: %s  avail: %s  use%%: %s\n",$$2,$$3,$$4,$$5}'; \
	fi
	@printf "\n$(DIM)  home content:$(NC)\n"
	@HOME_SIZE=$$(du -sh $(HOME) 2>/dev/null | cut -f1); \
	printf "    $(GREEN)$$HOME_SIZE$(NC)\n"
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • system status:  $(BLUE)make sys-status$(NC)\n"
	@printf "  • gc old gens:    $(BLUE)make sys-gc$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🌐 LOG-NET - Comprehensive network diagnostics
# ═══════════════════════════════════════════════════════════════
# ──── Tests DNS resolution, ping and network throughput ────────
log-net: ## Run comprehensive network diagnostics
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🌐 log-net · network diagnostics$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(DIM)  DNS status:$(NC)\n"
	@resolvectl status 2>/dev/null | head -60 || printf "$(YELLOW)  resolvectl not available$(NC)\n"
	@printf "\n$(DIM)  latency — cloudflare (1.1.1.1):$(NC)\n"
	@ping -c 5 1.1.1.1
	@printf "\n$(DIM)  latency — google.com:$(NC)\n"
	@ping -c 5 google.com
	@printf "\n$(DIM)  throughput (cloudflare 50MB):$(NC)\n"
	@curl -L -o /dev/null --max-time 20 -w "  downloaded: %{size_download} bytes  speed: %{speed_download} B/s  time: %{time_total}s\n" \
		"https://speed.cloudflare.com/__down?bytes=50000000"
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • enhanced diagnostics: $(BLUE)make log-net-enhanced$(NC)\n"
	@printf "  • live logs:            $(BLUE)make log-watch$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📈 LOG-WATCH - Monitor system logs in real-time
# ═══════════════════════════════════════════════════════════════
# ──── Runs journalctl -f (follow mode), Ctrl+C to exit ──────
log-watch: ## Watch system logs in real-time (follow mode)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📈 log-watch · live journal stream$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(DIM)  streaming — press $(NC)$(YELLOW)Ctrl+C$(NC)$(DIM) to exit$(NC)\n\n"
	@journalctl -f

# ═══════════════════════════════════════════════════════════════
# 📋 LOG-BOOT - Display error and alert logs from the current boot
# ═══════════════════════════════════════════════════════════════
# ──── journalctl -b -p err..alert, last 50 entries ──────────
log-boot: ## Show boot logs
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📋 log-boot · errors from current boot$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@journalctl -b -p err..alert --no-pager | tail -50 || true
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • recent errors:  $(BLUE)make log-err$(NC)\n"
	@printf "  • live stream:    $(BLUE)make log-watch$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📋 LOG-ERR - Display recent error-level logs
# ═══════════════════════════════════════════════════════════════
# ──── Shows last 50 error messages with timestamps ──────────
log-err: ## Show recent error logs
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔴 log-err · recent error-level journal entries$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@ERROR_COUNT=$$(journalctl -p err -n 50 --no-pager 2>/dev/null | wc -l || echo "0"); \
	if [ "$$ERROR_COUNT" -eq 0 ]; then \
		printf "$(GREEN)  ✓ no recent errors — system is clean$(NC)\n"; \
	else \
		printf "$(YELLOW)  ⚠ found $$ERROR_COUNT recent error(s):$(NC)\n\n"; \
		journalctl -p err -n 50 --no-pager || true; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • boot errors:    $(BLUE)make log-boot$(NC)\n"
	@printf "  • service logs:   $(BLUE)make log-svc SVC=<name>$(NC)\n"
	@printf "  • live stream:    $(BLUE)make log-watch$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📋 LOG-SVC - Display logs for a specific systemd service
# ═══════════════════════════════════════════════════════════════
# ──── Requires SVC=<name> e.g. make log-svc SVC=sshd ───────
log-svc: ## Show logs for specific service (use SVC=name)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📋 log-svc · service journal logs$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if [ -z "$(SVC)" ]; then \
		printf "$(YELLOW)  usage: make log-svc SVC=<service-name>$(NC)\n\n"; \
		printf "$(DIM)  examples:$(NC)\n"; \
		printf "    make log-svc SVC=sshd\n"; \
		printf "    make log-svc SVC=networkmanager\n\n"; \
		printf "$(DIM)  running services:$(NC)\n"; \
		systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | \
			awk '{print "    " $$1}' | head -10 || true; \
		printf "\n"; \
	else \
		if journalctl -u $(SVC) --since "1 hour ago" --no-pager 2>/dev/null | grep -q .; then \
			journalctl -u $(SVC) --since "1 hour ago" -n 100 --no-pager; \
		else \
			printf "$(DIM)  no logs in the last hour — showing older entries:$(NC)\n\n"; \
			journalctl -u $(SVC) -n 50 --no-pager; \
		fi; \
	fi
ifndef EMBEDDED
	@if [ -n "$(SVC)" ]; then printf "\n$(GREEN)  ✓ done$(NC)\n"; fi
endif
	@if [ -n "$(SVC)" ]; then \
		printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"; \
		printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		printf "  • live stream:  $(BLUE)make log-watch$(NC)\n"; \
		printf "  • recent errors: $(BLUE)make log-err$(NC)\n\n"; \
	fi
# ═══════════════════════════════════════════════════════════════
# 🌐 LOG-NET-ENHANCED - Extended network diagnostics with auto-verification
# ═══════════════════════════════════════════════════════════════
# ──── Checks DNS, firewall, throughput, MTR and TCP optimizations ─
log-net-enhanced: ## Run enhanced network diagnostics with automatic verification
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🌐 log-net-enhanced · full network diagnostics$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	
	# 1. DNS Configuration Verification
	@printf "$(BLUE)1. DNS Configuration & Override Status:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(YELLOW)Global DNS (systemd-resolved):$(NC)\n"
	@resolvectl status 2>/dev/null | grep -A 3 "Global" || printf "$(YELLOW)resolvectl not available$(NC)\n"
	@printf "\n$(YELLOW)Interface DNS (enp0s31f6):$(NC)\n"
	@resolvectl status enp0s31f6 2>/dev/null | grep -E "Current DNS Server|DNS Servers|DNS Domain" || true
	@printf "\n"
	@if resolvectl status enp0s31f6 2>/dev/null | grep -q "1.1.1.1\|1.0.0.1"; then \
		printf "$(GREEN)✅ DNS configured correctly (using Cloudflare)$(NC)\n"; \
	elif resolvectl status enp0s31f6 2>/dev/null | grep -q "179.51.50"; then \
		printf "$(RED)⚠️  WARNING: Using ISP DNS (179.51.50.x)$(NC)\n"; \
		printf "$(YELLOW)   Run: sudo resolvectl dns enp0s31f6 1.1.1.1 1.0.0.1 9.9.9.9$(NC)\n"; \
	else \
		printf "$(YELLOW)⚠️  DNS status unknown$(NC)\n"; \
	fi
	
	# 2. NetworkManager DNS (from DHCP)
	@printf "\n$(BLUE)2. DNS from NetworkManager (DHCP):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@nmcli device show enp0s31f6 2>/dev/null | grep -E "IP4.DNS" || printf "$(YELLOW)NetworkManager info not available$(NC)\n"
	@if nmcli device show enp0s31f6 2>/dev/null | grep -q "179.51.50"; then \
		printf "$(YELLOW)ℹ️  ISP DNS detected in DHCP (ignored by systemd-resolved)$(NC)\n"; \
	fi
	
	# 3. DNS Query Speed Test
	@printf "\n$(BLUE)3. DNS Query Performance:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(YELLOW)Testing DNS query speeds...$(NC)\n"
	@for dns in "1.1.1.1:Cloudflare" "9.9.9.9:Quad9" "8.8.8.8:Google"; do \
		server=$$(echo $$dns | cut -d: -f1); \
		name=$$(echo $$dns | cut -d: -f2); \
		time=$$(dig @$$server google.com +noall +stats 2>/dev/null | grep "Query time:" | awk '{print $$4}' || echo "N/A"); \
		if [ "$$time" != "N/A" ]; then \
			printf "%-20s %4s ms\n" "$$name:" "$$time"; \
		fi; \
	done
	@if ! sudo iptables -L OUTPUT -n 2>/dev/null | grep -q "179.51.50.203"; then \
		time=$$(dig @179.51.50.203 google.com +noall +stats 2>/dev/null | grep "Query time:" | awk '{print $$4}' || echo "N/A"); \
		if [ "$$time" != "N/A" ]; then \
			printf "%-20s %4s ms\n" "ISP (Tigo/Claro):" "$$time"; \
		fi; \
	else \
		printf "%-20s $(RED)BLOCKED$(NC)\n" "ISP DNS:"; \
	fi
	
	# 4. Firewall Rules Verification
	@printf "\n$(BLUE)4. Firewall DNS Block Status:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if sudo iptables -L OUTPUT -n 2>/dev/null | grep -q "179.51.50"; then \
		printf "$(GREEN)✅ ISP DNS blocked by firewall$(NC)\n"; \
		sudo iptables -L OUTPUT -n 2>/dev/null | grep "179.51.50" | head -4 | sed 's/^/   /'; \
	else \
		printf "$(YELLOW)⚠️  No firewall rules blocking ISP DNS$(NC)\n"; \
		printf "$(YELLOW)   Run: sudo systemctl restart firewall$(NC)\n"; \
	fi
	
	# 5. Basic Connectivity Tests
	@printf "\n$(BLUE)5. Ping Test (Cloudflare 1.1.1.1):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@ping -c 5 1.1.1.1
	
	@printf "\n$(BLUE)6. Ping Test (Google):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@ping -c 5 google.com
	
	# 6. Throughput Test
	@printf "\n$(BLUE)7. Throughput Test (Cloudflare 50MB):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@curl -L -o /dev/null --max-time 20 -w "Downloaded: %{size_download} bytes, Speed: %{speed_download} B/s, Total: %{time_total}s\n" \
		"https://speed.cloudflare.com/__down?bytes=50000000"
	
	# 7. Speedtest
	@printf "\n$(BLUE)8. Speedtest (Nearest Server):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@nix run 'nixpkgs#speedtest-cli' -- --simple 2>/dev/null || printf "$(YELLOW)speedtest-cli failed or not available$(NC)\n"
	
	# 8. Route Quality (MTR)
	@printf "\n$(BLUE)9. Route Quality Analysis (MTR to 1.1.1.1):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if command -v mtr >/dev/null 2>&1; then \
		mtr -rw 1.1.1.1 -c 50; \
		printf "\n$(YELLOW)ℹ️  Note: High loss on hop #1 (gateway) is normal - it's an MTR artifact$(NC)\n"; \
		printf "$(YELLOW)   The gateway prioritizes routing over ICMP replies. See verify-gateway.sh$(NC)\n"; \
	else \
		printf "$(YELLOW)mtr not available$(NC)\n"; \
	fi
	
	# 9. Network Interface Statistics
	@printf "\n$(BLUE)10. Network Interface Statistics:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if ip -s link show enp0s31f6 >/dev/null 2>&1; then \
		printf "$(YELLOW)RX (Received):$(NC)\n"; \
		ip -s link show enp0s31f6 | grep -A 1 "RX:" | tail -1 | sed 's/^/   /'; \
		printf "$(YELLOW)TX (Transmitted):$(NC)\n"; \
		ip -s link show enp0s31f6 | grep -A 1 "TX:" | tail -1 | sed 's/^/   /'; \
		errors=$$(ip -s link show enp0s31f6 | grep -A 1 "RX:" | tail -1 | awk '{print $$3}'); \
		if [ "$$errors" = "0" ]; then \
			printf "$(GREEN)✅ No reception errors$(NC)\n"; \
		else \
			printf "$(YELLOW)⚠️  $$errors reception errors detected$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)Interface statistics not available$(NC)\n"; \
	fi
	
	# 10. TCP Congestion Control Verification
	@printf "\n$(BLUE)11. TCP Optimizations:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@cc=$$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $$3}'); \
	if [ "$$cc" = "bbr" ]; then \
		printf "$(GREEN)✅ TCP BBR enabled$(NC)\n"; \
	else \
		printf "$(YELLOW)⚠️  TCP congestion control: $$cc (recommended: bbr)$(NC)\n"; \
	fi
	@qdisc=$$(sysctl net.core.default_qdisc 2>/dev/null | awk '{print $$3}'); \
	if [ "$$qdisc" = "fq" ]; then \
		printf "$(GREEN)✅ Queue discipline: fq (optimal for BBR)$(NC)\n"; \
	else \
		printf "$(YELLOW)⚠️  Queue discipline: $$qdisc$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • force cloudflare DNS: $(BLUE)sudo resolvectl dns enp0s31f6 1.1.1.1 1.0.0.1 9.9.9.9$(NC)\n"
	@printf "  • check DNS override:   $(BLUE)resolvectl status enp0s31f6$(NC)\n"
	@printf "  • verify firewall:      $(BLUE)sudo iptables -L OUTPUT -n | grep 179.51$(NC)\n"
	@printf "  • gateway check:        $(BLUE)./verify-gateway.sh$(NC)\n"
	@printf "  • basic diagnostics:    $(BLUE)make log-net$(NC)\n\n"
