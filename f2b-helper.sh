#!/bin/sh
# /opt/upcp/misc/fail2ban/f2b-helper.sh
# Usage: fail2ban-helper.sh <ip> <ports> <comment> <action>
# <action> = ban | unban

IP="$1"
PORTS="$2"
COMMENT="$3"
ACTION="$4"

reload_needed=0

# Split ports by comma
for p in $(echo "$PORTS" | tr ',' ' '); do
    if [ "$ACTION" = "ban" ]; then
        if [ "$p" = "any" ] || [ -z "$p" ]; then
            ufw insert 1 deny from "$IP" to any comment "$COMMENT" &
        else
            ufw insert 1 deny proto tcp from "$IP" to any port "$p" comment "$COMMENT" &
        fi
        # special proxy handling for 80/443
        if [ "$p" = "80" ] || [ "$p" = "443" ]; then
            grep -qxF "$IP 1;" /opt/upcp/services/upcp-proxy/banned-ips.conf || echo "$IP 1;" >> /opt/upcp/services/upcp-proxy/banned-ips.conf
            reload_needed=1
        fi
    elif [ "$ACTION" = "unban" ]; then
        if [ "$p" = "any" ] || [ -z "$p" ]; then
            ufw delete deny from "$IP" to any &
        else
            ufw delete deny proto tcp from "$IP" to any port "$p" &
        fi
        if [ "$p" = "80" ] || [ "$p" = "443" ]; then
            sed -i "\|^$IP 1;|d" /opt/upcp/services/upcp-proxy/banned-ips.conf
            reload_needed=1
        fi
    fi
done

wait

# Reload proxy if needed
[ "$reload_needed" -eq 1 ] && rc-service upcp-proxy reload &
