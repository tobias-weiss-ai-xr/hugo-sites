# Hugo Multi-Site Architecture

This repository hosts multiple Hugo-based websites through a single Traefik reverse proxy with automatic SSL termination via Let's Encrypt.

## Architecture

```
Internet (HTTP/HTTPS)
    ↓
Traefik (Entry Point, SSL Termination, Redirection)
    ↓
Multiple Hugo Containers (Serving internally on port 1313)
```

## Hosted Sites

### 1. **Chemie Lernen** - https://chemie-lernen.org
- **Directory**: `hugo-chemie-lernen-org/`
- **Internal Port**: 1313
- **Primary Domain**: `chemie-lernen.org`
- **Aliases**: `www.chemie-lernen.org`

### 2. **GraphWiz AI** - https://graphwiz.ai
- **Directory**: `hugo-graphwiz-ai/`
- **Internal Port**: 1313
- **Primary Domain**: `graphwiz.ai`
- **Aliases**: `www.graphwiz.ai`, `graphwiz.de`, `www.graphwiz.de`

### 3. **Tobias Weiss** - https://tobias-weiss.org
- **Directory**: `hugo-tobias-weiss-org/`
- **Internal Port**: 1313
- **Primary Domain**: `tobias-weiss.org`
- **Aliases**: `www.tobias-weiss.org`, `next.tobias-weiss.org`

## Configuration

### Docker Compose
**File**: `docker-compose.yml`

Traefik is configured to use Docker labels for routing. Each Hugo service has labels defining its host rules and port.

### Traefik Configuration
- **Entry Points**: 80 (HTTP), 443 (HTTPS)
- **Automatic Redirect**: HTTP to HTTPS
- **SSL Resolver**: `mytlschallenge` (using Let's Encrypt TLS-ALPN-01)
- **Certificates**: Managed automatically and stored in `./letsencrypt/acme.json`

## Directory Structure

```
/opt/git/hugo-sites/
├── hugo-chemie-lernen-org/
│   └── myhugoapp/
├── hugo-graphwiz-ai/
│   └── myhugoapp/
├── hugo-tobias-weiss-org/
│   └── myhugoapp/
├── docker-compose.yml
├── .env
├── ARCHITECTURE.md (this file)
└── TESTING.md
```

## Management Commands

### Start All Services
```bash
docker compose up -d
```

### Stop All Services
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f traefik
docker compose logs -f hugo-chemie-lernen-org
```

### Check Container Status
```bash
docker compose ps
```

## Adding a New Hugo Site

1. **Create new directory** with the Hugo source.
2. **Add service** to `docker-compose.yml` following the existing pattern.
3. **Add domain** to the `.env` file if using variables.
4. **Update Traefik labels** for the new service.
5. **Restart**: `docker compose up -d`.

## Troubleshooting

### SSL Certificate Issues
1. Check Traefik logs: `docker compose logs traefik`
2. Ensure ports 80 and 443 are open and not blocked by another process (like HAProxy).
3. Verify `acme.json` permissions (should be 600).

### Routing Issues
1. Verify Traefik Dashboard at `http://localhost:8080` (if port exposed).
2. Check Docker labels in `docker-compose.yml`.

---

**Last Updated**: 2025-12-20
**Maintained By**: Tobias Weiss