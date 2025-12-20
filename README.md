# Hugo Multi-Site Infrastructure

This repository manages a collection of Hugo-based websites served through a centralized **Traefik** reverse proxy with automatic SSL termination via Let's Encrypt.

## Architecture

The setup uses Docker Compose to orchestrate multiple independent Hugo containers and a Traefik proxy.

- **Reverse Proxy**: Traefik v2.9
- **SSL**: Automatic HTTPS via Let's Encrypt (TLS-ALPN-01 challenge)
- **Routing**: Based on Docker labels
- **Sites**: Hugo instances running in server mode for live-reload support

## Hosted Sites

| Site Name | Primary Domain | Local Port |
| :--- | :--- | :--- |
| **Chemie Lernen** | [chemie-lernen.org](https://chemie-lernen.org) | 1313 |
| **GraphWiz AI** | [graphwiz.ai](https://graphwiz.ai) | 1314 |
| **Tobias Weiss** | [tobias-weiss.org](https://tobias-weiss.org) | 1315 |

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Ports 80 and 443 available on the host (managed via HAProxy in the `hubs-compose` project if applicable)

### Running the Services
1.  **Clone the repository**:
    ```bash
    git clone git@github.com:tobias-weiss-ai-xr/hugo-sites.git
    cd hugo-sites
    ```
2.  **Configure environment**:
    Ensure the `.env` file contains the correct domains.
3.  **Start the containers**:
    ```bash
    docker compose up -d --build
    ```

## Management

- **View Logs**: `docker compose logs -f`
- **Restart a Site**: `docker compose restart hugo-tobias-weiss-org`
- **Traefik Dashboard**: Available internally at `http://localhost:8083` or via `https://traefik.graphwiz.ai` (if configured in HAProxy).

## Development

Each site is mounted as a volume, allowing for real-time updates when content in the `myhugoapp` directories is modified.

## Documentation
- [Architecture Details](ARCHITECTURE.md)
- [Testing Guide](TESTING.md)
