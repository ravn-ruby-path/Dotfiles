# ═══════════════════════════════════════════════════════════════
# 📊 DIAGNOSTICS AND LOGS - System health, disk and journal monitoring
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/07-logs.mdx
# 🎯 Purpose: Monitor system status, network, disk usage and journal logs
# ──── Overview: 8 targets for diagnostics, logs and network analysis ────

.PHONY: sys-status sys-disk log-net log-watch log-boot log-err log-svc log-net-enhanced

# === Health and Diagnostics ===

# ═══════════════════════════════════════════════════════════════
# 🏥 SYS-STATUS - Combined dashboard and detailed system status
# ═══════════════════════════════════════════════════════════════
# ──── Reports hostname, NixOS version, disk, generations and git state 
# Combined dashboard and detailed system status
sys-status: ## System health dashboard and report
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🏥 System Health Dashboard                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(BLUE)1. Core Components:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  $(BLUE)Hostname:$(NC)     $(GREEN)$(HOSTNAME)$(NC)\n"
	@printf "  $(BLUE)NixOS:$(NC)        $(GREEN)$(nixos-version 2>/dev/null | cut -d' ' -f1 || echo 'N/A')$(NC)\n"
	@printf "  $(BLUE)Flake Config:$(NC) "
	@if nix flake metadata --json . >/dev/null 2>&1; then \
		printf "$(GREEN)✓ Valid$(NC)\n"; \
	else \
		printf "$(RED)✗ Invalid$(NC)\n"; \
	fi
	
	@printf "\n$(BLUE)2. Storage & Generations:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@DISK=$(df -h /nix 2>/dev/null | tail -1 | awk '{print $5 " used (" $4 " free)"}' || echo 'N/A'); \
	printf "  $(BLUE)Disk (/nix):$(NC)  $(GREEN)%s$(NC)\n" "$DISK"; \
	GENS_OUT=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null); \
	if [ -z "$GENS_OUT" ]; then \
		printf "  $(BLUE)Generations:$(NC)  $(YELLOW)Access denied (needs sudo)$(NC)\n"; \
	else \
		TOTAL_GENS=$(echo "$GENS_OUT" | grep -c . || echo '0'); \
		CURRENT_GEN=$(echo "$GENS_OUT" | tail -1 | awk '{print $1 " (" $2 " " $3 ")"}' || echo 'N/A'); \
		printf "  $(BLUE)Total Gens:$(NC)   $(GREEN)%s$(NC)\n" "$TOTAL_GENS"; \
		printf "  $(BLUE)Current Gen:$(NC)  $(GREEN)%s$(NC)\n" "$CURRENT_GEN"; \
	fi
	
	@printf "\n$(BLUE)3. System Health:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  $(BLUE)Git Status:$(NC)   "
	@if git diff-index --quiet HEAD -- 2>/dev/null; then \
		printf "$(GREEN)✓ Clean$(NC)\n"; \
	else \
		printf "$(YELLOW)⚠ Uncommitted changes$(NC)\n"; \
	fi
	@printf "  $(BLUE)Services:$(NC)     "
	@FAILED=$(systemctl --failed --no-legend 2>/dev/null | wc -l); \
	if [ $FAILED -eq 0 ]; then \
		printf "$(GREEN)✓ All running$(NC)\n"; \
	else \
		printf "$(RED)✗ $FAILED failed$(NC) (run 'systemctl --failed')\n"; \
	fi
	
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Dashboard complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"

