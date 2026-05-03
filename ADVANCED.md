# Advanced Guide

This document covers deployment, networking, and configuration topics that go beyond the basic setup in the README.

---

## Table of Contents

- [Host Authorisation](#host-authorisation)
- [Deployment Overview](#deployment-overview)
- [Setting Up a Subdomain](#setting-up-a-subdomain)
- [Reverse Proxy](#reverse-proxy)
- [Keeping the Server Running](#keeping-the-server-running)
- [Testing with ngrok](#testing-with-ngrok)

---

## Host Authorisation

Crystal Chalk uses Sinatra's built-in host authorisation to protect against DNS rebinding attacks. When a request comes in, the `Host` header is checked against a whitelist. Requests from unlisted hosts are rejected with a `403 Host not permitted` error.

In development mode (`rake dev`), host authorisation is disabled entirely. Localhost and any tunnel tools work without configuration

In production mode (`rake prod`), only the hosts you specify are allowed.

**Configuration in `settings.yml`:**

```yaml
site_url: "https://yourdomain.com"
extra_hosts:
  - "www.yourdomain.com"
```

Crystal Chalk derives the allowed host automatically from `site_url`. Add any additional hostnames to `extra_hosts`, like www variants, alternative domains, and so on.

> [!WARNING]
> If you see `Host not permitted` in production, check that `site_url` is set correctly and matches the domain your server is being accessed from exactly, including or excluding `www` as appropriate.

> [!NOTE]
> `site_url` should be the full URL including the protocol, e.g. `https://blog.yourdomain.com`, not just `blog.yourdomain.com`.

---

## Deployment Overview

Crystal Chalk is a persistent Ruby process, not a static site generator. Deploying it involves three things:

1. A **reverse proxy** (Caddy or Nginx) that receives public traffic on port 80/443 and forwards it to your Ruby process
2. A **process manager** (systemd) that keeps the Ruby process running and restarts it if it crashes
3. **DNS** pointing your domain or subdomain at your server

The sections below cover each of these on Ubuntu/Debian. The concepts are the same on other Linux distributions, just with different package managers.

---

## Setting Up a Subdomain

Go to your domain registrar or DNS provider and add an A record:

| Type | Name | Value |
|------|------|-------|
| A | `blog` | your server's public IP address |

This makes `blog.yourdomain.com` point to your server. If you want the blog at the root domain instead, use `@` as the name.

> [!NOTE]
> DNS changes can take anywhere from a few minutes to 48 hours to propagate, depending on your provider. Most modern registrars update within minutes.

---

## Reverse Proxy

Your Ruby server listens on a port (default `4567`). The reverse proxy sits in front of it, handling SSL and forwarding public requests.

<details>
<summary><strong>Caddy (recommended)</strong></summary>

Caddy is the simpler option. It handles SSL certificates automatically via Let's Encrypt with no extra steps. Assuming you have Caddy installed:

1. **Edit `/etc/caddy/Caddyfile`:**
    ```
    blog.yourdomain.com {
        reverse_proxy localhost:4567
    }
    ```

2. **Reload Caddy:**
    ```bash
    sudo systemctl reload caddy
    ```

That is it. Caddy provisions and renews the SSL certificate automatically.

</details>

<details>
<summary><strong>Nginx</strong></summary>

Nginx requires a separate SSL setup via Certbot. Assuming you have Nginx installed:

1. **Create `/etc/nginx/sites-available/crystal-chalk`:**
    ```nginx
    server {
        listen 80;
        server_name blog.yourdomain.com;
    
        location / {
            proxy_pass http://localhost:4567;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```

2. **Enable the site:**
    ```bash
    sudo ln -s /etc/nginx/sites-available/crystal-chalk /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl reload nginx
    ```

3. **Add SSL via Certbot:**
    ```bash
    sudo certbot --nginx -d blog.yourdomain.com
    ```

Certbot modifies the Nginx config to add SSL and sets up automatic renewal.

</details>

---

## Keeping the Server Running
 
Without a process manager, the server stops when your SSH session ends. Systemd keeps it running in the background and restarts it automatically if it crashes.
 
1. **Create `/etc/systemd/system/crystal-chalk.service`:**
    ```ini
    [Unit]
    Description=Crystal Chalk Blog Server
    After=network.target
    
    [Service]
    Type=simple
    User=youruser
    WorkingDirectory=/path/to/crystal-chalk
    Environment=APP_ENV=production
    ExecStart=/usr/bin/ruby bin/server
    Restart=on-failure
    RestartSec=5
    
    [Install]
    WantedBy=multi-user.target
    ```
 
Replace `youruser` with your Linux username and `/path/to/crystal-chalk` with the actual path to the repo.
 
2. **Enable and start the service:**
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable crystal-chalk   # start on boot
    sudo systemctl start crystal-chalk    # start now
    sudo systemctl status crystal-chalk   # check it's running
    ```

---

## Testing with ngrok

ngrok creates a temporary public tunnel to your local server. Useful for sharing a preview with someone or testing from a mobile device without deploying.

**Install ngrok on Windows:**

1. Download the installer from [ngrok.com/download](https://ngrok.com/download)

2. Extract `ngrok.exe` and add it to your PATH

3. Sign up at [ngrok.com](https://ngrok.com) and grab your authtoken

4. Run `ngrok config add-authtoken <your-token>`

5. Start a tunnel:
    ```bash
    # start Crystal Chalk first
    rake dev
    
    # in a separate terminal
    ngrok http 4567
    ```

6. ngrok will give you a URL like `https://abc123.ngrok-free.app`. You can open this directly in your browser! No need to add it to `settings.yml` since host authorisation is disabled in development mode.