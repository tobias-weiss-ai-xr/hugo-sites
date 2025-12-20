# Self-Hosted Cloud Infrastructure

This repository contains the configuration and orchestration for a comprehensive self-hosted cloud environment. It aggregates several major open-source projects into a unified deployment using Docker Compose.

## Project Structure

The infrastructure is organized into the following main components:

### 1. Mozilla Hubs (`hubs-compose/`)
A complete instance of Mozilla Hubs, an immersive social VR platform. This directory includes services for:
- **Hubs & Spoke:** The main web client and scene editor.
- **Reticulum:** The Phoenix-based networking and backend server.
- **Dialog:** The WebRTC media server.
- **PostgREST:** RESTful API for the database.
- **Support Services:** Postgres, custom middleware, and configuration management.

### 2. Mailcow (`mailcow-dockerized/`)
A fully functional mail server suite ("mailcow: dockerized") providing:
- SMTP/IMAP/POP3 services.
- Webmail (SOGo).
- Anti-spam and anti-virus protection (Rspamd, ClamAV).
- Management UI.

### 3. Static Sites (Hugo)
Hosted within the `hubs-compose` environment are several static websites generated with Hugo:
- **tobias-weiss.org:** Personal homepage and portfolio (Theme: Tobi-Goa).
- **chemie-lernen.org:** Educational resource.
- **graphwiz.ai:** AI and visualization project.

### 4. Knowledge Management (XWiki)
An XWiki instance (`xwiki-web` and `xwiki-db`) integration for collaborative documentation and knowledge management.

## Network & Routing
Traffic is managed via **HAProxy** (`hubs-compose/haproxy/`), which handles:
- SSL/TLS termination (Let's Encrypt).
- Host-based routing to different backends (Hubs, Mailcow, XWiki, Hugo sites).
- Automatic HTTP-to-HTTPS redirection.

## Getting Started

### Prerequisites
- Docker & Docker Compose
- Mutagen & Mutagen Compose (for Hubs synchronization)

### running the stack
Refer to the `hubs-compose/README.md` and `mailcow-dockerized/README.md` for specific startup instructions for each subsystem.

For the main Hubs and Web stack:
```bash
cd hubs-compose
./bin/up
```
# hugo-sites
