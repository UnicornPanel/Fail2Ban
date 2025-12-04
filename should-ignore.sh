#!/bin/sh

IP="$1"
CACHE_DIR="/var/cache/fail2ban"
CACHE_FILE="$CACHE_DIR/ips-to-ignore.txt"
TTL=86400  # Cache TTL in seconds

mkdir -p "$CACHE_DIR"

# Check if cache is fresh
if [ ! -f "$CACHE_FILE" ] || [ "$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))" -ge "$TTL" ]; then
    TMP_FILE=$(mktemp)

    ###############################################
    # ADD SERVER'S OWN PUBLIC IP ADDRESSES (IPv4)
    ###############################################
    ip -o -4 addr show \
      | awk '{print $4}' \
      | cut -d/ -f1 \
      | grep -vE '^(127\.|10\.|192\.168\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.)' \
      >> "$TMP_FILE"

    ###############################################
    # Cloudflare IPv4 & IPv6
    ###############################################
    curl -s https://www.cloudflare.com/ips-v4/ >> "$TMP_FILE"
    curl -s https://www.cloudflare.com/ips-v6/ >> "$TMP_FILE"

    ###############################################
    # WP Rocket IPv4 & IPv6
    ###############################################
    curl -s https://mega.wp-rocket.me/rocket-ips/rocket-ips-plain-ipv4.txt >> "$TMP_FILE"
    curl -s https://mega.wp-rocket.me/rocket-ips/rocket-ips-plain-ipv6.txt >> "$TMP_FILE"

    ###############################################
    # BunnyCDN IPv4 & IPv6
    ###############################################
    curl -s https://bunnycdn.com/api/system/edgeserverlist \
        | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$TMP_FILE"

    curl -s https://bunnycdn.com/api/system/edgeserverlist/IPv6 \
        | grep -oE '([a-fA-F0-9:]+:+)+[a-fA-F0-9]+' >> "$TMP_FILE"

    ###############################################
    # Ahrefs Crawler IPs (JSON)
    ###############################################
    curl -s https://api.ahrefs.com/v3/public/crawler-ip-ranges \
        | jq -r '.prefixes[].ipv4Prefix' >> "$TMP_FILE"

    ###############################################
    # Clean & dedupe
    ###############################################
    sort -u "$TMP_FILE" > "$CACHE_FILE"
    rm "$TMP_FILE"
fi

# Check if IP is in the ignore list
if grepcidr "$IP" "$CACHE_FILE" | grep -q .; then
    exit 0  # Ignore this IP
else
    exit 1  # Continue with ban
fi
