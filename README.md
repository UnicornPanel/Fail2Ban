
# Fail2Ban for Unicorn Panel

Fail2Ban configuration and integration utilities used within the **Unicorn Control Panel** ecosystem. This repository provides opinionated Fail2Ban jails, filters, and helper scripts designed to protect servers from brute‑force attacks and malicious traffic with minimal configuration.

## 🎯 Purpose of This Repository

This repo provides:

✔ Pre‑configured **Fail2Ban jails** optimized for common services  
✔ Custom **filters** intended for NGINX, SSH, and WordPress‑based environments  
✔ A curated **ignore list** of trusted CDN IPs 
✔ Scripts to simplify deployment within **Unicorn Panel** hosting containers  

## 🚀 Recommended Settings

These defaults provide strong baseline security:

| Setting        | Value      | Description                            |
|---------------|-----------|----------------------------------------|
| bantime        | 1h        | IP ban duration                         |
| findtime       | 10m       | Log window to detect repeated failures  |
| maxretry       | 3         | Attempts allowed before ban             |

Adjust these values depending on the sensitivity of your services.

## 🌐 CDN & Proxy Awareness

Because many Unicorn Panel deployments use services such as Cloudflare or BunnyCDN, included scripts can:

- Download the latest IPv4/IPv6 ranges
- Add them to Fail2Ban ignore lists
- Prevent accidental bans of legitimate remote proxies

## Trusted IPs

Unicorn Panel explicitly trusts the following:

- Cloudflare
- Bunny CDN
- WP Rocket
- Ahrefs

## 🦄 Unicorn Panel Integration

This repository is part of the **Unicorn Control Panel** ecosystem.

Learn more at: 🔗 https://unicornpanel.net/