# Deploy chemie-lernen.org to existing Traefik at /opt/git/docker-traefik

## Prerequisites
- SSH access to v22290
- Existing Traefik setup at `/opt/git/docker-traefik`
- Hugo site built locally

## Step 1: Build the site locally
```bash
cd ~/git/hugo-sites/hugo-chemie-lernen-org/myhugoapp
hugo --minify
```

## Step 2: Create nginx.conf
Create `/opt/git/docker-traefik/chemie-lernen/nginx.conf`:

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Main location
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Favicon
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
}
```

## Step 3: Add service to existing docker-compose.yml
Edit `/opt/git/docker-traefik/docker-compose.yml` and add:

```yaml
services:
  # ... existing services ...

  chemie-lernen:
    image: nginx:alpine
    container_name: chemie-lernen
    restart: unless-stopped
    volumes:
      - ./chemie-lernen/public:/usr/share/nginx/html:ro
      - ./chemie-lernen/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.chemie-lernen.rule=Host(`chemie-lernen.org`) || Host(`www.chemie-lernen.org`)"
      - "traefik.http.routers.chemie-lernen.entrypoints=websecure"
      - "traefik.http.routers.chemie-lernen.tls.certresolver=letsencrypt"
      - "traefik.http.services.chemie-lernen.loadbalancer.server.port=80"

networks:
  proxy:
    external: true
```

## Step 4: Deploy site files
```bash
# Create directory
ssh root@v22290 "mkdir -p /opt/git/docker-traefik/chemie-lernen/public"

# Copy site files
scp -r ~/git/hugo-sites/hugo-chemie-lernen-org/myhugoapp/public/* root@v22290:/opt/git/docker-traefik/chemie-lernen/public/

# Copy nginx config
scp ~/git/hugo-sites/hugo-chemie-lernen-org/nginx.conf root@v22290:/opt/git/docker-traefik/chemie-lernen/nginx.conf
```

## Step 5: Update DNS
Add A records pointing to your server:
- `chemie-lernen.org` → server IP
- `www.chemie-lernen.org` → server IP

## Step 6: Start service
```bash
ssh root@v22290
cd /opt/git/docker-traefik
docker compose up -d
```

## Step 7: Verify
```bash
# Check service is running
docker ps | grep chemie-lernen

# Test site
curl -I https://chemie-lernen.org
curl -I https://www.chemie-lernen.org
```

## Test URLs after deployment:
- https://chemie-lernen.org/
- https://chemie-lernen.org/molekuel-studio/
- https://chemie-lernen.org/perioden-system-der-elemente/
- https://chemie-lernen.org/test-perioden-system.html