# ═══════════════════════════════════════════════════════════════
# 💾 SYS-DISK - Detailed disk usage report for key partitions
# ═══════════════════════════════════════════════════════════════
# ──── Uses duf if available, falls back to df ────────────────
# Detailed disk usage report for key partitions and directories
# Uses duf if available for pretty printing, otherwise falls back to df
sys-disk: ## Show disk usage info
 ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             💾 Disk Usage Report                       \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
 endif

	@printf "$(BLUE)1. Partition Usage:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if command -v duf >/dev/null 2>&1; then \
		duf -only local / /nix/store $(HOME); \
	else \
		printf "$(YELLOW)Root Partition (/):$(NC)\n"; \
		df -h / | tail -1 | awk '{print "  Size: " $$2 "  Used: " $$3 "  Avail: " $$4 "  Use%: " $$5}'; \
		printf "\n$(YELLOW)Nix Store (/nix/store):$(NC)\n"; \
		df -h /nix/store | tail -1 | awk '{print "  Size: " $$2 "  Used: " $$3 "  Avail: " $$4 "  Use%: " $$5}'; \
		printf "\n$(YELLOW)Home Partition ($(HOME)):$(NC)\n"; \
		df -h $(HOME) | tail -1 | awk '{print "  Size: " $$2 "  Used: " $$3 "  Avail: " $$4 "  Use%: " $$5}'; \
	fi

	@printf "\n$(BLUE)2. User Data Size:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(YELLOW)Calculating specific usage for $(HOME)...$(NC)\n"
	@HOME_SIZE=$$(du -sh $(HOME) 2>/dev/null | cut -f1); \
	printf "  $(BLUE)Home Content:$(NC) $(GREEN)$$HOME_SIZE$(NC)\n"

 ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Report complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
 endif

# ═══════════════════════════════════════════════════════════════
# 🌐 LOG-NET - Comprehensive network diagnostics
# ═══════════════════════════════════════════════════════════════
# ──── Tests DNS resolution, ping and network throughput ────────
# Comprehensive network diagnostics including DNS, connectivity, and performance tests
# Tests DNS resolution, ping connectivity, and network throughput
log-net: ## Run comprehensive network diagnostics
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🌐 Network Diagnostics                     \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(BLUE)1. DNS Status:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@resolvectl status 2>/dev/null | head -60 || printf "$(YELLOW)resolvectl not available$(NC)\n"
	
	@printf "\n$(BLUE)2. Latency Tests:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Pinging Cloudflare (1.1.1.1)...$(NC)\n"
	@ping -c 5 1.1.1.1
	@printf "\n$(BLUE)Pinging Google (google.com)...$(NC)\n"
	@ping -c 5 google.com
	
	@printf "\n$(BLUE)3. Throughput Test:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@curl -L -o /dev/null --max-time 20 -w "Downloaded: %{size_download} bytes, Speed: %{speed_download} B/s, Total: %{time_total}s\n" \
		"https://speed.cloudflare.com/__down?bytes=50000000"
		
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Diagnostics complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"

# ═══════════════════════════════════════════════════════════════
# 📈 LOG-WATCH - Monitor system logs in real-time
# ═══════════════════════════════════════════════════════════════
# ──── Runs journalctl -f (follow mode), Ctrl+C to exit ──────
# Monitor system logs in real-time using journalctl follow mode
# Continuously displays new log entries as they are written
log-watch: ## Watch system logs in real-time (follow mode)
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📊 Live System Logs                        \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	@printf "$(BLUE)Streaming new log entries...$(NC)\n"
	@printf "$(YELLOW)Press $(GREEN)Ctrl+C$(YELLOW) to exit$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@journalctl -f

# ═══════════════════════════════════════════════════════════════
# 📋 LOG-BOOT - Display error and alert logs from the current boot
# ═══════════════════════════════════════════════════════════════
# ──── journalctl -b -p err..alert, last 50 entries ──────────
# Display error and alert logs from the current boot session
# Shows systemd logs with priority err and alert from current boot
log-boot: ## Show boot logs
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📋 Current Boot Logs                       \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(BLUE)1. Critical Errors:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@journalctl -b -p err..alert --no-pager | tail -50 || true
	
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Log display complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"

# ═══════════════════════════════════════════════════════════════
# 📋 LOG-ERR - Display recent error-level logs
# ═══════════════════════════════════════════════════════════════
# ──── Shows last 50 error messages with timestamps ──────────
# Display recent error-level logs from systemd journal
# Shows the last 50 error messages with timestamps
log-err: ## Show recent error logs
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📋 Recent System Errors                    \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(BLUE)1. Error Analysis:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@ERROR_COUNT=$(journalctl -p err -n 50 --no-pager 2>/dev/null | wc -l || echo "0"); \
	if [ $$ERROR_COUNT -eq 0 ]; then \
		printf "$(GREEN)✓ No recent errors, system is clean.$(NC)\n"; \
	else \
		printf "$(YELLOW)⚠ Found $$ERROR_COUNT recent error(s):$(NC)\n\n"; \
		journalctl -p err -n 50 --no-pager || true; \
	fi
	
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Check complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"

# ═══════════════════════════════════════════════════════════════
# 📋 LOG-SVC - Display logs for a specific systemd service
# ═══════════════════════════════════════════════════════════════
# ──── Requires SVC=<name> e.g. make log-svc SVC=sshd ───────
# Display logs for a specific systemd service using journalctl
# Shows recent logs for the specified service (use SVC=name parameter)
log-svc: ## Show logs for specific service (use SVC=name)
	@if [ -z "$(SVC)" ]; then \
		printf "\n" ; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(CYAN)             📋 Service Log Viewer                      \n$(NC)"; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
		printf "$(RED)❌ Error: SVC variable required$(NC)\n\n"; \
		printf "$(BLUE)Usage:$(NC) make log-svc SVC=<service-name>\n\n"; \
		printf "$(BLUE)Examples:$(NC)\n"; \
		printf "  make log-svc SVC=sshd\n"; \
		printf "  make log-svc SVC=networkmanager\n\n"; \
		printf "$(BLUE)Running Services:$(NC)\n"; \
		if command -v systemctl >/dev/null 2>&1; then \
			systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | \
			awk '{print "  " $$1}' | head -10 || true; \
		fi; \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
		exit 1; \
	fi
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📋 Service Logs: $(SVC)                    \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(BLUE)1. Recent Entries:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if journalctl -u $(SVC) --since "1 hour ago" --no-pager 2>/dev/null | grep -q .; then \
		journalctl -u $(SVC) --since "1 hour ago" -n 100 --no-pager; \
	else \
		printf "$(YELLOW)No logs in the last hour. Showing older logs...$(NC)\n\n"; \
		journalctl -u $(SVC) -n 50 --no-pager; \
	fi
	
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Log display complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
# ═══════════════════════════════════════════════════════════════
# 🌐 LOG-NET-ENHANCED - Extended network diagnostics with auto-verification
# ═══════════════════════════════════════════════════════════════
# ──── Checks DNS, firewall, throughput, MTR and TCP optimizations ─
# NEW: Enhanced version with automatic DNS, firewall, and optimization verification
# You can test this without affecting the original 'make log-net' command
# Usage: make log-net-enhanced
log-net-enhanced: ## Run enhanced network diagnostics with automatic verification
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🌐 Network Diagnostics (Enhanced)                  \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
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
	
	# Final Summary
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Network diagnostics complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	@printf "$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "• Force Cloudflare DNS:  $(BLUE)sudo resolvectl dns enp0s31f6 1.1.1.1 1.0.0.1 9.9.9.9$(NC)\n"
	@printf "• Check DNS override:    $(BLUE)resolvectl status enp0s31f6$(NC)\n"
	@printf "• Verify firewall:       $(BLUE)sudo iptables -L OUTPUT -n | grep 179.51$(NC)\n"
	@printf "• Gateway verification:  $(BLUE)./verify-gateway.sh$(NC)\n"
	@printf "• View quality logs:     $(BLUE)tail -f /var/log/network-quality.log$(NC)\n"
	@printf "• Check DNS override log:$(BLUE)cat /var/log/dns-override.log$(NC)\n"
	@printf "\n"
